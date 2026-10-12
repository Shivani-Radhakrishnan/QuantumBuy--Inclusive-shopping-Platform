import '../models/product.dart';
import 'voice_command.dart' show levenshtein;

/// On-device keyword search, used when the ML service is unavailable.
///
/// Scores each product by how many query words appear in its name (most) or
/// description, tolerating one wrong letter in words of five letters or more.
List<Product> localSearch(String query, List<Product> products, {int limit = 10}) {
  final words = _words(query).where((w) => w.length >= 2).toList();
  if (words.isEmpty) return const [];
  final scored = <(Product, double)>[];
  for (final product in products) {
    final name = _words(product.name);
    final description = _words(product.description);
    var score = 0.0;
    for (final w in words) {
      if (name.contains(w)) {
        score += 3;
      } else if (name.any((n) => _close(w, n))) {
        score += 2;
      } else if (description.contains(w)) {
        score += 1;
      }
    }
    if (score > 0) scored.add((product, score));
  }
  scored.sort((a, b) => b.$2.compareTo(a.$2));
  return [for (final s in scored.take(limit)) s.$1];
}

List<String> _words(String text) => text
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
    .split(' ')
    .where((w) => w.isNotEmpty)
    .map((w) => w.length > 3 && w.endsWith('s') ? w.substring(0, w.length - 1) : w)
    .toList();

bool _close(String a, String b) =>
    (a.length >= 5 && b.length >= 5 && levenshtein(a, b) <= 1) || (a.length >= 4 && b.startsWith(a));
