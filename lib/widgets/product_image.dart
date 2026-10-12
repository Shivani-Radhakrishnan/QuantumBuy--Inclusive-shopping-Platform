import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/settings_model.dart';

/// Alt text for a product photo. With the "Alt text for images" setting on,
/// it includes the product description as well as the name.
String productAltText(Product product, {required bool detailed}) =>
    detailed ? 'Photo of ${product.name}. ${product.description}' : 'Photo of ${product.name}';

/// A product photo with a screen-reader label.
///
/// With "Alt text for images" on, the label is more detailed and, when
/// [showCaption] is true, the alt text is also shown under the image for
/// sighted users who find photos hard to make out.
class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.product,
    required this.size,
    this.circle = false,
    this.showCaption = false,
    this.fit = BoxFit.cover,
  });

  final Product product;
  final double size;
  final bool circle;
  final bool showCaption;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final altTextOn = context.watch<SettingsModel>().isAltTextEnabled;
    final alt = productAltText(product, detailed: altTextOn);

    Widget image = Image.asset(
      product.imageUrl,
      width: size,
      height: size,
      fit: fit,
      semanticLabel: alt,
      errorBuilder: (context, error, stack) => SizedBox(
        width: size,
        height: size,
        child: Icon(Icons.image_not_supported_outlined, size: size / 2, semanticLabel: alt),
      ),
    );
    image = circle ? ClipOval(child: image) : ClipRRect(borderRadius: BorderRadius.circular(8), child: image);

    if (!(showCaption && altTextOn)) return image;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        image,
        const SizedBox(height: 4),
        SizedBox(
          width: size,
          child: ExcludeSemantics(
            // The image label already says this; don't read it twice.
            child: Text(
              alt,
              key: const Key('altTextCaption'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ],
    );
  }
}
