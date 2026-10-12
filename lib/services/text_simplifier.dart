/// Shortens a product description to plain, easy-to-read text.
///
/// Used when "Simplified text" is on. Keeps the first sentence, drops the
/// trailing qualifying clause ("with ...", "for ...", after a comma) and caps
/// the result at [maxWords] words.
///
///     simplifyDescription('High-performance laptop for gaming and work.')
///     // 'High-performance laptop.'
String simplifyDescription(String description, {int maxWords = 6}) {
  var text = description.trim();
  if (text.isEmpty) return text;

  // First sentence only.
  final sentenceEnd = RegExp(r'[.!?](\s|$)').firstMatch(text);
  if (sentenceEnd != null) text = text.substring(0, sentenceEnd.start);

  // Drop a trailing clause, but only if something meaningful is left.
  final clause = RegExp(r',|\s(with|for|and|that|which|in|to)\s', caseSensitive: false)
      .firstMatch(text);
  if (clause != null && text.substring(0, clause.start).trim().split(RegExp(r'\s+')).length >= 2) {
    text = text.substring(0, clause.start);
  }

  final words = text.trim().split(RegExp(r'\s+'));
  if (words.length > maxWords) text = words.take(maxWords).join(' ');

  return '${text.trim()}.';
}
