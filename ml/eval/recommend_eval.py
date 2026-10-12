"""Evaluate "bought together" recommendations on simulated sessions (see quantumbuy_ml/sessions.py).

    python -m eval.recommend_eval

For every held-out session with at least two items, each item in turn is the query and
the others are what the shopper actually bought with it. HitRate@5: share of queries
where at least one co-bought item is in the top 5. Repeated for growing amounts of
purchase history, and separately for "cold" query items (fewer than 8 training purchases).
The data is simulated, so these numbers show how the methods behave, not real-shop accuracy.
"""
from __future__ import annotations

import json
from pathlib import Path

import numpy as np

from quantumbuy_ml import catalog
from quantumbuy_ml.encoder import get_encoder
from quantumbuy_ml.recommend import Recommender
from quantumbuy_ml.sessions import simulate

RESULTS = Path(__file__).resolve().parent / "results"
HISTORY = [50, 200, 1000, 5000]
METHODS = ["popular", "content", "cooccurrence", "hybrid"]


def evaluate(rec: Recommender, test: list[list[int]], k: int = 5) -> dict:
    hits = {m: [] for m in METHODS}
    cold = {m: [] for m in METHODS}
    for s in test:
        if len(s) < 2:
            continue
        for q in s:
            others = set(s) - {q}
            is_cold = rec.count[rec.index[q]] < 8
            for m in METHODS:
                top = [p.id for p in rec.recommend(q, k, m)]
                h = float(bool(others & set(top)))
                hits[m].append(h)
                if is_cold:
                    cold[m].append(h)
    return {m: {"hit@5": float(np.mean(hits[m])), "n": len(hits[m]),
                "cold_hit@5": float(np.mean(cold[m])) if cold[m] else None, "n_cold": len(cold[m])}
            for m in METHODS}


def main() -> int:
    products = list(catalog.load())
    vectors = get_encoder().encode([p.text() for p in products])
    ids = [p.id for p in products]
    test = simulate(1000, seed=1, all_ids=ids)
    report = {"test_sessions": len(test), "by_history": {}}
    for n in HISTORY:
        rec = Recommender(products, vectors, simulate(n, seed=0, all_ids=ids))
        report["by_history"][n] = evaluate(rec, test)
    RESULTS.mkdir(parents=True, exist_ok=True)
    (RESULTS / "recommend.json").write_text(json.dumps(report, indent=1) + "\n", encoding="utf-8")
    md = render(report)
    (RESULTS / "recommend.md").write_text(md, encoding="utf-8")
    print(md)
    return 0


def render(rep: dict) -> str:
    out = [f"### \"Bought together\" on simulated sessions ({rep['test_sessions']} held-out sessions)", "",
           "HitRate@5 by amount of purchase history (cold = query items with < 8 training purchases):", "",
           "| Training sessions | " + " | ".join(METHODS) + " | " + " | ".join(f"{m} (cold)" for m in ("content", "cooccurrence", "hybrid")) + " |",
           "|---|" + "---|" * (len(METHODS) + 3)]
    for n, r in rep["by_history"].items():
        cells = [f"{r[m]['hit@5']:.3f}" for m in METHODS]
        colds = [("-" if r[m]["cold_hit@5"] is None else f"{r[m]['cold_hit@5']:.3f} (n={r[m]['n_cold']})")
                 for m in ("content", "cooccurrence", "hybrid")]
        out.append(f"| {n} | " + " | ".join(cells) + " | " + " | ".join(colds) + " |")
    return "\n".join(out) + "\n"


if __name__ == "__main__":
    raise SystemExit(main())
