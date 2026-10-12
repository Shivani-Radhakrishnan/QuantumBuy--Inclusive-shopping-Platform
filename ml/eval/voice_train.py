"""Train the voice model on generated commands and export it to JSON.

    python -m eval.voice_train

Hyper-parameters are fixed in advance (no tuning on the hand-written test set); 15% of
the generated commands are held out as a sanity check of the fit.
"""
from __future__ import annotations

import json
import math
import random
from collections import Counter

import numpy as np
from sklearn.feature_extraction import DictVectorizer
from sklearn.linear_model import LogisticRegression

from quantumbuy_ml import catalog
from quantumbuy_ml.encoder import get_encoder
from quantumbuy_ml.voice import CATEGORY_WORDS, INTENTS, MODEL_PATH, token_features
from quantumbuy_ml.voice_data import UNIT_WORDS, generate

SEED = 0


def grams(tokens: list[str]) -> list[str]:
    return tokens + [f"{a}_{b}" for a, b in zip(tokens, tokens[1:])]


def main() -> int:
    products = list(catalog.load())
    rows = generate(products, n_per_intent=600, seed=SEED)
    random.Random(SEED).shuffle(rows)
    cut = int(len(rows) * 0.85)
    train, held = rows[:cut], rows[cut:]

    # intent: [embedding ; tf-idf]
    df = Counter(g for r in train for g in set(grams(r["tokens"])))
    vocab = {g: i for i, g in enumerate(sorted(g for g, c in df.items() if c >= 2))}
    idf = {g: math.log((1 + len(train)) / (1 + df[g])) + 1 for g in vocab}

    def tfidf(tokens):
        v = np.zeros(len(vocab))
        for g in grams(tokens):
            if g in vocab:
                v[vocab[g]] += 1
        nz = v > 0
        v[nz] = (1 + np.log(v[nz])) * np.array([idf[g] for g in vocab])[nz]
        n = np.linalg.norm(v)
        return v / n if n else v

    enc = get_encoder()

    def X_intent(rs):
        emb = enc.encode([" ".join(r["tokens"]) for r in rs])
        return np.hstack([emb, np.array([tfidf(r["tokens"]) for r in rs])])

    Xi, yi = X_intent(train), [r["intent"] for r in train]
    intent_lr = LogisticRegression(C=4.0, max_iter=5000).fit(Xi, yi)
    held_acc = float(np.mean(intent_lr.predict(X_intent(held)) == np.array([r["intent"] for r in held])))

    # slot tagger
    product_vocab = {w for p in products for w in p.name.lower().replace("-", " ").split()}
    category_vocab = {w for ws in CATEGORY_WORDS.values() for w in ws}

    def tok_rows(rs):
        X, y = [], []
        for r in rs:
            for i in range(len(r["tokens"])):
                X.append(token_features(r["tokens"], i, product_vocab, category_vocab))
                y.append(r["tags"][i])
        return X, y

    dv = DictVectorizer()
    Xt, yt = tok_rows(train)
    tagger_lr = LogisticRegression(C=2.0, max_iter=5000).fit(dv.fit_transform(Xt), yt)
    Xh, yh = tok_rows(held)
    tag_acc = float(np.mean(tagger_lr.predict(dv.transform(Xh)) == np.array(yh)))

    classes = list(intent_lr.classes_)
    model = {
        "intent": {"classes": classes, "idf": idf, "vocab": vocab, "bias": intent_lr.intercept_.tolist(),
                   "coef_dense": intent_lr.coef_[:, :384].round(6).tolist(),
                   "coef_sparse": intent_lr.coef_[:, 384:].round(6).tolist()},
        "tagger": {"classes": list(tagger_lr.classes_), "vocab": {k: int(v) for k, v in dv.vocabulary_.items()},
                   "weights": tagger_lr.coef_.round(6).tolist(), "bias": tagger_lr.intercept_.tolist()},
        "unit_words": UNIT_WORDS,
        "meta": {"n_train": len(train), "n_held_out": len(held), "held_out_intent_accuracy": held_acc,
                 "held_out_tag_accuracy": tag_acc, "seed": SEED},
    }
    assert set(classes) == set(INTENTS), classes
    MODEL_PATH.write_text(json.dumps(model, separators=(",", ":")) + "\n", encoding="utf-8")
    print(f"trained on {len(train)} generated commands; held-out generated: intent {held_acc:.3f}, tags {tag_acc:.3f}")
    print(f"model: {MODEL_PATH} ({MODEL_PATH.stat().st_size // 1024} KB)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
