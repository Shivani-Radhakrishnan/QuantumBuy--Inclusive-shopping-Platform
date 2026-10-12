import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shopping_app/services/ml_client.dart';

void main() {
  test('disabled without an address, and makes no request', () async {
    var calls = 0;
    final ml = MlClient(baseUrl: '', client: MockClient((_) async {
      calls++;
      return http.Response('[]', 200);
    }));
    expect(ml.enabled, isFalse);
    expect(await ml.search('tv'), isNull);
    expect(await ml.parseVoice('help'), isNull);
    expect(calls, 0);
  });

  test('search returns product ids in order', () async {
    final ml = MlClient(
      baseUrl: 'http://ml.test/',
      client: MockClient((req) async {
        expect(req.url.toString(), 'http://ml.test/search?q=warm+gloves&k=10');
        return http.Response(jsonEncode([{'id': 216}, {'id': 208}]), 200);
      }),
    );
    expect(await ml.search('warm gloves'), [216, 208]);
  });

  test('server errors, bad JSON and timeouts all become null', () async {
    final error = MlClient(baseUrl: 'http://ml.test', client: MockClient((_) async => http.Response('oops', 500)));
    final junk = MlClient(baseUrl: 'http://ml.test', client: MockClient((_) async => http.Response('not json', 200)));
    final slow = MlClient(
      baseUrl: 'http://ml.test',
      timeout: const Duration(milliseconds: 10),
      client: MockClient((_) => Completer<http.Response>().future),
    );
    expect(await error.similar(101), isNull);
    expect(await junk.boughtTogether(101), isNull);
    expect(await slow.search('tv'), isNull);
  });

  test('voice parse posts the text and reads the intent', () async {
    final ml = MlClient(
      baseUrl: 'http://ml.test',
      client: MockClient((req) async {
        expect(req.method, 'POST');
        expect(jsonDecode(req.body), {'text': 'add two laptops'});
        return http.Response(
            jsonEncode({'intent': 'add', 'confidence': 0.97, 'product_id': 102, 'quantity': 2, 'query': ''}), 200);
      }),
    );
    final v = (await ml.parseVoice('add two laptops'))!;
    expect((v.intent, v.productId, v.quantity, v.confidence), ('add', 102, 2, 0.97));
  });
}
