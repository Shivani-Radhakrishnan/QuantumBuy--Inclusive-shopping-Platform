"""Evaluate voice-command understanding on 150 hand-written commands (data/voice_test.csv).

    python -m eval.voice_eval            # uses the recorded rule-parser predictions
    python -m eval.voice_eval --rerun-dart   # re-run the app's Dart rule parser first

A command counts as understood when the intent is right and so are the slots that
intent needs: product and quantity for "add", product for "remove" and "describe",
category for "open_category". The baseline is the app's existing rule-based parser
(lib/services/voice_command.dart), which supports add, open_category and open_cart.
"""
from __future__ import annotations

import argparse
import csv
import json
import shutil
import subprocess
from collections import defaultdict
from pathlib import Path

from quantumbuy_ml import catalog
from quantumbuy_ml.encoder import get_encoder
from quantumbuy_ml.search import ProductSearch
from quantumbuy_ml.voice import INTENTS, VoiceParser

ML = Path(__file__).resolve().parent.parent
REPO = ML.parent
TEST = ML / "data" / "voice_test.csv"
BASELINE = ML / "data" / "voice_baseline_predictions.jsonl"
BEFORE_FIXES = ML / "eval" / "results" / "voice_before_fixes.json"
RESULTS = ML / "eval" / "results"
RULE_INTENTS = {"add", "open_category", "open_cart"}
DART_CANDIDATES = ["dart", str(Path.home() / "Documents/Program files/flutter/bin/dart")]


def load_test() -> list[dict]:
    with TEST.open(newline="", encoding="utf-8") as fh:
        return list(csv.DictReader(fh))


def correct(gold: dict, pred: dict) -> bool:
    if pred.get("intent") != gold["intent"]:
        return False
    if gold["intent"] in ("add", "remove", "describe") and str(pred.get("product")) != gold["product"]:
        return False
    if gold["intent"] == "add" and int(pred.get("quantity") or 1) != int(gold["quantity"] or 1):
        return False
    if gold["intent"] == "open_category" and pred.get("category") != gold["category"]:
        return False
    return True


def run_dart(texts: list[str]) -> list[dict]:
    dart = next((d for d in DART_CANDIDATES if shutil.which(d) or Path(d).exists()), None)
    if dart is None:
        raise SystemExit("dart not found")
    out = subprocess.run([dart, "run", "tool/parse_commands.dart"], input="\n".join(texts) + "\n",
                         capture_output=True, text=True, cwd=REPO, check=True).stdout
    return [json.loads(line) for line in out.splitlines() if line.startswith("{")]


def score(gold: list[dict], preds: list[dict]) -> dict:
    by = defaultdict(list)
    for g, p in zip(gold, preds):
        ok = correct(g, p)
        by[g["intent"]].append(ok)
        by["all"].append(ok)
        if g["intent"] in RULE_INTENTS:
            by["rule-supported intents"].append(ok)
    intent_acc = sum(g["intent"] == p.get("intent") for g, p in zip(gold, preds)) / len(gold)
    return {"intent_accuracy": intent_acc} | {k: {"accuracy": sum(v) / len(v), "n": len(v)} for k, v in by.items()}


def compute(rerun_dart: bool = False) -> dict:
    gold = load_test()
    texts = [g["text"] for g in gold]
    if rerun_dart or not BASELINE.exists():
        baseline = run_dart(texts)
        BASELINE.write_text("\n".join(json.dumps(b) for b in baseline) + "\n", encoding="utf-8")
    baseline = [json.loads(line) for line in BASELINE.read_text(encoding="utf-8").splitlines() if line]
    assert len(baseline) == len(gold)

    products = list(catalog.load())
    enc = get_encoder()
    parser = VoiceParser.load(products, ProductSearch(products, enc), enc)
    parses = [parser.parse(t) for t in texts]
    model_preds = [{"intent": p.intent, "product": p.product.id if p.product else None, "quantity": p.quantity,
                    "category": p.category} for p in parses]

    report = {"n": len(gold), "rule parser": score(gold, baseline), "voice model": score(gold, model_preds),
              "errors": [{"text": g["text"], "gold": {k: g[k] for k in ("intent", "product", "quantity", "category")},
                          "pred": m} for g, m in zip(gold, model_preds) if not correct(g, m)]}
    return report


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--rerun-dart", action="store_true")
    report = compute(ap.parse_args().rerun_dart)
    RESULTS.mkdir(parents=True, exist_ok=True)
    (RESULTS / "voice.json").write_text(json.dumps(report, indent=1) + "\n", encoding="utf-8")
    md = render(report)
    (RESULTS / "voice.md").write_text(md, encoding="utf-8")
    print(md)
    return 0


def render(rep: dict) -> str:
    rows = ["all", "rule-supported intents"] + INTENTS
    out = [f"### Voice commands ({rep['n']} hand-written test commands)", "",
           "Share of commands fully understood (intent and the slots it needs):", "",
           "| | " + " | ".join(f"{r} ({rep['voice model'][r]['n']})" for r in rows) + " | intent accuracy |",
           "|---|" + "---|" * (len(rows) + 1)]
    before = json.loads(BEFORE_FIXES.read_text()) if BEFORE_FIXES.exists() else None
    systems = [("rule parser", rep["rule parser"])]
    if before:
        systems.append(("voice model, first run (held out)", before))
    systems.append(("voice model" + (", after two fixes" if before else ""), rep["voice model"]))
    for sysname, s in systems:
        out.append(f"| {sysname} | " + " | ".join(f"{s[r]['accuracy']:.1%}" if r in s else "0.0%" for r in rows)
                   + f" | {s['intent_accuracy']:.1%} |")
    if before:
        out += ["", "The first run is the clean held-out result. Two generic fixes were made after seeing its errors: "
                "when no product word is tagged, search with the command's content words (misspellings and synonyms "
                "such as \"hedphones\", \"mobile phone\"); and a number right after \"the\" is not a quantity "
                "(\"the cheaper of the two mixers\")."]
    out += ["", f"Voice-model errors ({len(rep['errors'])}):", "", "| Command | Expected | Got |", "|---|---|---|"]
    for e in rep["errors"]:
        g, p = e["gold"], e["pred"]
        out.append(f"| {e['text']} | {g['intent']} {g['product'] or g['category'] or ''} x{g['quantity'] or ''} | "
                   f"{p['intent']} {p['product'] or p['category'] or ''} x{p['quantity']} |")
    return "\n".join(out) + "\n"


if __name__ == "__main__":
    raise SystemExit(main())
