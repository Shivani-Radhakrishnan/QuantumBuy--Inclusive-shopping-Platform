import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:provider/provider.dart';
import 'cart_model.dart';
import 'product_model.dart';

class VoiceOrderScreen extends StatefulWidget {
  @override
  _VoiceOrderScreenState createState() => _VoiceOrderScreenState();
}

class _VoiceOrderScreenState extends State<VoiceOrderScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Press the button and start speaking";
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
            _processVoiceCommand(_text);
          }),
        );
      } else {
        setState(() => _isListening = false);
        _speech.stop();
      }
    }
  }

  void _processVoiceCommand(String command) {
    // Handle navigation to a specific category
    if (command.toLowerCase().contains("open electronics")) {
      Navigator.pushNamed(context, '/productList', arguments: 'Electronics');
    } else if (command.toLowerCase().contains("open clothing")) {
      Navigator.pushNamed(context, '/productList', arguments: 'Clothing and Accessories');
    } else if (command.toLowerCase().contains("open groceries")) {
      Navigator.pushNamed(context, '/productList', arguments: 'Groceries and Gourmet Food');
    } 
    // Additional categories can be added here

    // Handle ordering a specific product
    else if (command.toLowerCase().contains("order smartphone")) {
      _addItemToCart('Smartphone');
    } else if (command.toLowerCase().contains("order laptop")) {
      _addItemToCart('Laptop');
    } else if (command.toLowerCase().contains("order rice")) {
      _addItemToCart('Rice');
    } 
    // Additional products can be added here
  }

  void _addItemToCart(String productName) {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final productModel = cartModel.getProductByName(productName);

    if (productModel != null) {
      cartModel.addItem(productModel);
      setState(() {
        _text = "$productName has been added to your cart";
      });
    } else {
      setState(() {
        _text = "Sorry, I couldn't find $productName";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Order'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Text(
                _text,
                style: TextStyle(fontSize: 24.0),
              ),
            ),
          ),
          FloatingActionButton(
            onPressed: _listen,
            child: Icon(_isListening ? Icons.mic : Icons.mic_none),
          ),
          SizedBox(height: 20),
          Text(
            'Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%',
          ),
        ],
      ),
    );
  }
}
