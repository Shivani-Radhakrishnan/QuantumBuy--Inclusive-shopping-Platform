import 'package:flutter/foundation.dart';

import 'order.dart';
import 'product.dart';

/// One line in the cart: a product and how many of it.
@immutable
class CartItem {
  const CartItem(this.product, this.quantity);

  final Product product;
  final int quantity;

  double get lineTotal => product.price * quantity;
}

/// The shopping cart. Quantities are tracked per product id.
class CartModel extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  /// Cart lines in the order they were first added.
  List<CartItem> get items => List.unmodifiable(_items.values);

  bool get isEmpty => _items.isEmpty;

  /// Total number of units across all lines.
  int get totalQuantity => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalCost => _items.values.fold(0.0, (sum, item) => sum + item.lineTotal);

  int quantityOf(Product product) => _items[product.id]?.quantity ?? 0;

  /// Adds [quantity] units of [product] (default one).
  void addItem(Product product, {int quantity = 1}) {
    if (quantity <= 0) throw ArgumentError.value(quantity, 'quantity', 'must be positive');
    final current = quantityOf(product);
    _items[product.id] = CartItem(product, current + quantity);
    notifyListeners();
  }

  /// Removes one unit of [product]; the line goes when it reaches zero.
  void removeItem(Product product) {
    final current = quantityOf(product);
    if (current == 0) return;
    if (current == 1) {
      _items.remove(product.id);
    } else {
      _items[product.id] = CartItem(product, current - 1);
    }
    notifyListeners();
  }

  /// Removes the whole line for [product].
  void removeAll(Product product) {
    if (_items.remove(product.id) != null) notifyListeners();
  }

  void clearCart() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }

  /// Turns the cart into an [Order] and empties it.
  ///
  /// Throws a [StateError] if the cart is empty.
  Order placeOrder({required String paymentMethod, String? deliveryAddress, DateTime? now}) {
    if (_items.isEmpty) throw StateError('Cannot place an order with an empty cart');
    final order = Order(
      items: items,
      total: totalCost,
      paymentMethod: paymentMethod,
      deliveryAddress: deliveryAddress,
      placedAt: now ?? DateTime.now(),
    );
    clearCart();
    return order;
  }
}
