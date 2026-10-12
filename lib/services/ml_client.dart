import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// What the ML service understood from a voice command.
class VoiceIntent {
  const VoiceIntent({
    required this.intent,
    required this.confidence,
    this.productId,
    this.quantity = 1,
    this.category,
    this.query = '',
  });

  factory VoiceIntent.fromJson(Map<String, dynamic> json) => VoiceIntent(
        intent: json['intent'] as String,
        confidence: (json['confidence'] as num).toDouble(),
        productId: (json['product_id'] as num?)?.toInt(),
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        category: json['category'] as String?,
        query: json['query'] as String? ?? '',
      );

  /// add, remove, open_category, open_cart, checkout, search, describe or help.
  final String intent;
  final double confidence;
  final int? productId;
  final int quantity;
  final String? category;
  final String query;
}

/// Client for the QuantumBuy ML service (ml/ in this repo): semantic search,
/// recommendations and voice-command understanding.
///
/// Every call returns null when the service is not configured, unreachable,
/// slow or returns an error, and callers fall back to the on-device features.
/// The address comes from `--dart-define=ML_URL=http://host:8080`; without it
/// the client is disabled and the app works exactly as before.
class MlClient {
  MlClient({String? baseUrl, http.Client? client, this.timeout = const Duration(seconds: 3)})
      : baseUrl = (baseUrl ?? const String.fromEnvironment('ML_URL')).replaceAll(RegExp(r'/+$'), ''),
        _injected = client;

  final String baseUrl;
  final Duration timeout;
  final http.Client? _injected;
  late final http.Client _client = _injected ?? http.Client(); // created only when first used

  bool get enabled => baseUrl.isNotEmpty;

  Future<Object?> _send(Future<http.Response> Function(Uri uri) request, String path,
      [Map<String, String>? query]) async {
    if (!enabled) return null;
    try {
      final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
      final response = await request(uri).timeout(timeout);
      if (response.statusCode != 200) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      return null; // offline, timeout, bad JSON: use the fallback
    }
  }

  List<int>? _ids(Object? body) =>
      body is List ? [for (final item in body) ((item as Map)['id'] as num).toInt()] : null;

  /// Product ids, best match first.
  Future<List<int>?> search(String query, {int limit = 10}) async =>
      _ids(await _send(_client.get, '/search', {'q': query, 'k': '$limit'}));

  Future<List<int>?> similar(int productId, {int limit = 5}) async =>
      _ids(await _send(_client.get, '/products/$productId/similar', {'k': '$limit'}));

  Future<List<int>?> boughtTogether(int productId, {int limit = 5}) async =>
      _ids(await _send(_client.get, '/products/$productId/bought-together', {'k': '$limit'}));

  Future<VoiceIntent?> parseVoice(String text) async {
    final body = await _send(
      (uri) => _client.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'text': text})),
      '/voice/parse',
    );
    return body is Map<String, dynamic> ? VoiceIntent.fromJson(body) : null;
  }
}
