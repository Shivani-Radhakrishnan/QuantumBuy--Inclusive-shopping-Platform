import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/product_catalog.dart';
import '../routes.dart';
import '../widgets/voice_shortcut_button.dart';

const Map<String, IconData> _categoryIcons = {
  'Electronics': Icons.electrical_services,
  'Clothing and Accessories': Icons.shopping_bag,
  'Home and Kitchen': Icons.kitchen,
  'Beauty and Personal Care': Icons.brush,
  'Groceries and Gourmet Food': Icons.local_grocery_store,
};

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<ProductRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: const VoiceShortcutButton(),
      body: GridView.extent(
        maxCrossAxisExtent: 240,
        padding: const EdgeInsets.all(8),
        children: [
          for (final category in repository.categories)
            _CategoryTile(
              category: category,
              icon: _categoryIcons[category] ?? Icons.storefront,
              productCount: repository.productsIn(category).length,
            ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.icon, required this.productCount});

  final String category;
  final IconData icon;
  final int productCount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, Routes.productList, arguments: category),
        child: Semantics(
          button: true,
          label: '$category, $productCount products',
          excludeSemantics: true,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 64, color: colors.onSurface),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    category,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
