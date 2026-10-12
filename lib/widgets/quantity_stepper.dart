import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_model.dart';
import '../models/product.dart';
import '../models/settings_model.dart';
import '../services/speaker.dart';

/// Add / remove buttons for one product, with the quantity in between.
///
/// Both buttons have labels for screen readers ("Add Laptop to cart") and
/// 48dp tap targets. With accessibility features on, the change is spoken.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({super.key, required this.product, this.showRemoveWhenEmpty = false});

  final Product product;
  final bool showRemoveWhenEmpty;

  void _announce(BuildContext context, String message) {
    if (context.read<SettingsModel>().speaksProductDetails) {
      context.read<Speaker>().speak(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final quantity = context.select<CartModel, int>((cart) => cart.quantityOf(product));
    final cart = context.read<CartModel>();
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (quantity > 0 || showRemoveWhenEmpty) ...[
          IconButton(
            tooltip: 'Remove one ${product.name}',
            icon: Icon(Icons.remove_circle_outline, color: colors.error),
            onPressed: quantity == 0
                ? null
                : () {
                    cart.removeItem(product);
                    final left = quantity - 1;
                    _announce(context, left == 0 ? 'Removed ${product.name}' : '${product.name}, $left in cart');
                  },
          ),
          Semantics(
            label: '$quantity in cart',
            excludeSemantics: true,
            child: SizedBox(
              width: 28,
              child: Text('$quantity', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
            ),
          ),
        ],
        IconButton(
          tooltip: 'Add ${product.name} to cart',
          icon: Icon(Icons.add_circle_outline, color: colors.primary),
          onPressed: () {
            cart.addItem(product);
            _announce(context, 'Added ${product.name}, ${quantity + 1} in cart');
          },
        ),
      ],
    );
  }
}
