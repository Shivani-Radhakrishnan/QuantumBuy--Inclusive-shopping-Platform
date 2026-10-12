import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_app/app.dart';
import 'package:shopping_app/models/cart_model.dart';
import 'package:shopping_app/models/settings_model.dart';
import 'package:shopping_app/services/ml_client.dart';
import 'package:shopping_app/services/speaker.dart';
import 'package:shopping_app/services/speech_service.dart';

/// Records what the app says instead of using a speech engine.
class FakeSpeaker implements Speaker {
  final spoken = <String>[];

  @override
  Future<void> speak(String text) async => spoken.add(text);

  @override
  Future<void> stop() async {}
}

/// Speech recognition that "hears" whatever the test tells it to.
class FakeSpeech implements SpeechService {
  FakeSpeech({this.available = true});

  final bool available;
  void Function(String words, bool isFinal)? _onResult;
  void Function(SpeechFailure? failure)? _onDone;
  bool listening = false;

  @override
  Future<bool> start({
    required void Function(String words, bool isFinal) onResult,
    required void Function(SpeechFailure? failure) onDone,
  }) async {
    if (!available) return false;
    _onResult = onResult;
    _onDone = onDone;
    listening = true;
    return true;
  }

  /// Simulates the user saying [words].
  void hear(String words) {
    _onResult?.call(words, false);
    _onResult?.call(words, true);
    listening = false;
    _onDone?.call(null);
  }

  @override
  Future<void> stop() async => listening = false;
}

/// Pumps the real app at [route] with fake speech services and the given
/// saved settings.
Future<FakeSpeaker> pumpApp(
  WidgetTester tester, {
  String route = '/home',
  Map<String, Object> prefs = const {},
  FakeSpeech? speech,
  FakeSpeaker? speaker,
  MlClient? ml,
  Widget Function(Widget app)? wrap,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final fakeSpeaker = speaker ?? FakeSpeaker();
  final app = QuantumBuyApp(
    initialRoute: route,
    speaker: fakeSpeaker,
    speech: speech ?? FakeSpeech(),
    ml: ml ?? MlClient(baseUrl: ''),
  );
  await tester.pumpWidget(wrap == null ? app : wrap(app));
  // Let saved settings load.
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
  await tester.pumpAndSettle();
  return fakeSpeaker;
}

/// Settings stored under the keys SettingsModel uses.
Map<String, Object> settingsPrefs({
  bool highContrast = false,
  bool textScaling = false,
  bool altText = false,
  bool voiceControl = false,
  bool simplifiedText = false,
  bool accessibility = false,
  bool darkMode = false,
  bool largeText = false,
}) =>
    {
      'settings.highContrast': highContrast,
      'settings.textScaling': textScaling,
      'settings.altText': altText,
      'settings.voiceControl': voiceControl,
      'settings.simplifiedText': simplifiedText,
      'settings.accessibility': accessibility,
      'settings.darkMode': darkMode,
      'settings.largeText': largeText,
    };

CartModel cartOf(WidgetTester tester) =>
    Provider.of<CartModel>(tester.element(find.byType(Navigator).first), listen: false);

SettingsModel settingsOf(WidgetTester tester) =>
    Provider.of<SettingsModel>(tester.element(find.byType(Navigator).first), listen: false);

/// Navigator for pushing routes directly.
NavigatorState navigatorOf(WidgetTester tester) => tester.state<NavigatorState>(find.byType(Navigator).first);
