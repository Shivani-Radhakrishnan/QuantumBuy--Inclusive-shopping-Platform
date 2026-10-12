import pytest

from quantumbuy_ml.voice import VoiceParser, normalise


@pytest.fixture(scope="module")
def parser(products, engine, encoder):
    return VoiceParser.load(products, engine, encoder)


def test_normalise_numbers_and_asr_to():
    assert normalise("Add TWO laptops!") == ["add", "2", "laptops"]
    assert normalise("add to t-shirts") == ["add", "2", "t", "shirts"]
    assert normalise("take me to the cart") == ["take", "me", "to", "the", "cart"]


@pytest.mark.parametrize("text,intent,product,qty", [
    ("add three bags of rice", "add", 501, 3),
    ("order the most expensive camera", "add", 112, 1),
    ("add the cheapest camera", "add", 115, 1),
    ("remove the coffee maker", "remove", 308, 1),
    ("tell me about the electric kettle", "describe", 309, 1),
    ("add a fridge", "add", 304, 1),
])
def test_product_commands(parser, text, intent, product, qty):
    p = parser.parse(text)
    assert (p.intent, p.product.id if p.product else None, p.quantity) == (intent, product, qty)


@pytest.mark.parametrize("text,intent", [
    ("open my cart", "open_cart"), ("go to checkout", "checkout"), ("help", "help"),
    ("find something for oily skin", "search"),
])
def test_other_intents(parser, text, intent):
    assert parser.parse(text).intent == intent


def test_category(parser):
    p = parser.parse("show me the groceries")
    assert p.intent == "open_category" and p.category == "Groceries and Gourmet Food"


def test_the_two_is_not_a_quantity(parser):
    assert parser.parse("add the cheaper of the two mixers").quantity == 1
