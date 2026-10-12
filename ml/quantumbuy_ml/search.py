"""Product search: BM25 keyword baseline, semantic (embedding) search, and a hybrid of both.

The hybrid adds character-trigram BM25 to the embedding score, so misspellings
("hedphones") still match. Its weight is tuned on the dev queries only
(``eval/search_eval.py``).
"""
from __future__ import annotations

import math
import re
from collections import Counter
from dataclasses import dataclass

import numpy as np

from quantumbuy_ml.catalog import Product

HYBRID_WEIGHT = 0.7   # weight of the embedding score; chosen on the dev split, see eval/results/search.md


def words(text: str) -> list[str]:
    return re.findall(r"[a-z0-9]+", text.lower())


def trigrams(text: str) -> list[str]:
    out = []
    for w in words(text):
        w = f"#{w}#"
        out += [w[i:i + 3] for i in range(len(w) - 2)]
    return out


class BM25:
    def __init__(self, docs: list[list[str]], k1: float = 1.2, b: float = 0.75) -> None:
        self.k1, self.b = k1, b
        self.tf = [Counter(d) for d in docs]
        self.len = np.array([len(d) for d in docs], dtype=float)
        self.avg = float(self.len.mean()) if len(docs) else 0.0
        df = Counter(t for d in docs for t in set(d))
        n = len(docs)
        self.idf = {t: math.log(1 + (n - c + 0.5) / (c + 0.5)) for t, c in df.items()}

    def scores(self, query: list[str]) -> np.ndarray:
        s = np.zeros(len(self.tf))
        for t in set(query):
            idf = self.idf.get(t)
            if idf is None:
                continue
            for i, tf in enumerate(self.tf):
                f = tf.get(t, 0)
                if f:
                    s[i] += idf * f * (self.k1 + 1) / (f + self.k1 * (1 - self.b + self.b * self.len[i] / self.avg))
        return s


def _minmax(x: np.ndarray) -> np.ndarray:
    lo, hi = float(x.min()), float(x.max())
    return np.zeros_like(x) if hi - lo < 1e-12 else (x - lo) / (hi - lo)


@dataclass(frozen=True)
class Hit:
    product: Product
    score: float


class ProductSearch:
    def __init__(self, products: list[Product], encoder=None, weight: float = HYBRID_WEIGHT,
                 with_photo_descriptions: bool = False) -> None:
        self.products = list(products)
        texts = [p.text(with_photo_descriptions) for p in self.products]
        self.word_bm25 = BM25([words(t) for t in texts])
        self.gram_bm25 = BM25([trigrams(t) for t in texts])
        self.encoder = encoder
        self.vectors = encoder.encode(texts) if encoder is not None else None
        self.weight = weight

    def keyword_scores(self, query: str) -> np.ndarray:
        return self.word_bm25.scores(words(query))

    def semantic_scores(self, query: str) -> np.ndarray:
        return self.vectors @ self.encoder.encode([query])[0]

    def hybrid_scores(self, query: str, weight: float | None = None) -> np.ndarray:
        w = self.weight if weight is None else weight
        return w * _minmax(self.semantic_scores(query)) + (1 - w) * _minmax(self.gram_bm25.scores(trigrams(query)))

    def search(self, query: str, k: int = 10, method: str = "hybrid") -> list[Hit]:
        if not words(query):
            return []
        s = {"keyword": self.keyword_scores, "semantic": self.semantic_scores, "hybrid": self.hybrid_scores}[method](query)
        order = np.argsort(-s, kind="stable")[:k]
        return [Hit(self.products[i], float(s[i])) for i in order if method != "keyword" or s[i] > 0]
