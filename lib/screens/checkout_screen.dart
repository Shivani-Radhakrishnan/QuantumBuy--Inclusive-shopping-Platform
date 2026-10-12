import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/cart_model.dart';
import '../models/settings_model.dart';
import '../models/user_model.dart';
import '../routes.dart';
import '../services/speaker.dart';
import '../utils/validators.dart';

enum PaymentMethod {
  upi('UPI'),
  card('Credit/Debit Card'),
  netBanking('Net Banking');

  const PaymentMethod(this.label);
  final String label;
}

/// Checkout (demo): delivery address and payment details are validated, but
/// no payment is processed and card details are never stored or sent.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _upiController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  PaymentMethod _method = PaymentMethod.upi;
  String? _bank;
  bool _saveAddress = true;

  static const _banks = ['State Bank of India', 'HDFC Bank', 'ICICI Bank', 'Axis Bank', 'Kotak Mahindra Bank'];

  @override
  void initState() {
    super.initState();
    _addressController.text = context.read<UserModel>().address ?? '';
  }

  @override
  void dispose() {
    _addressController.dispose();
    _upiController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct the highlighted fields.')),
      );
      return;
    }
    final cart = context.read<CartModel>();
    final user = context.read<UserModel>();
    final speak = context.read<SettingsModel>().speaksProductDetails;
    final speaker = context.read<Speaker>();
    final address = _addressController.text.trim();

    if (_saveAddress && address != (user.address ?? '')) {
      await user.updateProfile(address: address);
    }
    if (!mounted) return;
    final order = cart.placeOrder(paymentMethod: _method.label, deliveryAddress: address);
    if (speak) speaker.speak('Order placed. Total ${spokenPrice(order.total)}.');
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.orderConfirmation,
      ModalRoute.withName(Routes.home),
      arguments: order,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();
    final theme = Theme.of(context);

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Your cart is empty, so there is nothing to check out.'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pushReplacementNamed(context, Routes.categories),
                child: const Text('Browse categories'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Order summary', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final item in cart.items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(child: Text('${item.quantity} x ${item.product.name}')),
                    Text(formatPrice(item.lineTotal)),
                  ],
                ),
              ),
            const Divider(height: 24),
            Text('Delivery address', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('addressField'),
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
              minLines: 2,
              maxLines: 4,
              validator: (v) {
                final missing = requiredField(v, 'a delivery address');
                if (missing != null) return missing;
                return v!.trim().length < 10 ? 'Please enter the full address' : null;
              },
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _saveAddress,
              onChanged: (v) => setState(() => _saveAddress = v ?? false),
              title: const Text('Save this address to my profile'),
            ),
            const Divider(height: 24),
            Text('Payment method', style: theme.textTheme.titleMedium),
            for (final method in PaymentMethod.values)
              RadioListTile<PaymentMethod>(
                contentPadding: EdgeInsets.zero,
                title: Text(method.label),
                value: method,
                groupValue: _method,
                onChanged: (v) => setState(() => _method = v!),
              ),
            const SizedBox(height: 8),
            ..._paymentFields(),
            const SizedBox(height: 8),
            Text(
              'Demo checkout: no payment is taken and card details are not stored.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Total: ${formatPrice(cart.totalCost)}',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              FilledButton(
                key: const Key('placeOrderButton'),
                onPressed: _placeOrder,
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                child: const Text('Place order'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _paymentFields() {
    const border = OutlineInputBorder();
    switch (_method) {
      case PaymentMethod.upi:
        return [
          TextFormField(
            key: const Key('upiField'),
            controller: _upiController,
            decoration: const InputDecoration(labelText: 'UPI ID', hintText: 'name@bank', border: border),
            keyboardType: TextInputType.emailAddress,
            validator: validateUpiId,
          ),
        ];
      case PaymentMethod.card:
        return [
          TextFormField(
            key: const Key('cardNumberField'),
            controller: _cardNumberController,
            decoration: const InputDecoration(labelText: 'Card number', border: border),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d ]')), LengthLimitingTextInputFormatter(23)],
            autofillHints: const [AutofillHints.creditCardNumber],
            validator: validateCardNumber,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  key: const Key('expiryField'),
                  controller: _expiryController,
                  decoration: const InputDecoration(labelText: 'Expiry (MM/YY)', border: border),
                  keyboardType: TextInputType.datetime,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d/]')), LengthLimitingTextInputFormatter(5)],
                  validator: validateExpiry,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  key: const Key('cvvField'),
                  controller: _cvvController,
                  decoration: const InputDecoration(labelText: 'CVV', border: border),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                  validator: validateCvv,
                ),
              ),
            ],
          ),
        ];
      case PaymentMethod.netBanking:
        return [
          DropdownButtonFormField<String>(
            key: const Key('bankField'),
            value: _bank,
            decoration: const InputDecoration(labelText: 'Bank', border: border),
            items: [for (final bank in _banks) DropdownMenuItem(value: bank, child: Text(bank))],
            onChanged: (v) => setState(() => _bank = v),
            validator: (v) => v == null ? 'Please choose your bank' : null,
          ),
        ];
    }
  }
}
