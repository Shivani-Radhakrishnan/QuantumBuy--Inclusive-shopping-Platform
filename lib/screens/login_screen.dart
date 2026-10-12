import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../routes.dart';
import '../services/speaker.dart';
import '../services/speech_service.dart';
import '../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isListening = false;
  late final SpeechService _speech;

  @override
  void initState() {
    super.initState();
    _speech = context.read<SpeechService>();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    if (_isListening) _speech.stop();
    super.dispose();
  }

  Future<void> _toggleVoiceHelp() async {
    final speech = _speech;
    final speaker = context.read<Speaker>();
    if (_isListening) {
      await speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }
    final started = await speech.start(
      onResult: (words, isFinal) {
        if (!isFinal) return;
        final command = words.toLowerCase();
        if (command.contains('username') || command.contains('email')) {
          speaker.speak('Username or email field');
        } else if (command.contains('password')) {
          speaker.speak('Password field');
        } else if (command.contains('log in') || command.contains('login')) {
          _login();
        } else if (command.contains('register')) {
          Navigator.pushNamed(context, Routes.register);
        }
      },
      onDone: (_) {
        if (mounted) setState(() => _isListening = false);
      },
    );
    if (!mounted) return;
    setState(() => _isListening = started);
    if (!started) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voice help needs microphone permission.')),
      );
    } else {
      speaker.speak('Listening. Say username, password, login or register.');
    }
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<UserModel>();
    final ok = user.authenticate(_usernameController.text, _passwordController.text);
    if (!ok) {
      setState(() => _errorMessage = 'Invalid username or password');
      context.read<Speaker>().speak('Invalid username or password');
      return;
    }
    setState(() => _errorMessage = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login successful'), duration: Duration(seconds: 2)),
    );
    Navigator.pushReplacementNamed(context, Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Login to QuantumBuy'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username or email',
                            prefixIcon: Icon(Icons.person),
                          ),
                          autofillHints: const [AutofillHints.username],
                          textInputAction: TextInputAction.next,
                          validator: (v) => requiredField(v, 'your username or email'),
                        ),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                          ),
                          autofillHints: const [AutofillHints.password],
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _login(),
                          validator: (v) => requiredField(v, 'your password'),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _errorMessage!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _login,
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Login'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, Routes.register),
                  child: const Text('New user? Register here'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _toggleVoiceHelp,
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                  label: Text(_isListening ? 'Stop voice help' : 'Voice help'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
