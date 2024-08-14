import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Import text-to-speech
import 'package:speech_to_text/speech_to_text.dart'; // Import speech-to-text
import 'user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  final FlutterTts _flutterTts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    await _speechToText.initialize();
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void _toggleListening() async {
    if (_isListening) {
      _speechToText.stop();
    } else {
      bool available = await _speechToText.initialize();
      if (available) {
        _speechToText.listen(onResult: (result) {
          if (result.hasConfidenceRating && result.confidence > 0.5) {
            String command = result.recognizedWords.toLowerCase();
            if (command.contains('username') || command.contains('email')) {
              _speak('Username or Email field');
            } else if (command.contains('password')) {
              _speak('Password field');
            } else if (command.contains('login')) {
              _login();
            }
          }
        });
      }
    }
    setState(() {
      _isListening = !_isListening;
    });
  }

  void _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    bool isAuthenticated =
        Provider.of<UserModel>(context, listen: false).authenticate(username, password);

    if (isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Successful!'),
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(seconds: 2)); // Delay to show the snackbar

      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _errorMessage = 'Invalid username or password';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login to QuantumBuy'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username or Email',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.blue, // High-contrast color
              ),
              child: const Text('Login'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text('New user? Register here'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleListening,
              child: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 20),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
