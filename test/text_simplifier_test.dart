import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_app/data/product_catalog.dart';
import 'package:shopping_app/services/text_simplifier.dart';

void main() {
  test('drops the qualifying clause', () {
    expect(simplifyDescription('High-performance laptop for gaming and work.'), 'High-performance laptop.');
    expect(simplifyDescription('Ultra HD Smart TV with multiple streaming apps.'), 'Ultra HD Smart TV.');
    expect(simplifyDescription('Portable Bluetooth speaker with powerful sound.'), 'Portable Bluetooth speaker.');
  });

  test('keeps only the first sentence', () {
    expect(simplifyDescription('Soft cotton. Machine washable. Ten colours.'), 'Soft cotton.');
  });

  test('caps the length', () {
    expect(simplifyDescription('one two three four five six seven eight nine'), 'one two three four five six.');
  });

  test('never leaves a single dangling word when a clause would remove everything', () {
    expect(simplifyDescription('Tea for everyone.'), 'Tea for everyone.');
  });

  test('handles empty text', () {
    expect(simplifyDescription(''), '');
  });

  test('every catalogue description gets shorter or stays the same, and is never empty', () {
    for (final product in const ProductRepository().allProducts) {
      final simple = simplifyDescription(product.description);
      expect(simple.length, lessThanOrEqualTo(product.description.length + 1), reason: product.name);
      expect(simple.replaceAll('.', '').trim(), isNotEmpty, reason: product.name);
    }
  });
}
