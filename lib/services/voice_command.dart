import '../models/product.dart';

/// A spoken command, parsed by [parseVoiceCommand].
sealed class VoiceCommand {
  const VoiceCommand();
}

/// "order two laptops", "add rice", "buy a smart tv", or just "laptop".
class AddProductCommand extends VoiceCommand {
  const AddProductCommand(this.product, this.quantity);
  final Product product;
  final int quantity;
}

/// "open electronics", "show me groceries", "clothes".
class OpenCategoryCommand extends VoiceCommand {
  const OpenCategoryCommand(this.category);
  final String category;
}

/// "open my cart", "go to checkout".
class OpenCartCommand extends VoiceCommand {
  const OpenCartCommand();
}

/// Nothing in the phrase matched a product, category or the cart.
class UnknownCommand extends VoiceCommand {
  const UnknownCommand(this.phrase);
  final String phrase;
}

const _openWords = {'open', 'show', 'browse', 'view', 'see', 'go', 'take', 'display', 'list'};

/// Extra words people use for a category, beyond the words in its name.
const Map<String, List<String>> categoryAliases = {
  'Electronics': ['electronics', 'electronic', 'gadgets', 'tech'],
  'Clothing and Accessories': ['clothing', 'clothes', 'accessories', 'fashion', 'apparel'],
  'Home and Kitchen': ['home', 'kitchen', 'appliances', 'household'],
  'Beauty and Personal Care': ['beauty', 'personal care', 'cosmetics', 'makeup', 'skincare'],
  'Groceries and Gourmet Food': ['groceries', 'grocery', 'food', 'gourmet'],
};

const _numberWords = {
  'a': 1, 'an': 1, 'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5,
  'six': 6, 'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10,
};

/// Turns recognised speech into a [VoiceCommand].
///
/// Matching is case-insensitive and tolerant of small recognition errors
/// (plurals, a letter or two wrong, "t shirt" for "T-shirt"). When several
/// products match, the longest name wins, so "rice cooker" is not read as
/// "rice". A product match beats a category match unless the phrase starts
/// with an "open"/"show" style verb.
VoiceCommand parseVoiceCommand(
  String phrase, {
  required List<Product> products,
  required List<String> categories,
}) {
  final words = _tokens(phrase);
  if (words.isEmpty) return UnknownCommand(phrase);

  final wantsToOpen = _openWords.contains(words.first);

  if (words.contains('cart') || words.contains('basket') || words.contains('checkout')) {
    final mentionsProduct = _bestProduct(words, products) != null;
    if (!mentionsProduct || wantsToOpen) return const OpenCartCommand();
  }

  final category = _bestCategory(words, categories);
  final product = _bestProduct(words, products);

  if (category != null && (wantsToOpen || product == null)) {
    return OpenCategoryCommand(category);
  }
  if (product != null) {
    return AddProductCommand(product.product, _quantity(words, product.start));
  }
  return UnknownCommand(phrase);
}

class _ProductMatch {
  _ProductMatch(this.product, this.start, this.length, this.errors);
  final Product product;
  final int start;
  final int length;
  final int errors;
}

_ProductMatch? _bestProduct(List<String> words, List<Product> products) {
  _ProductMatch? best;
  for (final product in products) {
    final nameWords = _tokens(product.name);
    final variants = <List<String>>[
      nameWords,
      if (nameWords.length > 1) [nameWords.join()], // "t shirt" -> "tshirt"
    ];
    for (final variant in variants) {
      final match = _findSequence(words, variant);
      if (match == null) continue;
      final candidate = _ProductMatch(product, match.$1, nameWords.join().length, match.$2);
      if (best == null ||
          candidate.length > best.length ||
          (candidate.length == best.length && candidate.errors < best.errors)) {
        best = candidate;
      }
    }
  }
  // Also accept two spoken words that together form a one-word name
  // ("smart watch" -> "Smartwatch").
  for (var i = 0; i + 1 < words.length; i++) {
    final joined = words[i] + words[i + 1];
    for (final product in products) {
      final name = _tokens(product.name).join();
      if (_wordsMatch(joined, name) && (best == null || name.length > best.length)) {
        best = _ProductMatch(product, i, name.length, 0);
      }
    }
  }
  return best;
}

/// Finds [target] as consecutive words in [words]; returns (start, errors).
(int, int)? _findSequence(List<String> words, List<String> target) {
  for (var i = 0; i + target.length <= words.length; i++) {
    var errors = 0;
    var ok = true;
    for (var j = 0; j < target.length; j++) {
      final d = _wordDistance(words[i + j], target[j]);
      if (d == null) {
        ok = false;
        break;
      }
      errors += d;
    }
    if (ok) return (i, errors);
  }
  return null;
}

String? _bestCategory(List<String> words, List<String> categories) {
  final phrase = words.join(' ');
  String? best;
  var bestScore = 0;
  for (final category in categories) {
    final aliases = categoryAliases[category] ??
        _tokens(category).where((w) => w != 'and' && w.length > 2).toList();
    var score = 0;
    for (final alias in aliases) {
      final aliasWords = alias.split(' ');
      if (aliasWords.length > 1 ? phrase.contains(alias) : words.any((w) => _wordsMatch(w, alias))) {
        score += alias.length;
      }
    }
    if (score > bestScore) {
      bestScore = score;
      best = category;
    }
  }
  return best;
}

int _quantity(List<String> words, int productStart) {
  // The word just before the product name: "order two laptops".
  if (productStart == 0) return 1;
  final word = words[productStart - 1];
  final n = int.tryParse(word) ?? _numberWords[word];
  return (n != null && n > 0 && n <= 20) ? n : 1;
}

List<String> _tokens(String text) => text
    .toLowerCase()
    .replaceAll(RegExp(r"[^a-z0-9\s]"), ' ')
    .split(RegExp(r'\s+'))
    .where((w) => w.isNotEmpty)
    .toList();

bool _wordsMatch(String spoken, String expected) => _wordDistance(spoken, expected) != null;

/// Edit distance between a spoken word and an expected word, after removing
/// a plural "s"/"es", or null if they are too different to be the same word.
int? _wordDistance(String spoken, String expected) {
  if (spoken == expected) return 0;
  for (final suffix in const ['es', 's']) {
    if (spoken.endsWith(suffix) && spoken.substring(0, spoken.length - suffix.length) == expected) {
      return 0;
    }
  }
  // Short words must match exactly; "tea" and "tie" are different products.
  if (expected.length < 5) return null;
  final allowed = expected.length >= 8 ? 2 : 1;
  if ((spoken.length - expected.length).abs() > allowed) return null;
  final d = levenshtein(spoken, expected);
  return d <= allowed ? d : null;
}

/// Classic Levenshtein edit distance.
int levenshtein(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  var previous = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 0; i < a.length; i++) {
    final current = List<int>.filled(b.length + 1, 0);
    current[0] = i + 1;
    for (var j = 0; j < b.length; j++) {
      final cost = a[i] == b[j] ? 0 : 1;
      current[j + 1] = [current[j] + 1, previous[j + 1] + 1, previous[j] + cost]
          .reduce((x, y) => x < y ? x : y);
    }
    previous = current;
  }
  return previous[b.length];
}

/// The sentence spoken (and shown) after a command is carried out.
String confirmationFor(VoiceCommand command) => switch (command) {
      AddProductCommand(:final product, :final quantity) => quantity == 1
          ? 'Added ${product.name} to your cart.'
          : 'Added $quantity ${product.name} to your cart.',
      OpenCategoryCommand(:final category) => 'Opening $category.',
      OpenCartCommand() => 'Opening your cart.',
      UnknownCommand(:final phrase) =>
        'Sorry, I could not find "$phrase". Try saying "order rice" or "open electronics".',
    };
