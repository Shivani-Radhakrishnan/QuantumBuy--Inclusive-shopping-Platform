import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:palette_generator/palette_generator.dart';
import 'product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Map<Color, Offset> colorPositions = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _analyzeImage();
    });
  }

  Future<void> _analyzeImage() async {
    final product = ModalRoute.of(context)!.settings.arguments as Product;
    final imageProvider = AssetImage(product.imageUrl);

    final analyzer = ColorAnalyzer(imageProvider);
    final results = await analyzer.extractColorsWithPositions();

    setState(() {
      colorPositions = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Product product = ModalRoute.of(context)!.settings.arguments as Product;

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Center(
        child: Stack(
          children: [
            Image.asset(
              product.imageUrl,
              width: 300,
              height: 300,
              fit: BoxFit.cover,
            ),
            if (colorPositions.isNotEmpty)
              CustomPaint(
                size: const Size(300, 300),
                painter: ColorArrowPainter(colorPositions: colorPositions),
              ),
          ],
        ),
      ),
    );
  }
}

class ColorArrowPainter extends CustomPainter {
  final Map<Color, Offset> colorPositions;

  ColorArrowPainter({required this.colorPositions});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final textStyle = const TextStyle(
      color: Colors.black,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );

    colorPositions.forEach((color, position) {
      // Adjust positions to fit the image size if needed
      final adjustedPosition = Offset(
        position.dx * size.width,
        position.dy * size.height,
      );

      // Draw arrow line
      paint.color = Colors.black;
      canvas.drawLine(adjustedPosition, adjustedPosition.translate(30, -30), paint);

      // Draw circle
      paint.color = color;
      canvas.drawCircle(adjustedPosition, 5, paint);

      // Draw text
      final textSpan = TextSpan(
        text: 'RGB(${color.red}, ${color.green}, ${color.blue})',
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, adjustedPosition.translate(40, -40));
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class ColorAnalyzer {
  final ImageProvider imageProvider;

  ColorAnalyzer(this.imageProvider);

  Future<Map<Color, Offset>> extractColorsWithPositions() async {
    final ImageStream imageStream = imageProvider.resolve(const ImageConfiguration());
    final Completer<Map<Color, Offset>> completer = Completer();

    imageStream.addListener(
      ImageStreamListener((ImageInfo info, bool _) async {
        final ByteData? byteData = await info.image.toByteData(format: ImageByteFormat.rawRgba);
        if (byteData == null) {
          completer.complete({});
          return;
        }

        final Uint8List bytes = byteData.buffer.asUint8List();
        final img.Image image = img.Image.fromBytes(info.image.width, info.image.height, bytes);

        final Map<Color, List<Offset>> colorPositions = {};
        for (int y = 0; y < image.height; y += 5) { // Sample every 5th pixel for speed
          for (int x = 0; x < image.width; x += 5) {
            final pixel = image.getPixel(x, y);
            final color = Color.fromARGB(
              (pixel >> 24) & 0xFF,
              (pixel >> 16) & 0xFF,
              (pixel >> 8) & 0xFF,
              pixel & 0xFF,
            );

            if (!colorPositions.containsKey(color)) {
              colorPositions[color] = [];
            }
            colorPositions[color]!.add(Offset(x.toDouble(), y.toDouble()));
          }
        }

        final Map<Color, Offset> dominantColorsWithPositions = {};
        colorPositions.forEach((color, positions) {
          final averageX = positions.map((p) => p.dx).reduce((a, b) => a + b) / positions.length;
          final averageY = positions.map((p) => p.dy).reduce((a, b) => a + b) / positions.length;
          dominantColorsWithPositions[color] = Offset(averageX, averageY);
        });

        completer.complete(dominantColorsWithPositions);
      }),
    );

    return completer.future;
  }
}
