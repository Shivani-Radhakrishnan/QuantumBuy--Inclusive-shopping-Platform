import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shopping_app/data/product_catalog.dart';
import 'package:shopping_app/routes.dart';
import 'package:shopping_app/services/ml_client.dart';

import 'test_app.dart';

/// An ML service that answers from [routes] (path -> JSON body); anything else is a 404.
MlClient fakeMl(Map<String, Object?> routes) => MlClient(
      baseUrl: 'http://ml.test',
      client: MockClient((req) async {
        final body = routes[req.url.path];
        return body == null ? http.Response('', 404) : http.Response(jsonEncode(body), 200);
      }),
    );

Map<String, Object?> intent(String name, {int? product, int quantity = 1, double confidence = 0.95, String query = ''}) =>
    {'intent': name, 'confidence': confidence, 'product_id': product, 'quantity': quantity, 'query': query};

const repo = ProductRepository();

Future<void> say(WidgetTester tester, FakeSpeech speech, String words) async {
  await tester.tap(find.byTooltip('Start listening'));
  await tester.pump();
  speech.hear(words);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the voice model can remove items, which the rule parser cannot', (tester) async {
    final speech = FakeSpeech();
    final speaker = await pumpApp(tester, route: Routes.voiceOrder, speech: speech,
        ml: fakeMl({'/voice/parse': intent('remove', product: 102)}));
    cartOf(tester).addItem(repo.byId(102)!, quantity: 2);
    await say(tester, speech, 'remove the laptop');
    expect(cartOf(tester).quantityOf(repo.byId(102)!), 0);
    expect(speaker.spoken.last, 'Removed Laptop from your cart.');
  });

  testWidgets('"cheapest camera" adds the product the model resolved', (tester) async {
    final speech = FakeSpeech();
    await pumpApp(tester, route: Routes.voiceOrder, speech: speech,
        ml: fakeMl({'/voice/parse': intent('add', product: 115)}));
    await say(tester, speech, 'add the cheapest camera');
    expect(cartOf(tester).quantityOf(repo.byId(115)!), 1);
  });

  testWidgets('low-confidence or failed model answers fall back to the rule parser', (tester) async {
    final speech = FakeSpeech();
    await pumpApp(tester, route: Routes.voiceOrder, speech: speech,
        ml: fakeMl({'/voice/parse': intent('help', confidence: 0.2)}));
    await say(tester, speech, 'order two laptops');
    expect(cartOf(tester).quantityOf(repo.byId(102)!), 2);
  });

  testWidgets('checkout by voice needs something in the cart', (tester) async {
    final speech = FakeSpeech();
    final speaker = await pumpApp(tester, route: Routes.voiceOrder, speech: speech,
        ml: fakeMl({'/voice/parse': intent('checkout')}));
    await say(tester, speech, 'check out');
    expect(speaker.spoken.last, 'Your cart is empty. Add something first.');
  });

  testWidgets('search shows the service results, or falls back to keywords', (tester) async {
    await pumpApp(tester, route: Routes.search, ml: fakeMl({'/search': [{'id': 216}, {'id': 208}]}));
    await tester.enterText(find.byKey(const Key('searchField')), 'keep my hands warm');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('Gloves'), findsOneWidget);
    expect(find.textContaining('2 results for "keep my hands warm"'), findsOneWidget);
    expect(find.textContaining('keyword search'), findsNothing);
  });

  testWidgets('without the service, search uses on-device keywords and says so', (tester) async {
    await pumpApp(tester, route: Routes.search);
    await tester.enterText(find.byKey(const Key('searchField')), 'blendr');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('Blender'), findsOneWidget);
    expect(find.textContaining('keyword search; smart search is unavailable'), findsOneWidget);
  });

  testWidgets('product page shows the photo description and recommendations', (tester) async {
    await pumpApp(tester, ml: fakeMl({
      '/products/308/similar': [{'id': 309}, {'id': 307}],
      '/products/308/bought-together': [{'id': 514}],
    }));
    navigatorOf(tester).pushNamed(Routes.productDetail, arguments: repo.byId(308));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('photoDescription')), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Often bought together'), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('Similar items'), findsOneWidget);
    expect(find.text('Electric Kettle'), findsOneWidget);
    expect(find.text('Coffee'), findsOneWidget);
  });

  testWidgets('without the service, similar items come from the same category', (tester) async {
    await pumpApp(tester);
    navigatorOf(tester).pushNamed(Routes.productDetail, arguments: repo.byId(308));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Similar items'), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('Often bought together'), findsNothing);
  });
}
