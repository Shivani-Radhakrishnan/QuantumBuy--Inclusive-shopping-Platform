from fastapi.testclient import TestClient

from quantumbuy_ml.api import app

client = TestClient(app)


def test_health():
    assert client.get("/health").json()["products"] == 100


def test_search_and_validation():
    hits = client.get("/search", params={"q": "washing machine", "k": 3}).json()
    assert hits[0]["name"] == "Washing Machine" and len(hits) == 3 and hits[0]["score"] >= hits[1]["score"]
    assert client.get("/search", params={"q": ""}).status_code == 422
    assert client.get("/search", params={"q": "tv", "k": 500}).status_code == 422


def test_recommendations():
    sim = client.get("/products/308/similar").json()
    assert len(sim) == 5 and all(p["id"] != 308 for p in sim)
    assert len(client.get("/products/308/bought-together", params={"k": 3}).json()) == 3
    assert client.get("/products/999/similar").status_code == 404


def test_voice_parse():
    r = client.post("/voice/parse", json={"text": "add two laptops"}).json()
    assert (r["intent"], r["product_id"], r["quantity"]) == ("add", 102, 2)
    assert client.post("/voice/parse", json={"text": ""}).status_code == 422
