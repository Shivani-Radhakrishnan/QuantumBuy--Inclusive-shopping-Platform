import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_app/data/product_catalog.dart';
import 'package:shopping_app/models/settings_model.dart';

import 'test_app.dart';

final laptop = const ProductRepository().allProducts.firstWhere((p) => p.name == 'Laptop');

Future<void> openLaptop(WidgetTester tester) async {
  navigatorOf(tester).pushNamed('/productDetail', arguments: laptop);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('high contrast switches to a high-contrast colour scheme', (tester) async {
    await pumpApp(tester, prefs: settingsPrefs(highContrast: true));
    final theme = Theme.of(tester.element(find.text('Categories')));
    expect(theme.colorScheme.surface, Colors.white);
    expect(theme.colorScheme.onSurface, Colors.black);

    await settingsOf(tester).toggleHighContrast(false);
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(find.text('Categories'))).colorScheme.surface, isNot(Colors.white));
  });

  testWidgets('text scaling multiplies the text scale factor', (tester) async {
    await pumpApp(tester);
    double scale() => MediaQuery.textScalerOf(tester.element(find.text('Categories'))).scale(10) / 10;
    expect(scale(), 1.0);
    await settingsOf(tester).toggleTextScaling(true);
    await tester.pumpAndSettle();
    expect(scale(), closeTo(SettingsModel.textScaleBoost, 0.001));
  });

  testWidgets('large text makes text styles bigger', (tester) async {
    await pumpApp(tester);
    double? bodySize() => Theme.of(tester.element(find.text('Categories'))).textTheme.bodyMedium!.fontSize;
    final normal = bodySize()!;
    await settingsOf(tester).toggleLargeText(true);
    await tester.pumpAndSettle();
    expect(bodySize(), closeTo(normal * 1.2, 0.01));
  });

  testWidgets('alt text: detailed image label and a visible caption', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester);
    await openLaptop(tester);
    expect(find.bySemanticsLabel('Photo of Laptop'), findsOneWidget);
    expect(find.byKey(const Key('altTextCaption')), findsNothing);

    await settingsOf(tester).toggleAltText(true);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Photo of Laptop. ${laptop.description}'), findsOneWidget);
    expect(find.byKey(const Key('altTextCaption')), findsOneWidget);
    handle.dispose();
  });

  testWidgets('simplified text shortens product descriptions', (tester) async {
    await pumpApp(tester);
    await openLaptop(tester);
    expect(find.text('High-performance laptop for gaming and work.'), findsOneWidget);

    await settingsOf(tester).toggleSimplifiedText(true);
    await tester.pumpAndSettle();
    expect(find.text('High-performance laptop.'), findsOneWidget);
    expect(find.text('High-performance laptop for gaming and work.'), findsNothing);
  });

  testWidgets('accessibility features read the product name and price aloud', (tester) async {
    final speaker = await pumpApp(tester, prefs: settingsPrefs(accessibility: true));
    await openLaptop(tester);
    expect(speaker.spoken, isNotEmpty);
    expect(speaker.spoken.first, startsWith('Laptop, 50000 rupees'));

    // Cart changes are announced too.
    await tester.tap(find.text('Add to cart'));
    await tester.pumpAndSettle();
    expect(speaker.spoken.last, 'Laptop added to cart');
  });

  testWidgets('nothing is read aloud when accessibility features are off', (tester) async {
    final speaker = await pumpApp(tester);
    await openLaptop(tester);
    expect(speaker.spoken, isEmpty);
    // ...unless the shopper asks for it.
    await tester.tap(find.byTooltip('Read product details aloud'));
    expect(speaker.spoken.single, startsWith('Laptop, 50000 rupees'));
  });

  testWidgets('voice control adds a microphone shortcut that opens voice ordering', (tester) async {
    await pumpApp(tester);
    expect(find.byTooltip('Voice order'), findsNothing);

    await settingsOf(tester).toggleVoiceControl(true);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Voice order'), findsOneWidget);

    await tester.tap(find.byTooltip('Voice order'));
    await tester.pumpAndSettle();
    expect(find.text('Voice Order'), findsOneWidget);
  });

  testWidgets('settings screen toggles are persisted', (tester) async {
    await pumpApp(tester, route: '/settings');
    await tester.tap(find.text('High contrast'));
    await tester.pumpAndSettle();
    expect(settingsOf(tester).isHighContrast, isTrue);
  });

  testWidgets('the survey turns on recommended settings', (tester) async {
    await pumpApp(tester, route: '/settings');
    await tester.scrollUntilVisible(find.text('Visual-impairment survey'), 100);
    await tester.tap(find.text('Visual-impairment survey'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complete Blindness'));
    await tester.tap(find.text('Save and apply'));
    await tester.pumpAndSettle();
    final settings = settingsOf(tester);
    expect(settings.isAccessibilityEnabled, isTrue);
    expect(settings.isVoiceControlEnabled, isTrue);
    expect(find.text('Your answer: Complete Blindness'), findsOneWidget);
  });
}
