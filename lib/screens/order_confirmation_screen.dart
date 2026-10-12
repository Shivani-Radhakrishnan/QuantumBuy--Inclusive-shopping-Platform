import 'package:flutter/material.dart';

import '../models/order.dart';
import '../routes.dart';
import '../services/speaker.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key, required this.order});

  final Order order;

  void _continueShopping(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, Routes.home, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      // Back goes home rather than to the (now empty) checkout.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _continueShopping(context);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Order placed'), automaticallyImplyLeading: false),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Icon(Icons.check_circle, size: 96, color: theme.colorScheme.primary, semanticLabel: 'Success'),
            const SizedBox(height: 16),
            Semantics(
              liveRegion: true,
              child: Text(
                'Thank you! Your order has been placed.',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 8),
            Text('Order ${order.reference}', textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
            const SizedBox(height: 24),
            for (final item in order.items)
              ListTile(
                title: Text(item.product.name),
                subtitle: Text('${item.quantity} x ${formatPrice(item.product.price)}'),
                trailing: Text(formatPrice(item.lineTotal)),
              ),
            const Divider(),
            ListTile(
              title: const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text(formatPrice(order.total), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(title: const Text('Payment'), trailing: Text(order.paymentMethod)),
            if (order.deliveryAddress != null)
              ListTile(title: const Text('Deliver to'), subtitle: Text(order.deliveryAddress!)),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton(
              onPressed: () => _continueShopping(context),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('Continue shopping'),
            ),
          ),
        ),
      ),
    );
  }
}
