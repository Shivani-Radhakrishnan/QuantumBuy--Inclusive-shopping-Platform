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

    // Calculate the total price from the items in the cart
    double totalPrice = cartModel.items.fold(0, (sum, item) => sum + item.price);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: const Color(0xFFDD8560),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
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
                const SizedBox(height: 10),
                _buildPaymentMethodRadio('UPI', 'UPI'),
                _buildPaymentMethodRadio('Card', 'Credit/Debit Card'),
                _buildPaymentMethodRadio('Net Banking', 'Net Banking'),
                const SizedBox(height: 20),
                _buildPaymentInput(),
              ],
            ),
          ),
          const Spacer(),
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL',
                  style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 3),
                ),
                Text(
                  '₹${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.orange, fontSize: 16, letterSpacing: 3),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (validatePaymentDetails()) {
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
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black, backgroundColor: const Color(0xFFDD8560),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
            ),
            child: const Text('Buy Now'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodRadio(String value, String title) {
    return ListTile(
      title: Text(title),
      leading: Radio<String>(
        value: value,
        groupValue: _selectedPaymentMethod,
        onChanged: (String? newValue) {
          setState(() {
            _selectedPaymentMethod = newValue!;
          });
        },
      ),
    );
  }

  Widget _buildPaymentInput() {
    if (_selectedPaymentMethod == 'UPI') {
      return TextField(
        controller: _upiController,
        decoration: const InputDecoration(labelText: 'UPI ID'),
      );
    } else if (_selectedPaymentMethod == 'Card') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
      );
    } else if (_selectedPaymentMethod == 'Net Banking') {
      return TextField(
        controller: _netBankingController,
        decoration: const InputDecoration(labelText: 'Bank Name'),
      );
    }
    return const SizedBox.shrink();
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
