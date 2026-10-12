import numpy as np

from quantumbuy_ml import catalog
from quantumbuy_ml.recommend import Recommender
from quantumbuy_ml.search import BM25, trigrams, words
from quantumbuy_ml.sessions import MISSIONS, simulate


def test_catalogue_is_read_from_the_app(products):
    assert len(products) == 100 and len({p.id for p in products}) == 100
    assert catalog.categories() == ["Electronics", "Clothing and Accessories", "Home and Kitchen",
                                    "Beauty and Personal Care", "Groceries and Gourmet Food"]
    assert catalog.by_id()[318].name == "Rice Cooker"
    known = {p.id for p in products}
    assert all(i in known for items in MISSIONS.values() for i in items)


def test_encoder_gives_unit_vectors_and_sensible_similarity(encoder):
    v = encoder.encode(["electric kettle for boiling water", "boil water quickly", "a pair of jeans"])
    assert v.shape == (3, 384) and np.allclose(np.linalg.norm(v, axis=1), 1, atol=1e-5)
    assert v[0] @ v[1] > v[0] @ v[2]


def test_bm25_and_trigrams():
    bm = BM25([words("rice cooker"), words("rice"), words("olive oil")])
    s = bm.scores(words("rice"))
    assert s[1] > s[0] > 0 == s[2]
    assert "#he" in trigrams("hedphones")


def test_search_exact_synonym_and_typo(engine):
    assert engine.search("rice cooker", 1)[0].product.name == "Rice Cooker"
    assert engine.search("fridge", 1)[0].product.name == "Refrigerator"
    assert engine.search("hedphones", 1)[0].product.name == "Headphones"
    assert engine.search("", 5) == []


def test_recommender_counts_and_cold_start(products, engine):
    sessions = [[501, 318], [501, 318, 505], [501, 505]]
    rec = Recommender(products, engine.vectors, sessions)
    assert rec.count[rec.index[501]] == 3 and rec.co[rec.index[501], rec.index[318]] == 2
    assert rec.recommend(501, 2, "cooccurrence")[0].id in (318, 505)
    # an item never bought falls back to content similarity
    assert [p.id for p in rec.recommend(304, 3, "hybrid")] == [p.id for p in rec.recommend(304, 3, "content")]
    assert 304 not in [p.id for p in rec.recommend(304, 5)]


def test_simulation_is_deterministic():
    assert simulate(50, seed=3) == simulate(50, seed=3) != simulate(50, seed=4)


def test_generated_dart_descriptions_match_the_checked_json():
    import json
    import re
    data = json.loads(catalog.DESCRIPTIONS.read_text(encoding="utf-8"))
    dart = (catalog.REPO / "lib" / "data" / "photo_descriptions.dart").read_text(encoding="utf-8")
    entries = dict(re.findall(r"^  '([^']+)': '((?:[^'\\]|\\.)*)',$", dart, re.M))
    assert {k: v.replace("\\'", "'") for k, v in entries.items()} == data["descriptions"]
    assert not set(data["descriptions"]) & set(data["rejected"])
