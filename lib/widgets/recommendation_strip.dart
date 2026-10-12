import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/product_catalog.dart';
import '../models/product.dart';
import '../routes.dart';
import 'product_image.dart';

/// A titled, horizontally scrolling row of recommended products.
///
/// [load] returns product ids, or null when recommendations are unavailable,
/// in which case [fallback] is shown (or nothing, if it is null or empty).
class RecommendationStrip extends StatefulWidget {
  const RecommendationStrip({super.key, required this.title, required this.load, this.fallback});

  final String title;
  final Future<List<int>?> Function() load;
  final List<Product> Function()? fallback;

  @override
  State<RecommendationStrip> createState() => _RecommendationStripState();
}

class _RecommendationStripState extends State<RecommendationStrip> {
  late final Future<List<int>?> _future = widget.load();

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ProductRepository>();
    return FutureBuilder<List<int>?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();
        final ids = snapshot.data;
        final products = ids != null
            ? [for (final id in ids) if (repo.byId(id) case final p?) p]
            : (widget.fallback?.call() ?? const <Product>[]);
        if (products.isEmpty) return const SizedBox.shrink();
        final theme = Theme.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Semantics(header: true, child: Text(widget.title, style: theme.textTheme.titleMedium)),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final p = products[i];
                  return InkWell(
                    onTap: () => Navigator.pushNamed(context, Routes.productDetail, arguments: p),
                    child: SizedBox(
                      width: 100,
                      child: Column(
                        children: [
                          ProductImage(product: p, size: 100),
                          const SizedBox(height: 4),
                          Text(p.name, maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
