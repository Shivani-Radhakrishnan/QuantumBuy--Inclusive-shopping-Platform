import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_app/data/product_catalog.dart';

import 'test_app.dart';

void main() {
  testWidgets('a spoken order adds the product and confirms it aloud', (tester) async {
    final speech = FakeSpeech();
    final speaker = await pumpApp(tester, route: '/voiceOrder', speech: speech);

    await tester.tap(find.byTooltip('Start listening'));
    await tester.pumpAndSettle();
    expect(speech.listening, isTrue);

    speech.hear('order two laptops');
    await tester.pumpAndSettle();

    final laptop = const ProductRepository().allProducts.firstWhere((p) => p.name == 'Laptop');
    expect(cartOf(tester).quantityOf(laptop), 2);
    expect(speaker.spoken.last, 'Added 2 Laptop to your cart.');
    expect(find.text('Added 2 Laptop to your cart.'), findsOneWidget);
  });

  testWidgets('a spoken category opens it', (tester) async {
    final speech = FakeSpeech();
    await pumpApp(tester, route: '/voiceOrder', speech: speech);
    await tester.tap(find.byTooltip('Start listening'));
    await tester.pump();
    speech.hear('show me groceries');
    await tester.pumpAndSettle();
    expect(find.text('Groceries and Gourmet Food'), findsOneWidget);
    expect(find.text('Rice'), findsOneWidget);
  });

  testWidgets('typed commands work without a microphone', (tester) async {
    final speaker = await pumpApp(tester, route: '/voiceOrder');
    await tester.enterText(find.byKey(const Key('typedCommandField')), 'add honey');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();
    expect(cartOf(tester).totalQuantity, 1);
    expect(speaker.spoken.last, 'Added Honey to your cart.');
  });

  testWidgets('unknown phrases are explained, nothing is added', (tester) async {
    final speech = FakeSpeech();
    final speaker = await pumpApp(tester, route: '/voiceOrder', speech: speech);
    await tester.tap(find.byTooltip('Start listening'));
    await tester.pump();
    speech.hear('order a spaceship');
    await tester.pumpAndSettle();
    expect(cartOf(tester).isEmpty, isTrue);
    expect(speaker.spoken.last, startsWith('Sorry, I could not find'));
  });

  testWidgets('denied microphone permission shows a helpful message', (tester) async {
    await pumpApp(tester, route: '/voiceOrder', speech: FakeSpeech(available: false));
    await tester.tap(find.byTooltip('Start listening'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Speech recognition is not available'), findsOneWidget);
  });
}
