"""Published evaluation numbers reproduce from the committed data and models (nothing is written)."""
import json
from pathlib import Path

import pytest

RESULTS = Path(__file__).resolve().parents[1] / "eval" / "results"


def test_voice_results_reproduce():
    from eval import voice_eval
    published = json.loads((RESULTS / "voice.json").read_text())
    now = voice_eval.compute()
    for system in ("voice model", "rule parser"):
        assert now[system]["all"] == published[system]["all"], system


def test_search_results_reproduce():
    from eval import search_eval
    published = json.loads((RESULTS / "search.json").read_text())
    now = search_eval.compute()
    assert now["weight"] == published["weight"]
    for system, r in published["test"].items():
        assert now["test"][system]["all"]["ndcg@10"] == pytest.approx(r["all"]["ndcg@10"], abs=0.005), system
