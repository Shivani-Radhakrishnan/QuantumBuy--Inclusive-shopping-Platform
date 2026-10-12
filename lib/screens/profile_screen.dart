import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../routes.dart';
import '../utils/validators.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _pickImage(BuildContext context) async {
    final user = context.read<UserModel>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 512);
      if (picked != null) await user.updateProfile(profilePicture: picked.path);
    } catch (e) {
      debugPrint('Image picker failed: $e');
      messenger.showSnackBar(const SnackBar(content: Text('Could not open your photo library.')));
    }
  }

  Future<void> _edit(
    BuildContext context, {
    required String title,
    required String? initial,
    required String? Function(String?) validator,
    required Future<void> Function(String value) onSave,
    TextInputType? keyboardType,
  }) async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => _EditDialog(title: title, initial: initial, validator: validator, keyboardType: keyboardType),
    );
    if (value != null) await onSave(value);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserModel>();
    final theme = Theme.of(context);
    final loggedIn = user.isLoggedIn;
    final picture = user.profilePicture;
    final ImageProvider avatar = (picture != null && !kIsWeb && File(picture).existsSync())
        ? FileImage(File(picture))
        : const AssetImage('assets/default_profile.png');

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Semantics(
              button: loggedIn,
              label: loggedIn ? 'Profile photo. Double tap to change' : 'Profile photo',
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: loggedIn ? () => _pickImage(context) : null,
                child: CircleAvatar(radius: 60, backgroundImage: avatar),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            loggedIn ? (user.userName ?? '') : 'Guest',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          if (loggedIn && user.email != null)
            Text(user.email!, textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          const Divider(),
          if (loggedIn) ...[
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(user.phoneNumber ?? 'Add phone number'),
              trailing: const Icon(Icons.edit, semanticLabel: 'Edit'),
              onTap: () => _edit(
                context,
                title: 'Phone number',
                initial: user.phoneNumber,
                validator: validatePhone,
                keyboardType: TextInputType.phone,
                onSave: (v) => user.updateProfile(phoneNumber: v),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: Text(user.address ?? 'Add delivery address'),
              trailing: const Icon(Icons.edit, semanticLabel: 'Edit'),
              onTap: () => _edit(
                context,
                title: 'Delivery address',
                initial: user.address,
                validator: (v) => requiredField(v, 'an address'),
                keyboardType: TextInputType.streetAddress,
                onSave: (v) => user.updateProfile(address: v),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                user.logout();
                Navigator.pushNamedAndRemoveUntil(context, Routes.login, (_) => false);
              },
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
            ),
          ] else
            FilledButton.icon(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, Routes.login, (_) => false),
              icon: const Icon(Icons.login),
              label: const Text('Log in'),
            ),
        ],
      ),
    );
  }
}

class _EditDialog extends StatefulWidget {
  const _EditDialog({required this.title, required this.initial, required this.validator, this.keyboardType});

  final String title;
  final String? initial;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;

  @override
  State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) Navigator.pop(context, _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          keyboardType: widget.keyboardType,
          decoration: InputDecoration(labelText: widget.title),
          validator: widget.validator,
          onFieldSubmitted: (_) => _save(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
