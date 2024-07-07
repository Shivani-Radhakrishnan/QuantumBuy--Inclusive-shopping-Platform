import 'package:flutter/foundation.dart';
import 'product_model.dart'; // Ensure this import statement is correct

class CartModel extends ChangeNotifier {
  List<Product> _items = [];

  List<Product> get items => _items;

  void addItem(Product product) {
    int index = _items.indexWhere((item) => item.id == product.id);
    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(Product(
        id: product.id,
        name: product.name,
        price: product.price,
        imageUrl: product.imageUrl,
        quantity: 1,
      ));
    }
    notifyListeners();
  }

  void removeItem(Product product) {
    int index = _items.indexWhere((item) => item.id == product.id);
    if (index != -1) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  int getItemCount(int productId) {
    int index = _items.indexWhere((item) => item.id == productId);
    return index != -1 ? _items[index].quantity : 0;
  }

  double getTotalCost() {
    double total = 0;
    for (var item in _items) {
      total += item.price * item.quantity;
    }
    return total;
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
