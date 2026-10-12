import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/settings_model.dart';
import '../routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();

    Widget toggle(String title, String subtitle, bool value, Future<void> Function(bool) onChanged) =>
        SwitchListTile(
          title: Text(title),
          subtitle: Text(subtitle),
          value: value,
          onChanged: onChanged,
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const _SectionHeader('Display'),
          toggle('Dark theme', 'Light text on a dark background.', settings.isDarkMode, settings.toggleDarkMode),
          toggle('Large text', 'Makes all text 20% bigger.', settings.isLargeText, settings.toggleLargeText),
          toggle('Text scaling', 'Scales text a further 30% on top of your device text size.',
              settings.isTextScaling, settings.toggleTextScaling),
          toggle('High contrast', 'Black and white colours with strong outlines.', settings.isHighContrast,
              settings.toggleHighContrast),
          const _SectionHeader('Accessibility'),
          toggle('Accessibility features', 'Reads product names, prices and cart changes aloud.',
              settings.isAccessibilityEnabled, settings.toggleAccessibility),
          toggle('Alt text for images', 'Detailed image descriptions for screen readers, shown under product photos.',
              settings.isAltTextEnabled, settings.toggleAltText),
          toggle('Voice control', 'Adds a microphone button to shopping screens for voice ordering.',
              settings.isVoiceControlEnabled, settings.toggleVoiceControl),
          toggle('Simplified text', 'Shorter, plainer product descriptions.', settings.isSimplifiedTextEnabled,
              settings.toggleSimplifiedText),
          const _SectionHeader('Personalise'),
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text('Visual-impairment survey'),
            subtitle: Text(settings.impairmentType == null
                ? 'Answer one question and we will turn on the settings that suit you.'
                : 'Your answer: ${settings.impairmentType}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, Routes.impairmentSurvey),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Semantics(
        header: true,
        child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
