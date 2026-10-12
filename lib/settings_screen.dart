import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_model.dart'; // Import your settings model

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsModel>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Basic Settings
          const Text(
            'Basic Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SwitchListTile(
            title: const Text('Enable Dark Theme'),
            value: settings.isDarkMode,
            onChanged: (bool value) {
              settings.toggleDarkMode(value);
            },
          ),
          SwitchListTile(
            title: const Text('Enable Large Text'),
            value: settings.isLargeText,
            onChanged: (bool value) {
              settings.toggleLargeText(value);
            },
          ),
          SwitchListTile(
            title: const Text('Enable Accessibility Features'),
            value: settings.isAccessibilityEnabled,
            onChanged: (bool value) {
              settings.toggleAccessibility(value);
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Accessibility Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SwitchListTile(
            title: const Text('High Contrast'),
            value: settings.isHighContrast,
            onChanged: (bool value) {
              settings.toggleHighContrast(value);
            },
          ),
          SwitchListTile(
            title: const Text('Text Scaling'),
            value: settings.isTextScaling,
            onChanged: (bool value) {
              settings.toggleTextScaling(value);
            },
          ),
          SwitchListTile(
            title: const Text('Alt Text for Images'),
            value: settings.isAltTextEnabled,
            onChanged: (bool value) {
              settings.toggleAltText(value);
            },
          ),
          SwitchListTile(
            title: const Text('Voice Control'),
            value: settings.isVoiceControlEnabled,
            onChanged: (bool value) {
              settings.toggleVoiceControl(value);
            },
          ),
          SwitchListTile(
            title: const Text('Simplified Text'),
            value: settings.isSimplifiedTextEnabled,
            onChanged: (bool value) {
              settings.toggleSimplifiedText(value);
            },
          ),
        ],
      ),
    );
  }
}
