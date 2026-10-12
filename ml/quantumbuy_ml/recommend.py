"""Recommendations: "similar items" from product embeddings and "bought together" from
co-purchase counts, blended so that rarely bought items still get sensible suggestions.

    score(i -> j) = alpha * cooccurrence_lift(i, j) + (1 - alpha) * cosine(i, j)

``alpha`` grows with how often item i has been bought (``n_i / (n_i + shrink)``), so a
well-observed item relies on purchase data and a new or rare item falls back to content
similarity (the cold-start case).
"""
from __future__ import annotations

from collections import Counter
from itertools import combinations

import numpy as np

from quantumbuy_ml.catalog import Product

SHRINK = 8.0   # purchases needed before co-occurrence and content get equal weight


class Recommender:
    def __init__(self, products: list[Product], vectors: np.ndarray | None = None,
                 sessions: list[list[int]] | None = None, shrink: float = SHRINK) -> None:
        self.products = list(products)
        self.index = {p.id: i for i, p in enumerate(self.products)}
        n = len(self.products)
        self.content = vectors @ vectors.T if vectors is not None else np.zeros((n, n))
        np.fill_diagonal(self.content, -1.0)
        self.shrink = shrink
        self.count = np.zeros(n)
        self.co = np.zeros((n, n))
        for s in sessions or []:
            items = sorted({self.index[i] for i in s if i in self.index})
            for i in items:
                self.count[i] += 1
            for a, b in combinations(items, 2):
                self.co[a, b] += 1
                self.co[b, a] += 1
        self.n_sessions = max(len(sessions or []), 1)

    def popularity(self) -> np.ndarray:
        return self.count.copy()

    def cooccurrence(self, i: int) -> np.ndarray:
        """Lift-style score: how much more often j is bought with i than on its own, squashed to 0-1."""
        if self.count[i] == 0:
            return np.zeros(len(self.products))
        p_j = (self.count + 1) / (self.n_sessions + 1)
        p_j_given_i = self.co[i] / self.count[i]
        lift = p_j_given_i / p_j
        return lift / (1 + lift)

    def scores(self, product_id: int, method: str = "hybrid") -> np.ndarray:
        i = self.index[product_id]
        if method == "popular":
            s = self.popularity()
        elif method == "content":
            s = self.content[i].copy()
        elif method == "cooccurrence":
            s = self.cooccurrence(i)
        else:
            alpha = self.count[i] / (self.count[i] + self.shrink)
            s = alpha * self.cooccurrence(i) + (1 - alpha) * (self.content[i] + 1) / 2
        s = s.astype(float)
        s[i] = -np.inf
        return s

    def recommend(self, product_id: int, k: int = 5, method: str = "hybrid") -> list[Product]:
        s = self.scores(product_id, method)
        return [self.products[j] for j in np.argsort(-s, kind="stable")[:k]]

    def similar(self, product_id: int, k: int = 5) -> list[Product]:
        return self.recommend(product_id, k, "content")
