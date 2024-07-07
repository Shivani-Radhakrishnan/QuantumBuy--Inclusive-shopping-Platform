import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.electrical_services),
            title: Text('Electronics'),
            onTap: () {
              Navigator.pushNamed(context, '/productList', arguments: 'Electronics');
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_bag),
            title: Text('Clothing and Accessories'),
            onTap: () {
              Navigator.pushNamed(context, '/productList', arguments: 'Clothing and Accessories');
            },
          ),
          ListTile(
            leading: Icon(Icons.kitchen),
            title: Text('Home and Kitchen'),
            onTap: () {
              Navigator.pushNamed(context, '/productList', arguments: 'Home and Kitchen');
            },
          ),
          ListTile(
            leading: Icon(Icons.brush),
            title: Text('Beauty and Personal Care'),
            onTap: () {
              Navigator.pushNamed(context, '/productList', arguments: 'Beauty and Personal Care');
            },
          ),
          ListTile(
            leading: Icon(Icons.local_grocery_store),
            title: Text('Groceries and Gourmet Food'),
            onTap: () {
              Navigator.pushNamed(context, '/productList', arguments: 'Groceries and Gourmet Food');
            },
          ),
        ],
      ),
    );
  }
}
