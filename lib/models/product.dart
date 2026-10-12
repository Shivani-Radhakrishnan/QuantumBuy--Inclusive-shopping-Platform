/// A product in the catalogue. Immutable: how many are in the cart is kept
/// by [CartModel], not on the product.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.description,
  });

  final int id;
  final String name;
  final String imageUrl;
  final double price;
  final String description;

  @override
  bool operator ==(Object other) => other is Product && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Product($id, $name)';
}
