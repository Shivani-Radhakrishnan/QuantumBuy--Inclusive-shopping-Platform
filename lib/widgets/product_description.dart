import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/settings_model.dart';
import '../services/text_simplifier.dart';

/// The description to show for [product], shortened when "Simplified text" is on.
String displayDescription(Product product, SettingsModel settings) => settings.isSimplifiedTextEnabled
    ? simplifyDescription(product.description)
    : product.description;

/// A product description that follows the "Simplified text" setting.
class ProductDescription extends StatelessWidget {
  const ProductDescription(this.product, {super.key, this.style, this.maxLines});

  final Product product;
  final TextStyle? style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();
    return Text(
      displayDescription(product, settings),
      style: style,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    );
  }
}
