import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-speech used across the app.
///
/// An interface so widget tests can swap in a fake and check what was said.
abstract class Speaker {
  Future<void> speak(String text);
  Future<void> stop();
}

/// [Speaker] backed by the platform text-to-speech engine (flutter_tts).
class TtsSpeaker implements Speaker {
  TtsSpeaker([FlutterTts? tts]) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;

  @override
  Future<void> speak(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (e) {
      // Text-to-speech isn't available on every platform; never crash for it.
      debugPrint('Text-to-speech unavailable: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}

/// Formats a price the way it is shown and spoken in the app.
String formatPrice(double price) => '₹${price.toStringAsFixed(2)}';

/// What is read aloud for a product: its name and price, in words a speech
/// engine pronounces naturally.
String spokenProductSummary(String name, double price) => '$name, ${spokenPrice(price)}';

/// A price as words a speech engine reads naturally: "1500 rupees".
String spokenPrice(double price) {
  final rupees = price.truncateToDouble() == price ? price.toStringAsFixed(0) : price.toStringAsFixed(2);
  return '$rupees rupees';
}
