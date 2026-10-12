import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_app/models/cart_model.dart';
import 'package:shopping_app/models/product.dart';

const laptop = Product(id: 1, name: 'Laptop', imageUrl: 'a.jpg', price: 50000, description: 'd');
const rice = Product(id: 2, name: 'Rice', imageUrl: 'b.jpg', price: 120.5, description: 'd');

void main() {
  late CartModel cart;
  var notifications = 0;

  setUp(() {
    cart = CartModel();
    notifications = 0;
    cart.addListener(() => notifications++);
  });

  test('starts empty', () {
    expect(cart.isEmpty, isTrue);
    expect(cart.totalCost, 0);
    expect(cart.totalQuantity, 0);
  });

  test('adding the same product increases its quantity', () {
    cart.addItem(laptop);
    cart.addItem(laptop);
    cart.addItem(rice, quantity: 3);
    expect(cart.items, hasLength(2));
    expect(cart.quantityOf(laptop), 2);
    expect(cart.quantityOf(rice), 3);
    expect(cart.totalQuantity, 5);
    expect(notifications, 3);
  });

  test('total counts every unit', () {
    cart.addItem(laptop, quantity: 2);
    cart.addItem(rice, quantity: 2);
    expect(cart.totalCost, 2 * 50000 + 2 * 120.5);
    expect(cart.items.first.lineTotal, 100000);
  });

  test('removing goes one unit at a time, then drops the line', () {
    cart.addItem(laptop, quantity: 2);
    cart.removeItem(laptop);
    expect(cart.quantityOf(laptop), 1);
    cart.removeItem(laptop);
    expect(cart.isEmpty, isTrue);
    cart.removeItem(laptop); // no-op, no notification
    expect(notifications, 3);
  });

  test('removeAll drops the whole line', () {
    cart.addItem(laptop, quantity: 4);
    cart.addItem(rice);
    cart.removeAll(laptop);
    expect(cart.quantityOf(laptop), 0);
    expect(cart.quantityOf(rice), 1);
  });

  test('rejects non-positive quantities', () {
    expect(() => cart.addItem(laptop, quantity: 0), throwsArgumentError);
  });

  test('items are read-only', () {
    cart.addItem(laptop);
    expect(() => cart.items.clear(), throwsUnsupportedError);
  });

  test('placing an order snapshots the cart and empties it', () {
    cart.addItem(laptop);
    cart.addItem(rice, quantity: 2);
    final order = cart.placeOrder(paymentMethod: 'UPI', deliveryAddress: '1 Main Street', now: DateTime(2026, 1, 2));
    expect(order.total, 50000 + 241);
    expect(order.itemCount, 3);
    expect(order.items, hasLength(2));
    expect(order.paymentMethod, 'UPI');
    expect(order.reference, startsWith('QB-'));
    expect(cart.isEmpty, isTrue);
  });

  test('an empty cart cannot be ordered', () {
    expect(() => cart.placeOrder(paymentMethod: 'UPI'), throwsStateError);
  });
}
