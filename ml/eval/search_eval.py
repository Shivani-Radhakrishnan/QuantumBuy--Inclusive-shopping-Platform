"""Evaluate product search on hand-labelled queries (data/search_queries.csv).

    python -m eval.search_eval

143 queries (50 dev, 93 test) of six kinds: exact names, synonyms, needs ("i want to
make smoothies"), looks ("pink tablet", answerable only from the photo descriptions),
misspellings and broad intents. The hybrid weight is chosen on dev; test is reported.
Metrics: Recall@5 (share of relevant products in the top 5), MRR@10, nDCG@10.
"""
from __future__ import annotations

import csv
import json
import math
from collections import defaultdict
from pathlib import Path

import numpy as np

from quantumbuy_ml import catalog
from quantumbuy_ml.encoder import get_encoder
from quantumbuy_ml.search import ProductSearch

ML = Path(__file__).resolve().parent.parent
QUERIES = ML / "data" / "search_queries.csv"
RESULTS = ML / "eval" / "results"
WEIGHTS = [round(0.1 * i, 1) for i in range(11)]


def load_queries() -> list[dict]:
    with QUERIES.open(newline="", encoding="utf-8") as fh:
        rows = list(csv.DictReader(fh))
    for r in rows:
        r["relevant"] = {int(x) for x in r["relevant"].split(";") if x}
    return rows


def metrics(ranked: list[int], relevant: set[int]) -> dict:
    top5 = ranked[:5]
    recall5 = len(relevant & set(top5)) / len(relevant)
    rr = next((1 / (i + 1) for i, pid in enumerate(ranked[:10]) if pid in relevant), 0.0)
    dcg = sum(1 / math.log2(i + 2) for i, pid in enumerate(ranked[:10]) if pid in relevant)
    idcg = sum(1 / math.log2(i + 2) for i in range(min(len(relevant), 10)))
    return {"recall@5": recall5, "mrr@10": rr, "ndcg@10": dcg / idcg}


def evaluate(engine: ProductSearch, queries: list[dict], method: str, weight: float | None = None) -> dict:
    per_kind = defaultdict(list)
    for q in queries:
        if method == "hybrid":
            s = engine.hybrid_scores(q["query"], weight)
        else:
            s = {"keyword": engine.keyword_scores, "semantic": engine.semantic_scores}[method](q["query"])
        order = np.argsort(-s, kind="stable")
        ranked = [engine.products[i].id for i in order if method != "keyword" or s[i] > 0]
        m = metrics(ranked, q["relevant"])
        per_kind[q["kind"]].append(m)
        per_kind["all"].append(m)
    return {k: {name: float(np.mean([m[name] for m in v])) for name in v[0]} | {"n": len(v)}
            for k, v in per_kind.items()}


def compute() -> dict:
    queries = load_queries()
    dev = [q for q in queries if q["split"] == "dev"]
    test = [q for q in queries if q["split"] == "test"]
    enc = get_encoder()
    products = list(catalog.load())
    engine = ProductSearch(products, enc)
    with_ai = ProductSearch(products, enc, with_photo_descriptions=True)

    dev_curve = {w: evaluate(engine, dev, "hybrid", w)["all"]["ndcg@10"] for w in WEIGHTS}
    best_w = max(WEIGHTS, key=lambda w: (dev_curve[w], -abs(w - 0.5)))
    dev_with_ai = evaluate(with_ai, dev, "hybrid", best_w)["all"]["ndcg@10"]
    report = {"n_dev": len(dev), "n_test": len(test), "dev_ndcg_by_weight": dev_curve, "weight": best_w,
              "dev_ndcg": {"without photo descriptions": dev_curve[best_w], "with photo descriptions": dev_with_ai},
              "products_with_ai_description": sum(bool(p.ai_description) for p in products), "test": {}}
    systems = {
        "keyword (BM25)": (engine, "keyword", None),
        "semantic (MiniLM)": (engine, "semantic", None),
        f"hybrid (w={best_w})": (engine, "hybrid", best_w),
        "hybrid, photo descriptions also indexed": (with_ai, "hybrid", best_w),
    }
    for name, (eng, method, w) in systems.items():
        report["test"][name] = evaluate(eng, test, method, w)
    return report


def main() -> int:
    report = compute()
    RESULTS.mkdir(parents=True, exist_ok=True)
    (RESULTS / "search.json").write_text(json.dumps(report, indent=1) + "\n", encoding="utf-8")
    md = render(report)
    (RESULTS / "search.md").write_text(md, encoding="utf-8")
    print(md)
    return 0


def render(rep: dict) -> str:
    kinds = ["exact", "synonym", "need", "look", "misspelling", "broad"]
    out = [f"### Product search ({rep['n_test']} test queries; hybrid weight {rep['weight']} chosen on "
           f"{rep['n_dev']} dev queries)", "",
           "| System | Recall@5 | MRR@10 | nDCG@10 |", "|---|---|---|---|"]
    for name, r in rep["test"].items():
        a = r["all"]
        out.append(f"| {name} | {a['recall@5']:.3f} | {a['mrr@10']:.3f} | {a['ndcg@10']:.3f} |")
    out += ["", "nDCG@10 by query kind (test):", "",
            "| System | " + " | ".join(f"{k} ({rep['test'][next(iter(rep['test']))][k]['n']})" for k in kinds) + " |",
            "|---|" + "---|" * len(kinds)]
    for name, r in rep["test"].items():
        out.append(f"| {name} | " + " | ".join(f"{r[k]['ndcg@10']:.3f}" for k in kinds) + " |")
    d = rep["dev_ndcg"]
    out += ["", f"Photo descriptions in the index (decided on dev): nDCG@10 {d['with photo descriptions']:.3f} with, "
                f"{d['without photo descriptions']:.3f} without, so they are left out of the index.",
            "The look queries all contain the product's name, so they do not test the descriptions."]
    out += ["", "Dev nDCG@10 by hybrid weight (1.0 = embeddings only, 0.0 = trigram BM25 only):", "",
            "| weight | " + " | ".join(str(w) for w in rep["dev_ndcg_by_weight"]) + " |",
            "|---|" + "---|" * len(rep["dev_ndcg_by_weight"]),
            "| nDCG@10 | " + " | ".join(f"{v:.3f}" for v in rep["dev_ndcg_by_weight"].values()) + " |"]
    return "\n".join(out) + "\n"


if __name__ == "__main__":
    raise SystemExit(main())
