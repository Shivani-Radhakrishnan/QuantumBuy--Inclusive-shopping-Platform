import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_model.dart';
import 'cart_model.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'UPI';
  final _upiController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _netBankingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    final cartModel = Provider.of<CartModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Confirm Delivery Address:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(userModel.address ?? 'No address provided'),
            const SizedBox(height: 20),
            const Text(
              'Select Payment Method:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: const Text('UPI'),
              leading: Radio<String>(
                value: 'UPI',
                groupValue: _selectedPaymentMethod,
                onChanged: (String? value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Credit/Debit Card'),
              leading: Radio<String>(
                value: 'Card',
                groupValue: _selectedPaymentMethod,
                onChanged: (String? value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Net Banking'),
              leading: Radio<String>(
                value: 'Net Banking',
                groupValue: _selectedPaymentMethod,
                onChanged: (String? value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
            ),
            if (_selectedPaymentMethod == 'UPI') ...[
              TextField(
                controller: _upiController,
                decoration: const InputDecoration(labelText: 'UPI ID'),
              ),
            ],
            if (_selectedPaymentMethod == 'Card') ...[
              TextField(
                controller: _cardNumberController,
                decoration: const InputDecoration(labelText: 'Card Number'),
              ),
              TextField(
                controller: _expiryDateController,
                decoration: const InputDecoration(labelText: 'Expiry Date (MM/YY)'),
              ),
              TextField(
                controller: _cvvController,
                decoration: const InputDecoration(labelText: 'CVV'),
                obscureText: true,
              ),
            ],
            if (_selectedPaymentMethod == 'Net Banking') ...[
              TextField(
                controller: _netBankingController,
                decoration: const InputDecoration(labelText: 'Bank Name'),
              ),
            ],
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (validatePaymentDetails()) {
                  // Implement the payment process
                  cartModel.clearCart();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Purchase successful')),
                  );
                  Navigator.pushReplacementNamed(context, '/');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid payment details')),
                  );
                }
              },
              child: const Text('Buy Now'),
            ),
          ],
        ),
      ),
    );
  }

  bool validatePaymentDetails() {
    if (_selectedPaymentMethod == 'UPI') {
      return _upiController.text.isNotEmpty;
    } else if (_selectedPaymentMethod == 'Card') {
      return _cardNumberController.text.isNotEmpty &&
          _expiryDateController.text.isNotEmpty &&
          _cvvController.text.isNotEmpty;
    } else if (_selectedPaymentMethod == 'Net Banking') {
      return _netBankingController.text.isNotEmpty;
    }
    return false;
  }
}
