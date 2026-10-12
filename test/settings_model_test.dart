import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_app/models/settings_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SettingsModel> load([Map<String, Object> stored = const {}]) async {
    SharedPreferences.setMockInitialValues(stored);
    final settings = SettingsModel();
    await settings.ready;
    return settings;
  }

  test('everything is off by default', () async {
    final s = await load();
    expect(
      [s.isDarkMode, s.isLargeText, s.isAccessibilityEnabled, s.isHighContrast, s.isTextScaling,
       s.isAltTextEnabled, s.isVoiceControlEnabled, s.isSimplifiedTextEnabled],
      everyElement(isFalse),
    );
    expect(s.impairmentType, isNull);
  });

  test('toggles are saved and survive a restart', () async {
    final s = await load();
    await s.toggleHighContrast(true);
    await s.toggleTextScaling(true);
    await s.toggleAltText(true);
    await s.toggleVoiceControl(true);
    await s.toggleSimplifiedText(true);
    await s.toggleAccessibility(true);

    final prefs = await SharedPreferences.getInstance();
    final stored = {for (final k in prefs.getKeys()) k: prefs.get(k)!};
    final restarted = await load(stored);
    expect(restarted.isHighContrast, isTrue);
    expect(restarted.isTextScaling, isTrue);
    expect(restarted.isAltTextEnabled, isTrue);
    expect(restarted.isVoiceControlEnabled, isTrue);
    expect(restarted.isSimplifiedTextEnabled, isTrue);
    expect(restarted.speaksProductDetails, isTrue);
    expect(restarted.isDarkMode, isFalse);
  });

  test('toggling notifies listeners', () async {
    final s = await load();
    var count = 0;
    s.addListener(() => count++);
    await s.toggleDarkMode(true);
    expect(count, 1);
  });

  test('the survey turns on the recommended settings and keeps others', () async {
    final s = await load();
    await s.toggleDarkMode(true);
    await s.applyImpairmentProfile('Low Vision');
    expect(s.impairmentType, 'Low Vision');
    expect(s.isLargeText, isTrue);
    expect(s.isTextScaling, isTrue);
    expect(s.isHighContrast, isTrue);
    expect(s.isAltTextEnabled, isTrue);
    expect(s.isDarkMode, isTrue, reason: 'existing choices are not switched off');

    final restarted = await load({
      for (final k in (await SharedPreferences.getInstance()).getKeys())
        k: (await SharedPreferences.getInstance()).get(k)!,
    });
    expect(restarted.impairmentType, 'Low Vision');
  });

  test('every survey answer has a recommendation (or none for Other)', () {
    expect(recommendedSettingsFor('Complete Blindness'),
        containsAll([AccessibilitySetting.accessibility, AccessibilitySetting.voiceControl]));
    expect(recommendedSettingsFor('Color Blindness'), contains(AccessibilitySetting.highContrast));
    expect(recommendedSettingsFor('Other'), isEmpty);
  });
}
