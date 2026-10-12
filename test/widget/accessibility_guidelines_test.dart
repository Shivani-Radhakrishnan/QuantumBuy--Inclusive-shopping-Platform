import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_app/data/product_catalog.dart';

import 'test_app.dart';

/// Checks a screen against Flutter's built-in accessibility guidelines:
/// 48x48dp tap targets (Android), labels on every tappable element, and
/// WCAG text contrast.
Future<void> expectAccessible(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}

void main() {
  final laptop = const ProductRepository().allProducts.firstWhere((p) => p.name == 'Laptop');

  final screens = <String, Future<void> Function(WidgetTester)>{
    'login': (t) => pumpApp(t, route: '/login'),
    'register': (t) => pumpApp(t, route: '/register'),
    'home': (t) => pumpApp(t, route: '/home'),
    'categories': (t) => pumpApp(t, route: '/categories'),
    'product list': (t) async {
      await pumpApp(t, route: '/categories');
      navigatorOf(t).pushNamed('/productList', arguments: 'Electronics');
      await t.pumpAndSettle();
    },
    'product detail': (t) async {
      await pumpApp(t);
      navigatorOf(t).pushNamed('/productDetail', arguments: laptop);
      await t.pumpAndSettle();
    },
    'cart with items': (t) async {
      await pumpApp(t, route: '/cart');
      cartOf(t).addItem(laptop);
      await t.pumpAndSettle();
    },
    'checkout': (t) async {
      await pumpApp(t, route: '/cart');
      cartOf(t).addItem(laptop);
      navigatorOf(t).pushNamed('/checkout');
      await t.pumpAndSettle();
    },
    'voice order': (t) => pumpApp(t, route: '/voiceOrder'),
    'settings': (t) => pumpApp(t, route: '/settings'),
    'impairment survey': (t) => pumpApp(t, route: '/impairment'),
    'profile': (t) => pumpApp(t, route: '/profile'),
  };

  for (final entry in screens.entries) {
    testWidgets('${entry.key} screen meets accessibility guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await entry.value(tester);
      await expectAccessible(tester);
      handle.dispose();
    });
  }

  testWidgets('home meets guidelines in high contrast + dark mode', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester, prefs: settingsPrefs(highContrast: true, darkMode: true, voiceControl: true));
    await expectAccessible(tester);
    handle.dispose();
  });

  testWidgets('product list meets guidelines with large, scaled text', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester, prefs: settingsPrefs(largeText: true, textScaling: true));
    navigatorOf(tester).pushNamed('/productList', arguments: 'Groceries and Gourmet Food');
    await tester.pumpAndSettle();
    await expectAccessible(tester);
    handle.dispose();
  });

  testWidgets('icon-only buttons have spoken labels', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester);
    for (final name in ['Profile', 'Settings']) {
      expect(tester.getSemantics(find.byTooltip(name)), containsSemantics(tooltip: name, isButton: true));
    }

    navigatorOf(tester).pushNamed('/productList', arguments: 'Electronics');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add Laptop to cart'));
    await tester.pumpAndSettle();
    expect(tester.getSemantics(find.byTooltip('Remove one Laptop')),
        containsSemantics(tooltip: 'Remove one Laptop', isButton: true));
    expect(find.bySemanticsLabel(RegExp('1 in cart')), findsOneWidget);
    handle.dispose();
  });
}
