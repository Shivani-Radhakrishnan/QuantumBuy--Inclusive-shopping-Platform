"""Generated training commands for the voice model (seeded, deterministic).

Templates are generic shop phrasings written for training; the hand-written test set
(data/voice_test.csv) was written separately and is never used here. Product phrases
use catalogue names only (plurals, units such as "a bag of"), not synonyms, so the
synonyms in the test set ("mobile phone", "suncream") measure generalisation through
the embedding-based product resolution.
"""
from __future__ import annotations

import random
import re

from quantumbuy_ml.catalog import Product
from quantumbuy_ml.voice import CATEGORY_WORDS, normalise

UNIT_WORDS = ["bag", "bags", "bottle", "bottles", "pair", "pairs", "packet", "packets", "pack", "packs",
              "jar", "jars", "box", "boxes", "tube", "tubes", "loaf", "loaves", "litre", "litres", "can",
              "cans", "piece", "pieces", "unit", "units", "of"]

ADD = ["add {q}{p}", "add {q}{p} to my cart", "add {q}{p} to the basket", "order {q}{p}", "buy {q}{p}",
       "i want {q}{p}", "i would like {q}{p}", "get me {q}{p}", "please add {q}{p}", "can you add {q}{p}",
       "put {q}{p} in my cart", "i need {q}{p}", "could you order {q}{p} for me", "add {q}{p} please",
       "i want to buy {q}{p}", "grab {q}{p}", "{q}{p} please", "include {q}{p} in my order"]
ADD_SORT = ["add the {s} {h}", "buy the {s} {h}", "order the {s} {h}", "i want the {s} {h}",
            "get me the {s} one of the {h}s", "add the {s} {h} to my cart"]
REMOVE = ["remove {p}", "remove the {p} from my cart", "delete the {p}", "take the {p} out of my basket",
          "i don't want the {p}", "cancel the {p}", "remove {p} from the order", "please delete {p}",
          "get rid of the {p}", "take out the {p}", "i no longer want the {p}", "undo the {p}"]
REMOVE_SORT = ["remove the {s} {h}", "delete the {s} {h}"]
DESCRIBE = ["tell me about the {p}", "describe the {p}", "what is the price of the {p}", "how much is the {p}",
            "read the description of the {p}", "what does the {p} look like", "details of the {p}",
            "give me information on the {p}", "what is the {p} like", "how much do the {p} cost",
            "explain the {p}", "what colour is the {p}"]
DESCRIBE_SORT = ["describe the {s} {h}", "how much is the {s} {h}"]
CATEGORY = ["open {c}", "show me {c}", "go to {c}", "browse {c}", "take me to {c}", "i want to see {c}",
            "show {c} products", "open the {c} section", "let me browse {c}", "display {c}", "{c} please",
            "switch to {c}", "what do you have in {c}"]
CART = ["open my cart", "show my cart", "what's in my cart", "view my basket", "go to cart", "open basket",
        "my cart", "show me my shopping cart", "what is in my basket", "check my cart", "cart please",
        "list the items in my cart", "how many items are in my cart", "open the shopping bag",
        "what did i put in my cart", "show basket contents"]
CHECKOUT = ["checkout", "check out now", "go to checkout", "pay now", "i want to pay", "place the order",
            "proceed to checkout", "complete my order", "finish shopping", "i'm done shopping",
            "buy what is in my cart", "make the payment", "confirm my order", "time to pay",
            "submit my order", "take me to payment"]
SEARCH = ["find {n}", "search for {n}", "look for {n}", "do you have {n}", "show me something for {n}",
          "i'm looking for {n}", "search {n}", "find me {n}", "any {n}", "what do you have for {n}",
          "can you find {n}", "i need something for {n}"]
NEEDS = ["oily skin", "a birthday present", "cleaning the kitchen", "summer holidays", "cold weather",
         "healthy snacks", "a home office", "making dinner", "my morning routine", "a picnic", "a new flat",
         "long hair", "a party", "rainy weather", "a baby shower", "camping", "gym clothes", "a quick meal",
         "relaxing at home", "school", "the beach", "gaming", "travel", "a wedding gift", "spicy food",
         "red clothes", "blue items", "something cheap", "gifts under 500", "small appliances",
         "things for the bathroom", "anything organic", "a gift for my mother", "sports gear"]
HELP = ["help", "help me", "what can i say", "how do i use this", "what are the commands", "i don't know what to do",
        "how does voice shopping work", "show me the help", "what are my options", "i'm lost",
        "explain how this works", "what should i say", "give me some examples", "how can you help",
        "instructions please", "i need assistance"]
FILLERS = ["", "", "", "um ", "uh ", "okay ", "hey ", "so "]
QTY_WORDS = {1: ["a ", "an ", "one ", "1 ", ""], 2: ["two ", "2 ", "to "], 3: ["three ", "3 "], 4: ["four ", "4 "],
             5: ["five ", "5 "], 6: ["six ", "6 "], 10: ["ten ", "10 "]}
UNITS = ["", "", "", "a bag of ", "a bottle of ", "a pair of ", "a packet of ", "a box of ", "a jar of ", "a tube of "]


def _plural(name: str) -> str:
    n = name.lower()
    if n.endswith(("s", "x", "ch", "sh")):
        return n if n.endswith("s") else n + "es"
    return n + "s"


def sort_groups(products: list[Product]) -> dict[str, list[Product]]:
    """Head nouns shared by several products (camera, cream, mixer, ...)."""
    groups: dict[str, list[Product]] = {}
    for p in products:
        head = re.findall(r"[a-z0-9]+", p.name.lower())[-1]
        groups.setdefault(head, []).append(p)
    return {h: ps for h, ps in groups.items() if len(ps) >= 2}


def _tagged(template: str, slots: dict[str, tuple[str, str]]) -> tuple[list[str], list[str]]:
    """Fill a template and return (tokens, BIO tags). slots: name -> (text, tag kind or "")."""
    tokens, tags = [], []
    for part in re.split(r"(\{[a-z]\})", template):
        if not part:
            continue
        if part.startswith("{"):
            text, kind = slots[part[1]]
        else:
            text, kind = part, ""
        if kind == "QTY" and text.strip() in ("to", "too"):
            toks = ["2"]   # what normalise() makes of "add to t shirts" when it sees the whole sentence
        else:
            toks = normalise(text)
        for j, t in enumerate(toks):
            tokens.append(t)
            if not kind or t in UNIT_WORDS or (kind == "PRODUCT" and t in ("a", "an", "the")):
                tags.append("O")
            elif kind == "QTY":
                tags.append("B-QTY" if t.isdigit() else "O")
            else:
                prev_same = j > 0 and tags and tags[-1].endswith("-" + kind)
                tags.append(("I-" if prev_same else "B-") + kind)
    return tokens, tags


def generate(products: list[Product], n_per_intent: int = 600, seed: int = 0) -> list[dict]:
    rng = random.Random(seed)
    groups = sort_groups(products)
    rows = []

    def product_phrase(p: Product, q: int) -> tuple[str, str, str]:
        unit = rng.choice(UNITS)
        name = _plural(p.name) if (q > 1 and not unit) else p.name.lower()
        qty = rng.choice(QTY_WORDS[q])
        if unit:
            qty = "" if q == 1 else qty
            unit = unit.replace("a ", "", 1) if q > 1 else unit
            unit = re.sub(r"(bag|bottle|pair|packet|box|jar|tube) of", r"\1s of", unit) if q > 1 else unit
        return qty, unit, name

    def emit(intent: str, template: str, slots: dict, **labels) -> None:
        filler = rng.choice(FILLERS)
        tokens, tags = _tagged(filler + template, slots)
        if tokens:
            rows.append({"tokens": tokens, "tags": tags, "intent": intent, **labels})

    for _ in range(n_per_intent):
        p = rng.choice(products)
        q = rng.choice([1, 1, 1, 2, 2, 3, 4, 5, 6, 10])
        qty, unit, name = product_phrase(p, q)
        emit("add", rng.choice(ADD), {"q": (qty, "QTY"), "p": (unit + name, "PRODUCT")}, product=p.id, quantity=q)
    for _ in range(n_per_intent // 4):
        head, ps = rng.choice(list(groups.items()))
        cheap = rng.random() < 0.5
        target = min(ps, key=lambda x: x.price) if cheap else max(ps, key=lambda x: x.price)
        s = rng.choice(["cheapest", "cheaper", "least expensive"] if cheap else ["most expensive", "priciest", "more expensive"])
        t = rng.choice(ADD_SORT + REMOVE_SORT + DESCRIBE_SORT)
        intent = "add" if t in ADD_SORT else ("remove" if t in REMOVE_SORT else "describe")
        emit(intent, t, {"s": (s, "SORT"), "h": (head, "PRODUCT")}, product=target.id, quantity=1)
    for intent, templates in (("remove", REMOVE), ("describe", DESCRIBE)):
        for _ in range(n_per_intent // 2):
            p = rng.choice(products)
            emit(intent, rng.choice(templates), {"p": (p.name.lower(), "PRODUCT")}, product=p.id, quantity=1)
    for _ in range(n_per_intent // 2):
        cat = rng.choice(list(CATEGORY_WORDS))
        phrase = rng.choice(CATEGORY_WORDS[cat] + [cat.lower(), cat.lower().split(" and ")[0]])
        emit("open_category", rng.choice(CATEGORY), {"c": (phrase, "CATEGORY")}, category=cat)
    for _ in range(n_per_intent // 2):
        emit("search", rng.choice(SEARCH), {"n": (rng.choice(NEEDS), "")})
    for intent, templates in (("open_cart", CART), ("checkout", CHECKOUT), ("help", HELP)):
        for _ in range(n_per_intent // 3):
            emit(intent, rng.choice(templates), {})
    rng.shuffle(rows)
    return rows
