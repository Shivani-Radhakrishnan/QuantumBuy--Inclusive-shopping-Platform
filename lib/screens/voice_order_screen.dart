import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/product_catalog.dart';
import '../models/cart_model.dart';
import '../routes.dart';
import '../services/speaker.dart';
import '../services/speech_service.dart';
import '../services/voice_command.dart';

/// Order by voice: "order two laptops", "add rice", "open electronics",
/// "open my cart". Commands can also be typed.
class VoiceOrderScreen extends StatefulWidget {
  const VoiceOrderScreen({super.key});

  @override
  State<VoiceOrderScreen> createState() => _VoiceOrderScreenState();
}

class _VoiceOrderScreenState extends State<VoiceOrderScreen> {
  late final SpeechService _speech;
  final _typedController = TextEditingController();
  bool _isListening = false;
  String _heard = '';
  String _status = 'Tap the microphone and say what you want, for example "order two laptops".';

  @override
  void initState() {
    super.initState();
    _speech = context.read<SpeechService>();
  }

  @override
  void dispose() {
    if (_isListening) _speech.stop();
    _typedController.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }
    setState(() {
      _heard = '';
      _status = 'Listening...';
    });
    final started = await _speech.start(
      onResult: (words, isFinal) {
        if (!mounted) return;
        setState(() => _heard = words);
        if (isFinal) _handle(words);
      },
      onDone: (failure) {
        if (!mounted) return;
        setState(() {
          _isListening = false;
          if (failure != null && _heard.isEmpty) {
            _status = 'I did not catch that. Tap the microphone and try again.';
          }
        });
      },
    );
    if (!mounted) return;
    setState(() {
      _isListening = started;
      if (!started) {
        _status = 'Speech recognition is not available. Check microphone permission, '
            'or type your order below.';
      }
    });
  }

  /// Parses and carries out a spoken or typed command.
  void _handle(String phrase) {
    if (phrase.trim().isEmpty) return;
    final repository = context.read<ProductRepository>();
    final command = parseVoiceCommand(
      phrase,
      products: repository.allProducts,
      categories: repository.categories,
    );
    final message = confirmationFor(command);
    setState(() {
      _heard = phrase;
      _status = message;
    });
    context.read<Speaker>().speak(message);

    switch (command) {
      case AddProductCommand(:final product, :final quantity):
        context.read<CartModel>().addItem(product, quantity: quantity);
      case OpenCategoryCommand(:final category):
        Navigator.pushNamed(context, Routes.productList, arguments: category);
      case OpenCartCommand():
        Navigator.pushNamed(context, Routes.cart);
      case UnknownCommand():
        break;
    }
  }

  void _submitTyped() {
    final text = _typedController.text;
    _typedController.clear();
    _handle(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartCount = context.select<CartModel, int>((cart) => cart.totalQuantity);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Order'),
        actions: [
          IconButton(
            tooltip: 'Cart, $cartCount ${cartCount == 1 ? 'item' : 'items'}',
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_cart),
            ),
            onPressed: () => Navigator.pushNamed(context, Routes.cart),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Semantics(
            liveRegion: true,
            child: Text(_status, key: const Key('voiceStatus'), style: theme.textTheme.headlineSmall),
          ),
          if (_heard.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('You said: "$_heard"', style: theme.textTheme.titleMedium),
          ],
          const SizedBox(height: 32),
          Center(
            child: SizedBox(
              width: 96,
              height: 96,
              child: FloatingActionButton.large(
                heroTag: 'voiceOrderMic',
                tooltip: _isListening ? 'Stop listening' : 'Start listening',
                onPressed: _toggleListening,
                child: Icon(_isListening ? Icons.mic : Icons.mic_none),
              ),
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            key: const Key('typedCommandField'),
            controller: _typedController,
            decoration: InputDecoration(
              labelText: 'Or type a command',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                tooltip: 'Send command',
                icon: const Icon(Icons.send),
                onPressed: _submitTyped,
              ),
            ),
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _submitTyped(),
          ),
          const SizedBox(height: 24),
          Text('Try saying', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          for (final example in const [
            '"Order two laptops"',
            '"Add rice cooker"',
            '"Buy a smart watch"',
            '"Open groceries"',
            '"Show my cart"',
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(example, style: theme.textTheme.bodyLarge),
            ),
        ],
      ),
    );
  }
}
