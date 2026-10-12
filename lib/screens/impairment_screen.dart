import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/settings_model.dart';

/// Asks about the shopper's visual impairment and switches on the settings
/// recommended for it (see [recommendedSettingsFor]).
class VisualImpairmentSurveyPage extends StatefulWidget {
  const VisualImpairmentSurveyPage({super.key});

  static const impairmentTypes = [
    'Complete Blindness',
    'Partial Vision',
    'Low Vision',
    'Color Blindness',
    'Night Blindness',
    'Peripheral Vision Loss',
    'Other',
  ];

  @override
  State<VisualImpairmentSurveyPage> createState() => _VisualImpairmentSurveyPageState();
}

class _VisualImpairmentSurveyPageState extends State<VisualImpairmentSurveyPage> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = context.read<SettingsModel>().impairmentType;
  }

  Future<void> _submit() async {
    final selected = _selected;
    final messenger = ScaffoldMessenger.of(context);
    if (selected == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Please select your type of visual impairment')));
      return;
    }
    final settings = context.read<SettingsModel>();
    await settings.applyImpairmentProfile(selected);
    final turnedOn = recommendedSettingsFor(selected);
    messenger.showSnackBar(SnackBar(
      content: Text(turnedOn.isEmpty
          ? 'Saved. You can choose settings yourself in Settings.'
          : 'Saved. Turned on: ${turnedOn.map(settingLabel).join(', ')}.'),
    ));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visual Impairment Survey')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Please select your type of visual impairment:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                for (final type in VisualImpairmentSurveyPage.impairmentTypes)
                  RadioListTile<String>(
                    title: Text(type),
                    value: type,
                    groupValue: _selected,
                    onChanged: (value) => setState(() => _selected = value),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('Save and apply'),
            ),
          ),
        ],
      ),
    );
  }
}
