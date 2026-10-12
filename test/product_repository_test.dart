import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_app/data/product_catalog.dart';

void main() {
  const repo = ProductRepository();

  test('has five categories with products', () {
    expect(repo.categories, hasLength(5));
    for (final category in repo.categories) {
      expect(repo.productsIn(category), isNotEmpty, reason: category);
    }
    expect(repo.productsIn('Nope'), isEmpty);
  });

  test('product ids are unique across categories (the cart keys on them)', () {
    final ids = repo.allProducts.map((p) => p.id).toList();
    expect(ids.toSet(), hasLength(ids.length));
  });

  test('product names are unique (voice ordering matches on them)', () {
    final names = repo.allProducts.map((p) => p.name.toLowerCase()).toList();
    expect(names.toSet(), hasLength(names.length));
  });

  test('every product image exists and is bundled', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final product in repo.allProducts) {
      expect(File(product.imageUrl).existsSync(), isTrue, reason: product.imageUrl);
      final folder = product.imageUrl.substring(0, product.imageUrl.lastIndexOf('/') + 1);
      expect(pubspec, contains('- $folder'), reason: '$folder must be listed under flutter: assets');
    }
  });

  test('lookups', () {
    final laptop = repo.allProducts.firstWhere((p) => p.name == 'Laptop');
    expect(repo.byId(laptop.id), laptop);
    expect(repo.categoryOf(laptop), 'Electronics');
    expect(repo.byId(-1), isNull);
  });
}
