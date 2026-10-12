import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_app.dart';

Future<void> fill(WidgetTester tester, String key, String text) async {
  final field = find.byKey(Key(key));
  await tester.scrollUntilVisible(field, 100, scrollable: find.byType(Scrollable).first);
  await tester.enterText(field, text);
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 100, scrollable: find.byType(Scrollable).first);
  await tester.tap(finder);
}

void main() {
  testWidgets('browse, add to cart, check out with validation, see confirmation', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await pumpApp(tester);

    // Home -> Categories -> Electronics
    await tester.tap(find.text('Categories'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Electronics'));
    await tester.pumpAndSettle();

    // Add two laptops and one smartphone.
    await tester.tap(find.byTooltip('Add Laptop to cart'));
    await tester.pump();
    await tester.tap(find.byTooltip('Add Laptop to cart'));
    await tester.pump();
    await tester.tap(find.byTooltip('Add Smartphone to cart'));
    await tester.pump();
    expect(cartOf(tester).totalQuantity, 3);

    // Removing one laptop.
    await tester.tap(find.byTooltip('Remove one Laptop'));
    await tester.pump();
    expect(cartOf(tester).totalQuantity, 2);
    await tester.tap(find.byTooltip('Add Laptop to cart'));
    await tester.pump();

    // Cart shows the right total: 2 x 50,000 + 10,000.
    await tester.tap(find.byTooltip('Cart'));
    await tester.pumpAndSettle();
    expect(find.text('Total: ₹110000.00'), findsOneWidget);
    expect(find.text('2 x ₹50000.00 = ₹100000.00'), findsOneWidget);

    await tester.tap(find.text('Checkout'));
    await tester.pumpAndSettle();

    // Submitting an empty form shows errors and does not place the order.
    await tester.tap(find.byKey(const Key('placeOrderButton')));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a delivery address'), findsOneWidget);
    expect(find.text('Please enter your UPI ID'), findsOneWidget);
    expect(cartOf(tester).isEmpty, isFalse);

    // Invalid card details are rejected too.
    await tapVisible(tester, find.text('Credit/Debit Card'));
    await tester.pumpAndSettle();
    await fill(tester, 'cardNumberField', '4111 1111 1111 1112');
    await fill(tester, 'expiryField', '01/20');
    await fill(tester, 'cvvField', '12');
    await tester.tap(find.byKey(const Key('placeOrderButton')));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid card number'), findsOneWidget);
    expect(find.text('This card has expired'), findsOneWidget);
    expect(find.text('CVV is 3 or 4 digits'), findsOneWidget);

    // Valid UPI payment goes through.
    await tapVisible(tester, find.text('UPI'));
    await tester.pumpAndSettle();
    await fill(tester, 'addressField', '12 Example Street, Chennai 600001');
    await fill(tester, 'upiField', 'shopper@okbank');
    await tester.tap(find.byKey(const Key('placeOrderButton')));
    await tester.pumpAndSettle();

    expect(find.text('Thank you! Your order has been placed.'), findsOneWidget);
    expect(find.text('₹110000.00'), findsWidgets);
    expect(cartOf(tester).isEmpty, isTrue, reason: 'the cart is cleared after ordering');

    // Back from the confirmation goes home, not to the empty checkout.
    await tester.tap(find.text('Continue shopping'));
    await tester.pumpAndSettle();
    expect(find.text('QuantumBuy'), findsOneWidget);
    expect(navigatorOf(tester).canPop(), isFalse);
  });

  testWidgets('checkout with an empty cart explains why and offers browsing', (tester) async {
    await pumpApp(tester, route: '/checkout');
    expect(find.text('Your cart is empty, so there is nothing to check out.'), findsOneWidget);
    expect(find.text('Browse categories'), findsOneWidget);
  });

  testWidgets('empty cart screen', (tester) async {
    await pumpApp(tester, route: '/cart');
    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.text('Checkout'), findsNothing);
  });
}
