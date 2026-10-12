import 'package:flutter/material.dart';

class SettingsModel with ChangeNotifier {
  bool _isDarkMode = false;
  bool _isLargeText = false;
  bool _isAccessibilityEnabled = false;
  bool _isHighContrast = false;
  bool _isTextScaling = false;
  bool _isAltTextEnabled = false;
  bool _isVoiceControlEnabled = false;
  bool _isSimplifiedTextEnabled = false;

  bool get isDarkMode => _isDarkMode;
  bool get isLargeText => _isLargeText;
  bool get isAccessibilityEnabled => _isAccessibilityEnabled;
  bool get isHighContrast => _isHighContrast;
  bool get isTextScaling => _isTextScaling;
  bool get isAltTextEnabled => _isAltTextEnabled;
  bool get isVoiceControlEnabled => _isVoiceControlEnabled;
  bool get isSimplifiedTextEnabled => _isSimplifiedTextEnabled;

  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void toggleLargeText(bool value) {
    _isLargeText = value;
    notifyListeners();
  }

  void toggleAccessibility(bool value) {
    _isAccessibilityEnabled = value;
    notifyListeners();
  }

  void toggleHighContrast(bool value) {
    _isHighContrast = value;
    notifyListeners();
  }

  void toggleTextScaling(bool value) {
    _isTextScaling = value;
    notifyListeners();
  }

  void toggleAltText(bool value) {
    _isAltTextEnabled = value;
    notifyListeners();
  }

  void toggleVoiceControl(bool value) {
    _isVoiceControlEnabled = value;
    notifyListeners();
  }

  void toggleSimplifiedText(bool value) {
    _isSimplifiedTextEnabled = value;
    notifyListeners();
  }
}
