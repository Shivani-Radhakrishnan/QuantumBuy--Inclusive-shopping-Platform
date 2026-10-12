import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_app/data/product_catalog.dart';
import 'package:shopping_app/services/local_search.dart';

void main() {
  final products = const ProductRepository().allProducts;
  List<String> names(String q) => [for (final p in localSearch(q, products, limit: 3)) p.name];

  test('finds names, plurals and one-letter typos', () {
    expect(names('rice cooker').first, 'Rice Cooker');
    expect(names('laptops').first, 'Laptop');
    expect(names('blendr').first, 'Blender');
  });

  test('falls back to description words and ignores empty queries', () {
    expect(names('waterproof'), contains('Raincoat'));
    expect(localSearch('  ', products), isEmpty);
    expect(localSearch('zzzz', products), isEmpty);
  });
}
