import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Why speech recognition could not start or stopped early.
enum SpeechFailure {
  /// Microphone or speech-recognition permission was refused, or the device
  /// has no recogniser.
  unavailable,

  /// Recognition started but failed (no match, network, timeout...).
  error,
}

/// Speech recognition used by voice ordering and the login screen.
///
/// An interface so widget tests can drive voice commands without a
/// microphone.
abstract class SpeechService {
  /// Starts listening. [onResult] receives the words heard so far and whether
  /// they are final; [onDone] is called when listening stops, with the
  /// failure if there was one. Returns false if recognition is unavailable.
  Future<bool> start({
    required void Function(String words, bool isFinal) onResult,
    required void Function(SpeechFailure? failure) onDone,
  });

  Future<void> stop();
}

/// [SpeechService] backed by the platform recogniser (speech_to_text).
class PlatformSpeechService implements SpeechService {
  PlatformSpeechService([stt.SpeechToText? speech]) : _speech = speech ?? stt.SpeechToText();

  final stt.SpeechToText _speech;
  bool _initialised = false;
  void Function(SpeechFailure? failure)? _onDone;

  @override
  Future<bool> start({
    required void Function(String words, bool isFinal) onResult,
    required void Function(SpeechFailure? failure) onDone,
  }) async {
    _onDone = onDone;
    try {
      if (!_initialised) {
        _initialised = await _speech.initialize(
          onError: (error) {
            debugPrint('Speech error: ${error.errorMsg}');
            _finish(SpeechFailure.error);
          },
          onStatus: (status) {
            if (status == stt.SpeechToText.doneStatus || status == stt.SpeechToText.notListeningStatus) {
              _finish(null);
            }
          },
        );
      }
      if (!_initialised) return false;
      await _speech.listen(
        onResult: (result) => onResult(result.recognizedWords, result.finalResult),
        listenFor: const Duration(seconds: 15),
        pauseFor: const Duration(seconds: 3),
        listenOptions: stt.SpeechListenOptions(cancelOnError: true, partialResults: true),
      );
      return true;
    } catch (e) {
      debugPrint('Speech recognition unavailable: $e');
      return false;
    }
  }

  void _finish(SpeechFailure? failure) {
    final callback = _onDone;
    _onDone = null;
    callback?.call(failure);
  }

  @override
  Future<void> stop() async {
    try {
      await _speech.stop();
    } catch (_) {}
  }
}
