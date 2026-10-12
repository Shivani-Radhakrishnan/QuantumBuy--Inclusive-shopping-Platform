"""QuantumBuy ML service.

    uvicorn quantumbuy_ml.api:app --port 8080       # docs at /docs

    GET  /health
    GET  /search?q=...&k=10                 hybrid semantic + typo-tolerant search
    GET  /products/{id}/similar?k=5         content-based (embeddings)
    GET  /products/{id}/bought-together?k=5 co-purchase + content hybrid
    POST /voice/parse  {"text": "..."}      intent, product, quantity, category

Everything is built in memory at start-up (100 products: well under a second after the
embedding model is loaded).
"""
from __future__ import annotations

from contextlib import asynccontextmanager
from functools import lru_cache
from typing import Optional

import os

from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from quantumbuy_ml import __version__, catalog
from quantumbuy_ml.encoder import get_encoder
from quantumbuy_ml.recommend import Recommender
from quantumbuy_ml.search import ProductSearch
from quantumbuy_ml.sessions import simulate
from quantumbuy_ml.voice import VoiceParser



@asynccontextmanager
async def lifespan(_app):
    state()          # load the model and build the indexes before serving
    yield


app = FastAPI(title="QuantumBuy ML", version=__version__, lifespan=lifespan,
              description="Semantic product search, recommendations and voice-command understanding.")

# The Flutter web build calls the service from the browser. Allowed origins come from
# QUANTUMBUY_CORS (comma-separated); without it, only localhost pages may call it.
_origins = [o.strip() for o in os.environ.get("QUANTUMBUY_CORS", "").split(",") if o.strip()]
app.add_middleware(
    CORSMiddleware,
    allow_origins=_origins,
    allow_origin_regex=None if _origins else r"http://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_methods=["GET", "POST"],
    allow_headers=["Content-Type"],
)


class ProductOut(BaseModel):
    id: int
    name: str
    price: float
    category: str
    image: str
    score: Optional[float] = None


class ParseIn(BaseModel):
    text: str = Field(..., min_length=1, max_length=300, examples=["add the cheapest camera"])


class ParseOut(BaseModel):
    intent: str
    confidence: float
    product_id: Optional[int]
    product_name: Optional[str]
    quantity: int
    category: Optional[str]
    sort: Optional[str]
    query: str


@lru_cache(maxsize=1)
def state():
    products = list(catalog.load())
    enc = get_encoder()
    search = ProductSearch(products, enc)
    rec = Recommender(products, search.vectors, simulate(5000, seed=0, all_ids=[p.id for p in products]))
    return products, search, rec, VoiceParser.load(products, search, enc)


def _out(p, score=None) -> ProductOut:
    return ProductOut(id=p.id, name=p.name, price=p.price, category=p.category, image=p.image,
                      score=None if score is None else round(score, 4))


def _check(product_id: int):
    _, _, rec, _ = state()
    if product_id not in rec.index:
        raise HTTPException(404, f"no product {product_id}")


@app.get("/health")
def health() -> dict:
    products, *_ = state()
    return {"status": "ok", "version": __version__, "products": len(products)}


@app.get("/search", response_model=list[ProductOut])
def search(q: str = Query(..., min_length=1, max_length=200), k: int = Query(10, ge=1, le=50)) -> list[ProductOut]:
    _, engine, _, _ = state()
    return [_out(h.product, h.score) for h in engine.search(q, k)]


@app.get("/products/{product_id}/similar", response_model=list[ProductOut])
def similar(product_id: int, k: int = Query(5, ge=1, le=20)) -> list[ProductOut]:
    _check(product_id)
    return [_out(p) for p in state()[2].similar(product_id, k)]


@app.get("/products/{product_id}/bought-together", response_model=list[ProductOut])
def bought_together(product_id: int, k: int = Query(5, ge=1, le=20)) -> list[ProductOut]:
    _check(product_id)
    return [_out(p) for p in state()[2].recommend(product_id, k, "hybrid")]


@app.post("/voice/parse", response_model=ParseOut)
def parse(body: ParseIn) -> ParseOut:
    r = state()[3].parse(body.text).to_json()
    return ParseOut(**{k: r[k] for k in ParseOut.model_fields})
