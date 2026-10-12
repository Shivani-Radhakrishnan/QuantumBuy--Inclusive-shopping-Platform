"""Simulated shopping sessions (there is no real purchase history for this demo shop).

Each session follows one shopping "mission" (breakfast, baking, home cinema, ...): it
picks 2-5 items from that mission and, with some probability, one random unrelated item.
Mission popularity follows a Zipf-like curve, so some missions and their items are rare,
which exercises the cold-start case. Seeded and deterministic.
"""
from __future__ import annotations

import random

MISSIONS: dict[str, list[int]] = {
    "breakfast": [506, 512, 519, 520, 307, 513, 514, 504],
    "coffee corner": [308, 514, 512, 509, 517],
    "tea time": [513, 309, 509, 517, 504],
    "baking": [511, 509, 512, 313, 319, 301, 515],
    "pasta night": [503, 502, 505, 302, 510],
    "rice dinner": [501, 318, 505, 508, 507],
    "healthy smoothies": [306, 317, 516, 520, 504],
    "frying": [315, 508, 510, 511],
    "slow cooking": [316, 507, 505, 518, 510],
    "kitchen setup": [302, 312, 320, 305, 304, 310],
    "laundry and cleaning": [314, 303, 310, 311],
    "home cinema": [103, 116, 119, 113, 107],
    "photography": [105, 112, 115, 110, 118],
    "work from home": [102, 111, 110, 104, 114],
    "phone and gadgets": [101, 106, 114, 104, 107],
    "smart home": [109, 117, 311, 103],
    "winter wardrobe": [203, 208, 209, 216, 212],
    "summer wardrobe": [201, 210, 204, 207, 206],
    "office wear": [211, 217, 219, 213, 205],
    "party outfit": [214, 205, 403, 404, 409],
    "rainy season": [218, 215, 220],
    "skincare routine": [407, 418, 402, 408, 410, 413],
    "body care": [406, 417, 412, 411],
    "hair care": [401, 414, 405, 419],
    "makeup bag": [404, 409, 416, 415],
    "grooming": [420, 120, 411, 419],
}


def simulate(n_sessions: int, seed: int = 0, noise: float = 0.2, all_ids: list[int] | None = None) -> list[list[int]]:
    rng = random.Random(seed)
    names = list(MISSIONS)
    rng.shuffle(names)
    weights = [1 / (rank + 1) ** 0.8 for rank in range(len(names))]   # Zipf-like mission popularity
    pool = all_ids or sorted({i for v in MISSIONS.values() for i in v})
    sessions = []
    for _ in range(n_sessions):
        mission = MISSIONS[rng.choices(names, weights)[0]]
        k = rng.randint(2, min(5, len(mission)))
        items = rng.sample(mission, k)
        if rng.random() < noise:
            items.append(rng.choice(pool))
        sessions.append(sorted(set(items)))
    return sessions
