"""Voice-command understanding: intent classification, slot tagging and product resolution.

    "add the cheapest camera"   -> add, product=Action Camera (cheapest of 3 cameras), quantity=1
    "i want to pairs of jeans"  -> add, product=Jeans, quantity=2   ("to" before a plural)
    "take me to the cart"       -> open_cart

1. Normalise: lower-case, number words to digits, "to"/"too" before a plural noun to 2.
2. Intent: logistic regression over a MiniLM sentence embedding plus word TF-IDF.
3. Slots: a per-token classifier (BIO tags for PRODUCT, QTY, CATEGORY, SORT) over
   hand-written token features.
4. Resolve: the PRODUCT phrase goes through the hybrid product search, so synonyms
   ("mobile phone", "suncream") work without being in the training data. With a SORT
   slot ("cheapest", "most expensive"), the choice is among products that share the
   phrase's head noun.

Trained by ``eval/voice_train.py`` on generated commands (``quantumbuy_ml/voice_data.py``)
and stored as plain JSON (vocabularies and weights), so loading needs no pickle.
"""
from __future__ import annotations

import json
import math
import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

import numpy as np

from quantumbuy_ml.catalog import Product

MODEL_PATH = Path(__file__).resolve().parent / "models" / "voice_model.json"

INTENTS = ["add", "remove", "open_category", "open_cart", "checkout", "search", "describe", "help"]
TAGS = ["O", "B-PRODUCT", "I-PRODUCT", "B-QTY", "B-CATEGORY", "I-CATEGORY", "B-SORT", "I-SORT"]

NUMBER_WORDS = {"a": 1, "an": 1, "one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6,
                "seven": 7, "eight": 8, "nine": 9, "ten": 10, "a couple of": 2, "couple": 2, "dozen": 12}
_DIGITS = {"one": "1", "two": "2", "three": "3", "four": "4", "five": "5", "six": "6", "seven": "7",
           "eight": "8", "nine": "9", "ten": "10"}
CHEAP = {"cheapest", "cheaper", "cheap", "lowest", "least", "budget", "inexpensive"}
EXPENSIVE = {"expensive", "priciest", "pricier", "premium", "best", "costliest", "dearest"}

# Words that carry the command, not the product, for the no-product-tagged fallback.
_COMMAND_WORDS = {
    "add", "order", "buy", "get", "put", "want", "need", "like", "would", "i'd", "i'll", "take", "purchase", "grab",
    "remove", "delete", "cancel", "drop", "rid", "out", "tell", "describe", "show", "read", "what", "how", "much",
    "is", "are", "does", "do", "the", "a", "an", "some", "me", "my", "to", "in", "into", "of", "for", "from", "and",
    "please", "can", "could", "you", "i", "it", "cart", "basket", "order", "um", "uh", "okay", "so", "hey", "one",
    "more", "new", "about", "look", "price", "cost", "details", "description", "pack", "bag", "bottle", "pair",
    "packet", "box", "jar", "tube", "loaf", "litre",
}

CATEGORY_WORDS = {
    "Electronics": ["electronics", "electronic", "gadgets", "gadget", "tech", "devices"],
    "Clothing and Accessories": ["clothing", "clothes", "accessories", "fashion", "apparel", "outfits"],
    "Home and Kitchen": ["home", "kitchen", "appliances", "household", "kitchenware"],
    "Beauty and Personal Care": ["beauty", "personal", "care", "cosmetics", "makeup", "skincare", "toiletries"],
    "Groceries and Gourmet Food": ["groceries", "grocery", "food", "gourmet", "pantry"],
}


_ADD_VERBS_FLAT = {"add", "buy", "order", "want", "get", "need", "take", "purchase"}


def normalise(text: str) -> list[str]:
    t = re.sub(r"[^a-z0-9' ]", " ", text.lower().replace("-", " "))
    tokens = [w for w in t.split() if w]
    out = []
    for i, w in enumerate(tokens):
        nxt = tokens[i + 1] if i + 1 < len(tokens) else ""
        nxt2 = tokens[i + 2] if i + 2 < len(tokens) else ""
        if w in ("to", "too") and i > 0 and tokens[i - 1] in _ADD_VERBS_FLAT and (nxt.endswith("s") or nxt2.endswith("s")):
            out.append("2")                       # "add to t shirts" -> "add 2 t shirts"
        else:
            out.append(_DIGITS.get(w, w))
    return out



# ── token features for the slot tagger ─────────────────────────────────────

def token_features(tokens: list[str], i: int, product_vocab: set[str], category_vocab: set[str]) -> dict:
    w = tokens[i]

    def at(k):
        j = i + k
        return tokens[j] if 0 <= j < len(tokens) else ("<s>" if j < 0 else "</s>")

    f = {
        "bias": 1.0, "w=" + w: 1.0, "suf3=" + w[-3:]: 1.0, "pre3=" + w[:3]: 1.0,
        "digit": float(w.isdigit()), "numword": float(w in NUMBER_WORDS),
        "in_product_vocab": float(w in product_vocab or w.rstrip("s") in product_vocab),
        "in_category_vocab": float(w in category_vocab),
        "cheap": float(w in CHEAP), "expensive": float(w in EXPENSIVE),
        "first": float(i == 0), "last": float(i == len(tokens) - 1),
    }
    for k in (-2, -1, 1, 2):
        u = at(k)
        f[f"w{k}=" + u] = 1.0
        f[f"pv{k}"] = float(u in product_vocab or u.rstrip("s") in product_vocab)
        f[f"cv{k}"] = float(u in category_vocab)
        f[f"dg{k}"] = float(u.isdigit())
    return f


# ── a tiny JSON-serialisable linear model ──────────────────────────────────

@dataclass
class Linear:
    """Multinomial logistic regression over sparse dict features (stored as JSON)."""

    classes: list[str]
    vocab: dict[str, int]
    weights: list[list[float]]     # (n_classes, n_features)
    bias: list[float]

    def logits(self, feats: dict[str, float]) -> np.ndarray:
        W = self._W
        z = np.array(self.bias, dtype=float)
        for name, v in feats.items():
            j = self.vocab.get(name)
            if j is not None:
                z += W[:, j] * v
        return z

    def __post_init__(self) -> None:
        self._W = np.array(self.weights, dtype=float)

    def proba(self, feats: dict[str, float]) -> np.ndarray:
        z = self.logits(feats)
        z = np.exp(z - z.max())
        return z / z.sum()

    def to_json(self) -> dict:
        return {"classes": self.classes, "vocab": self.vocab, "weights": self.weights, "bias": self.bias}


@dataclass
class IntentModel:
    """Logistic regression over [MiniLM embedding (dense), word TF-IDF (sparse)]."""

    classes: list[str]
    idf: dict[str, float]
    coef_dense: list[list[float]]
    coef_sparse: list[list[float]]
    vocab: dict[str, int]
    bias: list[float]

    def __post_init__(self) -> None:
        self._D = np.array(self.coef_dense)
        self._S = np.array(self.coef_sparse)

    def tfidf(self, tokens: list[str]) -> np.ndarray:
        v = np.zeros(len(self.vocab))
        grams = tokens + [f"{a}_{b}" for a, b in zip(tokens, tokens[1:])]
        for g in grams:
            j = self.vocab.get(g)
            if j is not None:
                v[j] += 1.0
        for g, j in self.vocab.items():
            if v[j]:
                v[j] = (1 + math.log(v[j])) * self.idf[g]
        n = np.linalg.norm(v)
        return v / n if n else v

    def proba(self, embedding: np.ndarray, tokens: list[str]) -> np.ndarray:
        z = np.array(self.bias) + self._D @ embedding + self._S @ self.tfidf(tokens)
        z = np.exp(z - z.max())
        return z / z.sum()


# ── parsing ────────────────────────────────────────────────────────────────

@dataclass
class Parse:
    intent: str
    confidence: float
    product: Optional[Product] = None
    quantity: int = 1
    category: Optional[str] = None
    sort: Optional[str] = None          # "cheapest" | "most_expensive"
    query: str = ""                     # for search
    spans: dict = field(default_factory=dict)

    def to_json(self) -> dict:
        return {"intent": self.intent, "confidence": round(self.confidence, 4),
                "product_id": self.product.id if self.product else None,
                "product_name": self.product.name if self.product else None,
                "quantity": self.quantity, "category": self.category, "sort": self.sort,
                "query": self.query, "spans": self.spans}


def spans_from_tags(tokens: list[str], tags: list[str]) -> dict[str, list[str]]:
    out: dict[str, list[str]] = {}
    cur, buf = None, []
    for w, t in zip(tokens + ["</s>"], tags + ["O"]):
        kind = t[2:] if t != "O" else None
        if t.startswith("B-") or kind != cur:
            if cur and buf:
                out.setdefault(cur, []).append(" ".join(buf))
            cur, buf = (kind, [w]) if kind else (None, [])
        elif kind:
            buf.append(w)
    return out


class VoiceParser:
    def __init__(self, data: dict, products: list[Product], search, encoder) -> None:
        self.intent = IntentModel(**data["intent"])
        self.tagger = Linear(**data["tagger"])
        self.products = products
        self.search = search
        self.encoder = encoder
        self.product_vocab = {w for p in products for w in re.findall(r"[a-z0-9]+", p.name.lower().replace("-", " "))}
        self.category_vocab = {w for ws in CATEGORY_WORDS.values() for w in ws}
        self.unit_words = set(data.get("unit_words", []))

    @classmethod
    def load(cls, products, search, encoder, path: Path = MODEL_PATH) -> "VoiceParser":
        return cls(json.loads(path.read_text(encoding="utf-8")), products, search, encoder)

    def tag(self, tokens: list[str]) -> list[str]:
        tags = []
        for i in range(len(tokens)):
            p = self.tagger.proba(token_features(tokens, i, self.product_vocab, self.category_vocab))
            t = self.tagger.classes[int(np.argmax(p))]
            if t.startswith("I-") and (not tags or tags[-1][2:] != t[2:]):
                t = "B-" + t[2:]                   # repair an I- without a B-
            tags.append(t)
        return tags

    def resolve_product(self, phrase: str, sort: Optional[str], utterance: str) -> Optional[Product]:
        phrase = " ".join(w for w in phrase.split() if w not in self.unit_words)
        if not phrase:
            return None
        hits = self.search.search(phrase, k=10)
        if not hits:
            return None
        if sort:
            head = phrase.split()[-1].rstrip("s")
            pool = [h for h in hits if any(head in w or w in head for w in
                                           re.findall(r"[a-z0-9]+", h.product.name.lower()) if len(w) > 2)]
            if not pool:
                pool = hits[:3]
            # break price ties by how well the whole utterance matches ("cream for my face")
            context = {h.product.id: s for h, s in
                       ((h, h.score) for h in self.search.search(utterance, k=len(self.products)))}
            key = (lambda h: (h.product.price, -context.get(h.product.id, 0))) if sort == "cheapest" else \
                  (lambda h: (-h.product.price, -context.get(h.product.id, 0)))
            return sorted(pool, key=key)[0].product
        return hits[0].product

    def resolve_category(self, phrase: str, tokens: list[str]) -> Optional[str]:
        words = set(phrase.split()) | set(tokens)
        best, score = None, 0
        for cat, ws in CATEGORY_WORDS.items():
            s = len(words & set(ws)) + len(words & set(cat.lower().split()))
            if s > score:
                best, score = cat, s
        if best is None and phrase:
            v = self.encoder.encode([phrase] + list(CATEGORY_WORDS))
            best = list(CATEGORY_WORDS)[int(np.argmax(v[1:] @ v[0]))]
        return best

    def parse(self, text: str) -> Parse:
        tokens = normalise(text)
        if not tokens:
            return Parse("help", 0.0)
        emb = self.encoder.encode([" ".join(tokens)])[0]
        p = self.intent.proba(emb, tokens)
        intent = self.intent.classes[int(np.argmax(p))]
        tags = self.tag(tokens)
        spans = spans_from_tags(tokens, tags)
        sort_words = " ".join(spans.get("SORT", []))
        sort = None
        if any(w in CHEAP for w in sort_words.split()) or (not sort_words and any(w in CHEAP for w in tokens)):
            sort = "cheapest"
        elif any(w in EXPENSIVE for w in sort_words.split()) or (not sort_words and "most" in tokens and "expensive" in tokens):
            sort = "most_expensive"
        result = Parse(intent, float(p.max()), spans=spans, sort=sort)
        if intent in ("add", "remove", "describe"):
            phrase = " ".join(spans.get("PRODUCT", []))
            if not phrase:
                # No product tagged (a misspelling or a synonym the tagger doesn't know): search
                # with the command's content words and let the embeddings resolve them.
                phrase = " ".join(w for w in tokens if w not in _COMMAND_WORDS and not w.isdigit())
            result.product = self.resolve_product(phrase, sort, " ".join(tokens))
            qty = next((int(w) for i, w in enumerate(tokens) if w.isdigit() and
                        tags[i] == "B-QTY" and not (i > 0 and tokens[i - 1] == "the")), None)  # "the two mixers"
            result.quantity = qty if (qty and 0 < qty <= 50) else 1
        elif intent == "open_category":
            result.category = self.resolve_category(" ".join(spans.get("CATEGORY", [])), tokens)
        elif intent == "search":
            result.query = " ".join(tokens)
        return result
