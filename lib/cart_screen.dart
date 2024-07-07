import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_model.dart';
import 'product_model.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Consumer<CartModel>(
        builder: (context, cart, child) {
          return ListView.builder(
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              Product product = cart.items[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(product.imageUrl),
                ),
                title: Text(product.name),
                subtitle: Text('₹${product.price.toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        Provider.of<CartModel>(context, listen: false).removeItem(product);
                      },
                    ),
                    Text('${product.quantity}x'),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        Provider.of<CartModel>(context, listen: false).addItem(product);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Consumer<CartModel>(
        builder: (context, cart, child) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ₹${cart.getTotalCost().toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/checkout');
                  },
                  child: Text('Checkout'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
