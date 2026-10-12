import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_app/data/product_catalog.dart';
import 'package:shopping_app/services/voice_command.dart';

const repo = ProductRepository();

VoiceCommand parse(String phrase) =>
    parseVoiceCommand(phrase, products: repo.allProducts, categories: repo.categories);

void expectAdd(String phrase, String product, [int quantity = 1]) {
  final command = parse(phrase);
  expect(command, isA<AddProductCommand>(), reason: phrase);
  command as AddProductCommand;
  expect(command.product.name, product, reason: phrase);
  expect(command.quantity, quantity, reason: phrase);
}

void expectOpen(String phrase, String category) {
  final command = parse(phrase);
  expect(command, isA<OpenCategoryCommand>(), reason: phrase);
  expect((command as OpenCategoryCommand).category, category, reason: phrase);
}

void main() {
  group('ordering products', () {
    test('matches any catalogue product, case-insensitively', () {
      expectAdd('order laptop', 'Laptop');
      expectAdd('ORDER RICE', 'Rice');
      expectAdd('Add Olive Oil', 'Olive Oil');
      expectAdd('i want a bluetooth speaker please', 'Bluetooth Speaker');
      expectAdd('buy face cream', 'Face Cream');
    });

    test('a product name on its own adds it', () {
      expectAdd('honey', 'Honey');
    });

    test('prefers the longest matching name', () {
      expectAdd('order rice cooker', 'Rice Cooker');
      expectAdd('order rice', 'Rice');
      expectAdd('add a coffee maker', 'Coffee Maker');
      expectAdd('add coffee', 'Coffee');
      expectAdd('buy digital camera', 'Digital Camera');
      expectAdd('order stand mixer', 'Stand Mixer');
    });

    test('tolerates plurals and small recognition errors', () {
      expectAdd('order two laptops', 'Laptop', 2);
      expectAdd('add watches', 'Watch');
      expectAdd('order headphone', 'Headphones');
      expectAdd('order refrigirator', 'Refrigerator');
      expectAdd('buy a smart watch', 'Smartwatch');
      expectAdd('add a t shirt', 'T-shirt');
      expectAdd('add tshirt', 'T-shirt');
    });

    test('short names must match exactly', () {
      expectAdd('add tea', 'Tea');
      expectAdd('add tie', 'Tie');
    });

    test('reads the quantity just before the product', () {
      expectAdd('order 3 sugar', 'Sugar', 3);
      expectAdd('add five bread', 'Bread', 5);
      expectAdd('add a milk', 'Milk', 1);
      expectAdd('i want to buy laptop', 'Laptop', 1);
    });

    test('"add X to cart" adds X rather than opening the cart', () {
      expectAdd('add honey to my cart', 'Honey');
    });
  });

  group('opening categories', () {
    test('by name or common alias', () {
      expectOpen('open electronics', 'Electronics');
      expectOpen('show me clothes', 'Clothing and Accessories');
      expectOpen('open groceries', 'Groceries and Gourmet Food');
      expectOpen('go to kitchen', 'Home and Kitchen');
      expectOpen('browse beauty', 'Beauty and Personal Care');
      expectOpen('Personal care', 'Beauty and Personal Care');
    });

    test('an open verb beats a product match', () {
      expectOpen('open home and kitchen', 'Home and Kitchen');
    });

    test('ordering a product inside a category name still orders it', () {
      expectAdd('order home theater system', 'Home Theater System');
    });
  });

  test('opens the cart', () {
    expect(parse('open my cart'), isA<OpenCartCommand>());
    expect(parse('go to checkout'), isA<OpenCartCommand>());
  });

  test('unknown phrases are reported, not guessed', () {
    expect(parse('what is the weather'), isA<UnknownCommand>());
    expect(parse(''), isA<UnknownCommand>());
    expect(parse('order a spaceship'), isA<UnknownCommand>());
  });

  test('confirmation sentences', () {
    final laptop = repo.allProducts.firstWhere((p) => p.name == 'Laptop');
    expect(confirmationFor(AddProductCommand(laptop, 1)), 'Added Laptop to your cart.');
    expect(confirmationFor(AddProductCommand(laptop, 2)), 'Added 2 Laptop to your cart.');
    expect(confirmationFor(const OpenCategoryCommand('Electronics')), 'Opening Electronics.');
    expect(confirmationFor(const OpenCartCommand()), 'Opening your cart.');
  });

  test('levenshtein', () {
    expect(levenshtein('kitten', 'sitting'), 3);
    expect(levenshtein('', 'abc'), 3);
    expect(levenshtein('same', 'same'), 0);
  });
}
