import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/settings_model.dart';
import '../routes.dart';

/// A microphone button that opens voice ordering from any shopping screen.
///
/// Only shown when the "Voice control" setting is on; otherwise it takes no
/// space. Use it as a Scaffold's floatingActionButton.
class VoiceShortcutButton extends StatelessWidget {
  const VoiceShortcutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final enabled = context.watch<SettingsModel>().isVoiceControlEnabled;
    if (!enabled) return const SizedBox.shrink();
    return FloatingActionButton(
      heroTag: 'voiceShortcut',
      tooltip: 'Voice order',
      onPressed: () => Navigator.pushNamed(context, Routes.voiceOrder),
      child: const Icon(Icons.mic),
    );
  }
}
