import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: GridView.count(
        crossAxisCount: 2, // Number of columns
        children: [
          _buildCategoryItem(
            context,
            Icons.electrical_services,
            'Electronics',
            '/productList',
            'Electronics',
          ),
          _buildCategoryItem(
            context,
            Icons.shopping_bag,
            'Clothing and Accessories',
            '/productList',
            'Clothing and Accessories',
          ),
          _buildCategoryItem(
            context,
            Icons.kitchen,
            'Home and Kitchen',
            '/productList',
            'Home and Kitchen',
          ),
          _buildCategoryItem(
            context,
            Icons.brush,
            'Beauty and Personal Care',
            '/productList',
            'Beauty and Personal Care',
          ),
          _buildCategoryItem(
            context,
            Icons.local_grocery_store,
            'Groceries and Gourmet Food',
            '/productList',
            'Groceries and Gourmet Food',
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, IconData icon, String label, String route, String arguments) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route, arguments: arguments);
      },
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80, // Increase the size of the icons
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
