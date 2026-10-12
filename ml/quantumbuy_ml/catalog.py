"""The product catalogue, read straight from the Flutter app's ``lib/data/product_catalog.dart``.

The app stays the single source of product data; a test checks that this parser sees all
100 products.
"""
from __future__ import annotations

import json
import re
from dataclasses import dataclass, field
from functools import lru_cache
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
DART_CATALOG = REPO / "lib" / "data" / "product_catalog.dart"
DESCRIPTIONS = REPO / "assets" / "ai_descriptions.json"

_CATEGORY = re.compile(r"^\s*'([^']+)':\s*\[", re.M)
_PRODUCT = re.compile(
    r"Product\(id:\s*(\d+),\s*name:\s*'([^']+)',\s*price:\s*([\d.]+),\s*imageUrl:\s*'([^']+)',\s*description:\s*'([^']+)'\)"
)


@dataclass(frozen=True)
class Product:
    id: int
    name: str
    price: float
    image: str
    description: str
    category: str
    ai_description: str = field(default="", compare=False)

    def text(self, with_photo_description: bool = False) -> str:
        """What the search index sees. The photo descriptions are spoken to shoppers but kept
        out of the index by default: on the dev queries they made ranking slightly worse."""
        parts = [self.name, self.description, self.category]
        if with_photo_description and self.ai_description:
            parts.append(self.ai_description)
        return ". ".join(parts)


def parse_dart(source: str) -> list[Product]:
    starts = [(m.start(), m.group(1)) for m in _CATEGORY.finditer(source)]
    out = []
    for i, (pos, category) in enumerate(starts):
        end = starts[i + 1][0] if i + 1 < len(starts) else len(source)
        for m in _PRODUCT.finditer(source, pos, end):
            out.append(Product(int(m.group(1)), m.group(2), float(m.group(3)), m.group(4), m.group(5), category))
    return out


@lru_cache(maxsize=1)
def load() -> tuple[Product, ...]:
    products = parse_dart(DART_CATALOG.read_text(encoding="utf-8"))
    ai = json.loads(DESCRIPTIONS.read_text(encoding="utf-8"))["descriptions"] if DESCRIPTIONS.exists() else {}
    return tuple(Product(**{**p.__dict__, "ai_description": ai.get(p.image, "")}) for p in products)


def by_id() -> dict[int, Product]:
    return {p.id: p for p in load()}


def categories() -> list[str]:
    return list(dict.fromkeys(p.category for p in load()))
