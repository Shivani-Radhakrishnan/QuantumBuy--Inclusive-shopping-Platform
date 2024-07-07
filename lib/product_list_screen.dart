import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_model.dart';
import 'product_model.dart';

class ProductListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final category = ModalRoute.of(context)!.settings.arguments as String;

    // Example products for different categories
    final products = {
      'Electronics': [
        Product(id: 1, name: 'Smartphone', price: 10000.0, imageUrl: 'assets/smartphone.jpg'),
        Product(id: 2, name: 'Laptop', price: 50000.0, imageUrl: 'assets/laptop.jpg'),
      ],
      'Clothing and Accessories': [
        Product(id: 3, name: 'T-shirt', price: 500.0, imageUrl: 'assets/tshirt.jpg'),
        Product(id: 4, name: 'Jeans', price: 1200.0, imageUrl: 'assets/jeans.jpg'),
      ],
      'Home and Kitchen': [
        Product(id: 5, name: 'Mixer', price: 2000.0, imageUrl: 'assets/mixer.jpg'),
        Product(id: 6, name: 'Cookware', price: 3000.0, imageUrl: 'assets/cookware.jpg'),
      ],
      'Beauty and Personal Care': [
        Product(id: 7, name: 'Shampoo', price: 200.0, imageUrl: 'assets/shampoo.jpg'),
        Product(id: 8, name: 'Face Cream', price: 400.0, imageUrl: 'assets/face_cream.jpg'),
      ],
      'Groceries and Gourmet Food': [
        Product(id: 9, name: 'Rice', price: 50.0, imageUrl: 'assets/rice.jpg'),
        Product(id: 10, name: 'Olive Oil', price: 300.0, imageUrl: 'assets/olive_oil.jpg'),
      ],
    }[category]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final cartModel = Provider.of<CartModel>(context);

          int itemCountInCart = cartModel.getItemCount(product.id);

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(product.imageUrl),
            ),
            title: Text(product.name),
            subtitle: Text('₹${product.price.toStringAsFixed(2)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (itemCountInCart > 0) ...[
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      cartModel.removeItem(product);
                    },
                  ),
                  Text('$itemCountInCart'),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      cartModel.addItem(product);
                    },
                  ),
                ] else ...[
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      cartModel.addItem(product);
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
