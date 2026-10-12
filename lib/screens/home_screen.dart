import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_model.dart';
import '../models/settings_model.dart';
import '../routes.dart';
import '../widgets/voice_shortcut_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();
    final cartCount = context.select<CartModel, int>((cart) => cart.totalQuantity);
    // The photo background is dropped in dark and high-contrast modes so text
    // sits on a plain, high-contrast surface.
    final plainBackground = settings.isDarkMode || settings.isHighContrast;
    final colors = Theme.of(context).colorScheme;
    final foreground = plainBackground ? colors.onSurface : Colors.white;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: foreground,
        elevation: 0,
        shape: const Border(),
        actions: [
          IconButton(
            tooltip: 'Profile',
            iconSize: 32,
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, Routes.profile),
          ),
          IconButton(
            tooltip: 'Settings',
            iconSize: 32,
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, Routes.settings),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: const VoiceShortcutButton(),
      body: DecoratedBox(
        decoration: plainBackground
            ? BoxDecoration(color: colors.surface)
            : BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/background.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.35), BlendMode.darken),
                ),
              ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        'QuantumBuy',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.bold,
                          shadows: plainBackground
                              ? null
                              : const [Shadow(blurRadius: 8, color: Colors.black, offset: Offset(2, 2))],
                        ),
                      ),
                    ),
                    const SizedBox(height: 160),
                    _HomeButton(
                      icon: Icons.category,
                      label: 'Categories',
                      onPressed: () => Navigator.pushNamed(context, Routes.categories),
                    ),
                    const SizedBox(height: 20),
                    _HomeButton(
                      icon: Icons.shopping_cart,
                      label: cartCount == 0 ? 'Cart' : 'Cart ($cartCount)',
                      semanticsLabel: cartCount == 0
                          ? 'Cart, empty'
                          : 'Cart, $cartCount ${cartCount == 1 ? 'item' : 'items'}',
                      onPressed: () => Navigator.pushNamed(context, Routes.cart),
                    ),
                    const SizedBox(height: 20),
                    _HomeButton(
                      icon: Icons.mic,
                      label: 'Voice Order',
                      onPressed: () => Navigator.pushNamed(context, Routes.voiceOrder),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  const _HomeButton({required this.icon, required this.label, required this.onPressed, this.semanticsLabel});

  final IconData icon;
  final String label;
  final String? semanticsLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final highContrast = context.watch<SettingsModel>().isHighContrast;
    return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label, semanticsLabel: semanticsLabel),
        style: ElevatedButton.styleFrom(
          // In high contrast the theme's black/white button colours are used.
          backgroundColor: highContrast ? null : const Color(0xFFEDEFF4),
          foregroundColor: highContrast ? null : const Color(0xFF0D1B2A),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
    );
  }
}
