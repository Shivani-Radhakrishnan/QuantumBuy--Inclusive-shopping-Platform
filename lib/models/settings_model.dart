import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User-facing accessibility and display preferences.
///
/// Every setting is saved with SharedPreferences, so it survives restarts.
/// How each one is applied:
/// - dark mode, high contrast: the app theme (`lib/app_theme.dart`)
/// - large text: larger base font sizes in the theme
/// - text scaling: multiplies the system text scale by [textScaleBoost]
/// - alt text: visible captions on product images (images always carry a
///   screen-reader label)
/// - accessibility features: product name and price are read aloud
/// - voice control: a microphone shortcut on the shopping screens
/// - simplified text: shorter, plainer product descriptions
class SettingsModel with ChangeNotifier {
  SettingsModel() {
    _ready = _load();
  }

  static const double textScaleBoost = 1.3;

  static const _kDarkMode = 'settings.darkMode';
  static const _kLargeText = 'settings.largeText';
  static const _kAccessibility = 'settings.accessibility';
  static const _kHighContrast = 'settings.highContrast';
  static const _kTextScaling = 'settings.textScaling';
  static const _kAltText = 'settings.altText';
  static const _kVoiceControl = 'settings.voiceControl';
  static const _kSimplifiedText = 'settings.simplifiedText';
  static const _kImpairment = 'settings.impairment';

  late final Future<void> _ready;

  /// Completes once saved settings have been loaded.
  Future<void> get ready => _ready;

  bool _isDarkMode = false;
  bool _isLargeText = false;
  bool _isAccessibilityEnabled = false;
  bool _isHighContrast = false;
  bool _isTextScaling = false;
  bool _isAltTextEnabled = false;
  bool _isVoiceControlEnabled = false;
  bool _isSimplifiedTextEnabled = false;
  String? _impairmentType;

  bool get isDarkMode => _isDarkMode;
  bool get isLargeText => _isLargeText;
  bool get isAccessibilityEnabled => _isAccessibilityEnabled;
  bool get isHighContrast => _isHighContrast;
  bool get isTextScaling => _isTextScaling;
  bool get isAltTextEnabled => _isAltTextEnabled;
  bool get isVoiceControlEnabled => _isVoiceControlEnabled;
  bool get isSimplifiedTextEnabled => _isSimplifiedTextEnabled;

  /// The answer to the visual-impairment survey, if it has been taken.
  String? get impairmentType => _impairmentType;

  /// Whether product name and price should be read aloud.
  bool get speaksProductDetails => _isAccessibilityEnabled;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_kDarkMode) ?? false;
    _isLargeText = prefs.getBool(_kLargeText) ?? false;
    _isAccessibilityEnabled = prefs.getBool(_kAccessibility) ?? false;
    _isHighContrast = prefs.getBool(_kHighContrast) ?? false;
    _isTextScaling = prefs.getBool(_kTextScaling) ?? false;
    _isAltTextEnabled = prefs.getBool(_kAltText) ?? false;
    _isVoiceControlEnabled = prefs.getBool(_kVoiceControl) ?? false;
    _isSimplifiedTextEnabled = prefs.getBool(_kSimplifiedText) ?? false;
    _impairmentType = prefs.getString(_kImpairment);
    notifyListeners();
  }

  Future<void> _save(String key, bool value) async {
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> toggleDarkMode(bool value) {
    _isDarkMode = value;
    return _save(_kDarkMode, value);
  }

  Future<void> toggleLargeText(bool value) {
    _isLargeText = value;
    return _save(_kLargeText, value);
  }

  Future<void> toggleAccessibility(bool value) {
    _isAccessibilityEnabled = value;
    return _save(_kAccessibility, value);
  }

  Future<void> toggleHighContrast(bool value) {
    _isHighContrast = value;
    return _save(_kHighContrast, value);
  }

  Future<void> toggleTextScaling(bool value) {
    _isTextScaling = value;
    return _save(_kTextScaling, value);
  }

  Future<void> toggleAltText(bool value) {
    _isAltTextEnabled = value;
    return _save(_kAltText, value);
  }

  Future<void> toggleVoiceControl(bool value) {
    _isVoiceControlEnabled = value;
    return _save(_kVoiceControl, value);
  }

  Future<void> toggleSimplifiedText(bool value) {
    _isSimplifiedTextEnabled = value;
    return _save(_kSimplifiedText, value);
  }

  /// Records the survey answer and turns on the settings that suit it.
  /// Settings are only switched on, never off, so earlier choices are kept.
  Future<void> applyImpairmentProfile(String impairmentType) async {
    _impairmentType = impairmentType;
    final recommended = recommendedSettingsFor(impairmentType);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kImpairment, impairmentType);
    for (final setting in recommended) {
      switch (setting) {
        case AccessibilitySetting.darkMode:
          await toggleDarkMode(true);
        case AccessibilitySetting.largeText:
          await toggleLargeText(true);
        case AccessibilitySetting.accessibility:
          await toggleAccessibility(true);
        case AccessibilitySetting.highContrast:
          await toggleHighContrast(true);
        case AccessibilitySetting.textScaling:
          await toggleTextScaling(true);
        case AccessibilitySetting.altText:
          await toggleAltText(true);
        case AccessibilitySetting.voiceControl:
          await toggleVoiceControl(true);
        case AccessibilitySetting.simplifiedText:
          await toggleSimplifiedText(true);
      }
    }
    notifyListeners();
  }
}

enum AccessibilitySetting {
  darkMode,
  largeText,
  accessibility,
  highContrast,
  textScaling,
  altText,
  voiceControl,
  simplifiedText,
}

/// Settings suggested for each answer of the visual-impairment survey.
Set<AccessibilitySetting> recommendedSettingsFor(String impairmentType) {
  switch (impairmentType) {
    case 'Complete Blindness':
      return {
        AccessibilitySetting.accessibility,
        AccessibilitySetting.voiceControl,
        AccessibilitySetting.simplifiedText,
      };
    case 'Partial Vision':
    case 'Low Vision':
      return {
        AccessibilitySetting.largeText,
        AccessibilitySetting.textScaling,
        AccessibilitySetting.highContrast,
        AccessibilitySetting.altText,
        AccessibilitySetting.accessibility,
      };
    case 'Color Blindness':
      return {AccessibilitySetting.highContrast, AccessibilitySetting.altText};
    case 'Night Blindness':
      return {AccessibilitySetting.highContrast, AccessibilitySetting.largeText};
    case 'Peripheral Vision Loss':
      return {AccessibilitySetting.largeText, AccessibilitySetting.simplifiedText};
    default:
      return {};
  }
}

/// The name of a setting as shown in the Settings screen.
String settingLabel(AccessibilitySetting setting) => switch (setting) {
      AccessibilitySetting.darkMode => 'Dark theme',
      AccessibilitySetting.largeText => 'Large text',
      AccessibilitySetting.accessibility => 'Accessibility features',
      AccessibilitySetting.highContrast => 'High contrast',
      AccessibilitySetting.textScaling => 'Text scaling',
      AccessibilitySetting.altText => 'Alt text for images',
      AccessibilitySetting.voiceControl => 'Voice control',
      AccessibilitySetting.simplifiedText => 'Simplified text',
    };
