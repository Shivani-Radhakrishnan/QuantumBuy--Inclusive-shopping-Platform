import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_model.dart';
import '../models/product.dart';
import '../models/settings_model.dart';
import '../routes.dart';
import '../services/colour_analysis.dart';
import '../services/speaker.dart';
import '../widgets/product_description.dart';
import '../widgets/product_image.dart';
import '../widgets/quantity_stepper.dart';
import '../widgets/voice_shortcut_button.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product, this.analyseColours = analyseImageColours});

  final Product product;

  /// Finds the image's main colours; replaceable in tests.
  final Future<List<DominantColour>> Function(ImageProvider provider, {int count}) analyseColours;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  static const double _imageSize = 280;

  List<DominantColour>? _colours;
  bool _colourError = false;

  Product get _product => widget.product;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.read<SettingsModel>().speaksProductDetails) _readAloud();
      _analyse();
    });
  }

  Future<void> _analyse() async {
    try {
      final colours = await widget.analyseColours(AssetImage(_product.imageUrl), count: 3);
      if (mounted) setState(() => _colours = colours);
    } catch (_) {
      if (mounted) setState(() => _colourError = true);
    }
  }

  void _readAloud() {
    final settings = context.read<SettingsModel>();
    final parts = [
      spokenProductSummary(_product.name, _product.price),
      displayDescription(_product, settings),
      if (_colours != null && _colours!.isNotEmpty) 'Main colours: ${_colours!.map((c) => c.name).join(', ')}.',
    ];
    context.read<Speaker>().speak(parts.join('. '));
  }

  void _addToCart() {
    context.read<CartModel>().addItem(_product);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('${_product.name} added to cart'),
        action: SnackBarAction(label: 'View cart', onPressed: () => Navigator.pushNamed(context, Routes.cart)),
      ));
    if (context.read<SettingsModel>().speaksProductDetails) {
      context.read<Speaker>().speak('${_product.name} added to cart');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inCart = context.select<CartModel, int>((cart) => cart.quantityOf(_product));
    final colours = _colours;

    return Scaffold(
      appBar: AppBar(
        title: Text(_product.name),
        actions: [
          IconButton(
            tooltip: 'Read product details aloud',
            icon: const Icon(Icons.volume_up),
            onPressed: _readAloud,
          ),
        ],
      ),
      floatingActionButton: const VoiceShortcutButton(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        children: [
          Center(
            child: Stack(
              children: [
                ProductImage(product: _product, size: _imageSize, showCaption: true),
                if (colours != null && colours.isNotEmpty)
                  ExcludeSemantics(
                    child: CustomPaint(
                      size: const Size(_imageSize, _imageSize),
                      painter: ColourMarkerPainter(
                        colours,
                        labelStyle: theme.textTheme.labelLarge!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(_product.name, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            formatPrice(_product.price),
            style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 12),
          ProductDescription(_product, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 16),
          Text('Main colours', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          if (_colourError)
            const Text('Colours could not be identified for this photo.')
          else if (colours == null)
            const Text('Finding colours...')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final colour in colours)
                  Chip(
                    avatar: CircleAvatar(backgroundColor: colour.color),
                    label: Text('${colour.name} ${(colour.share * 100).round()}%'),
                  ),
              ],
            ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _addToCart,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text(inCart == 0 ? 'Add to cart' : 'Add another ($inCart in cart)'),
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
              if (inCart > 0) QuantityStepper(product: _product),
            ],
          ),
        ],
      ),
    );
  }
}

/// Marks where each main colour appears on the photo, with its name.
class ColourMarkerPainter extends CustomPainter {
  ColourMarkerPainter(this.colours, {required this.labelStyle});

  final List<DominantColour> colours;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    for (final colour in colours) {
      final point = Offset(colour.position.dx * size.width, colour.position.dy * size.height);
      canvas.drawCircle(point, 9, Paint()..color = Colors.white);
      canvas.drawCircle(point, 7, Paint()..color = colour.color);
      canvas.drawCircle(
        point,
        9,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      final label = TextPainter(
        text: TextSpan(text: colour.name, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      // Keep the label inside the image.
      final dx = (point.dx + 14).clamp(0.0, size.width - label.width - 8);
      final dy = (point.dy - label.height / 2).clamp(0.0, size.height - label.height - 4);
      final box = Rect.fromLTWH(dx - 4, dy - 2, label.width + 8, label.height + 4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, const Radius.circular(4)),
        Paint()..color = Colors.black.withOpacity(0.75),
      );
      label.paint(canvas, Offset(dx, dy));
    }
  }

  @override
  bool shouldRepaint(ColourMarkerPainter oldDelegate) =>
      oldDelegate.colours != colours || oldDelegate.labelStyle != labelStyle;
}
