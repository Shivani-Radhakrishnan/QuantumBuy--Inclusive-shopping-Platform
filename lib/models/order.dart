import 'package:flutter/foundation.dart';

import 'cart_model.dart';

/// A completed (demo) order. No payment is processed.
@immutable
class Order {
  const Order({
    required this.items,
    required this.total,
    required this.paymentMethod,
    required this.placedAt,
    this.deliveryAddress,
  });

  final List<CartItem> items;
  final double total;
  final String paymentMethod;
  final String? deliveryAddress;
  final DateTime placedAt;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// A short reference shown to the shopper, derived from the order time.
  String get reference => 'QB-${placedAt.millisecondsSinceEpoch.toRadixString(36).toUpperCase()}';
}
