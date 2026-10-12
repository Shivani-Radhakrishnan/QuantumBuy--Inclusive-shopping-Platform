import pytest

from quantumbuy_ml import catalog
from quantumbuy_ml.encoder import get_encoder
from quantumbuy_ml.search import ProductSearch


@pytest.fixture(scope="session")
def products():
    return list(catalog.load())


@pytest.fixture(scope="session")
def encoder():
    return get_encoder()


@pytest.fixture(scope="session")
def engine(products, encoder):
    return ProductSearch(products, encoder)
