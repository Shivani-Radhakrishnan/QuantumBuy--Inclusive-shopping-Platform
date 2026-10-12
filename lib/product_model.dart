
class Product {
  final int id; // Add this field
  final String name;
  final String imageUrl;
  final double price;
   int quantity;
  final String description; // Add this field

  Product({
    required this.id, // Initialize this field
    required this.name,
    required this.imageUrl,
    required this.price,
    this.quantity=1,
    required this.description, // Initialize this field
  });
}
