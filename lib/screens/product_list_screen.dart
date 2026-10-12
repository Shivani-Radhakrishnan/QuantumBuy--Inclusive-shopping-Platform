import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/product_catalog.dart';
import '../models/product.dart';
import '../routes.dart';
import '../services/speaker.dart';
import '../widgets/product_description.dart';
import '../widgets/product_image.dart';
import '../widgets/quantity_stepper.dart';
import '../widgets/voice_shortcut_button.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final products = context.read<ProductRepository>().productsIn(category);
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        actions: [
          IconButton(
            tooltip: 'Cart',
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, Routes.cart),
          ),
        ],
      ),
      floatingActionButton: const VoiceShortcutButton(),
      body: products.isEmpty
          ? const Center(child: Text('No products in this category yet.'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
              itemCount: products.length,
              itemBuilder: (context, index) => _ProductTile(product: products[index]),
            ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: ProductImage(product: product, size: 56, circle: true),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatPrice(product.price),
              style: textTheme.bodyMedium?.copyWith(color: colors.primary, fontWeight: FontWeight.w600),
            ),
            ProductDescription(product, maxLines: 2, style: textTheme.bodySmall),
          ],
        ),
        trailing: QuantityStepper(product: product),
        onTap: () => Navigator.pushNamed(context, Routes.productDetail, arguments: product),
      ),
    );
  }
}
