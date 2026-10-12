import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_model.dart';
import '../routes.dart';
import '../services/speaker.dart';
import '../widgets/product_description.dart';
import '../widgets/product_image.dart';
import '../widgets/quantity_stepper.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          if (!cart.isEmpty)
            IconButton(
              tooltip: 'Empty cart',
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _confirmClear(context),
            ),
        ],
      ),
      body: cart.isEmpty
          ? _EmptyCart(onBrowse: () => Navigator.pushNamed(context, Routes.categories))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: cart.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProductImage(product: item.product, size: 80),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.product.name, style: theme.textTheme.titleMedium),
                              const SizedBox(height: 4),
                              ProductDescription(item.product, maxLines: 2, style: theme.textTheme.bodySmall),
                              const SizedBox(height: 4),
                              Text(
                                '${item.quantity} x ${formatPrice(item.product.price)} = ${formatPrice(item.lineTotal)}',
                                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
                              ),
                            ],
                          ),
                        ),
                        QuantityStepper(product: item.product),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total: ${formatPrice(cart.totalCost)}',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pushNamed(context, Routes.checkout),
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                      child: const Text('Checkout'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final cart = context.read<CartModel>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Empty cart?'),
        content: const Text('This removes every item from your cart.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Empty cart')),
        ],
      ),
    );
    if (confirmed == true) cart.clearCart();
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_cart_outlined, size: 72),
            const SizedBox(height: 12),
            Text('Your cart is empty', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            FilledButton(onPressed: onBrowse, child: const Text('Browse categories')),
          ],
        ),
      ),
    );
  }
}
