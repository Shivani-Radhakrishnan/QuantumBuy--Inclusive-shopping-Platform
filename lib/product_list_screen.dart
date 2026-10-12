import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_model.dart';
import 'product_model.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final category = ModalRoute.of(context)!.settings.arguments as String;

    // Expanded product list for different categories
    final products = {
  'Electronics': [
    Product(id: 1, name: 'Smartphone', price: 10000.0, imageUrl: 'assets/electronics/smartphone.jpg', description: 'Latest model with high-end features.'),
    Product(id: 2, name: 'Laptop', price: 50000.0, imageUrl: 'assets/electronics/laptop.jpg', description: 'High-performance laptop for gaming and work.'),
    Product(id: 3, name: 'Smart TV', price: 40000.0, imageUrl: 'assets/electronics/smart_tv.jpg', description: 'Ultra HD Smart TV with multiple streaming apps.'),
    Product(id: 4, name: 'Headphones', price: 2000.0, imageUrl: 'assets/electronics/headphones.jpg', description: 'Noise-cancelling headphones with excellent sound quality.'),
    Product(id: 5, name: 'Camera', price: 25000.0, imageUrl: 'assets/electronics/camera.jpg', description: 'DSLR camera with high-resolution image capture.'),
    Product(id: 6, name: 'Smartwatch', price: 8000.0, imageUrl: 'assets/electronics/smartwatch.jpg', description: 'Wearable smartwatch with fitness tracking capabilities.'),
    Product(id: 7, name: 'Bluetooth Speaker', price: 1500.0, imageUrl: 'assets/electronics/bluetooth_speaker.jpg', description: 'Portable Bluetooth speaker with powerful sound.'),
    Product(id: 8, name: 'Tablet', price: 25000.0, imageUrl: 'assets/electronics/tablet.jpg', description: 'High-resolution tablet for entertainment and work.'),
    Product(id: 9, name: 'Smart Thermostat', price: 10000.0, imageUrl: 'assets/electronics/smart_thermostat.jpg', description: 'Smart thermostat for energy-efficient climate control.'),
    Product(id: 10, name: 'External Hard Drive', price: 5000.0, imageUrl: 'assets/electronics/external_hard_drive.jpg', description: 'High-capacity external hard drive for data storage.'),
    Product(id: 11, name: '4K Monitor', price: 15000.0, imageUrl: 'assets/electronics/4k_monitor.jpg', description: '4K monitor with exceptional color accuracy.'),
    Product(id: 12, name: 'Digital Camera', price: 35000.0, imageUrl: 'assets/electronics/digital_camera.jpg', description: 'Professional digital camera for high-quality photography.'),
    Product(id: 13, name: 'Game Console', price: 30000.0, imageUrl: 'assets/electronics/game_console.jpg', description: 'Latest game console with a wide range of games.'),
    Product(id: 14, name: 'Wireless Charger', price: 2000.0, imageUrl: 'assets/electronics/wireless_charger.jpg', description: 'Convenient wireless charger for quick and easy charging.'),
    Product(id: 15, name: 'Action Camera', price: 15000.0, imageUrl: 'assets/electronics/action_camera.jpg', description: 'Compact action camera for capturing adventures.'),
    Product(id: 16, name: 'Home Theater System', price: 60000.0, imageUrl: 'assets/electronics/home_theater.jpg', description: 'Complete home theater system with surround sound.'),
    Product(id: 17, name: 'Smart Doorbell', price: 8000.0, imageUrl: 'assets/electronics/smart_doorbell.jpg', description: 'Smart doorbell with video and audio capabilities.'),
    Product(id: 18, name: 'Digital Photo Frame', price: 4000.0, imageUrl: 'assets/electronics/digital_photo_frame.jpg', description: 'Digital photo frame with high-resolution display.'),
    Product(id: 19, name: 'Projector', price: 20000.0, imageUrl: 'assets/electronics/projector.jpg', description: 'Projector for home theater or presentations.'),
    Product(id: 20, name: 'Electric Toothbrush', price: 3000.0, imageUrl: 'assets/electronics/electric_toothbrush.jpg', description: 'Electric toothbrush with multiple cleaning modes.'),
  ],
  'Clothing and Accessories': [
    Product(id: 1, name: 'T-shirt', price: 500.0, imageUrl: 'assets/clothing/tshirt.jpg', description: 'Comfortable cotton t-shirt available in various colors.'),
    Product(id: 2, name: 'Jeans', price: 1200.0, imageUrl: 'assets/clothing/jeans.jpg', description: 'Stylish jeans with a perfect fit.'),
    Product(id: 3, name: 'Jacket', price: 3000.0, imageUrl: 'assets/clothing/jacket.jpg', description: 'Warm and trendy jacket for winter.'),
    Product(id: 4, name: 'Sunglasses', price: 1500.0, imageUrl: 'assets/clothing/sunglasses.jpg', description: 'Fashionable sunglasses with UV protection.'),
    Product(id: 5, name: 'Watch', price: 5000.0, imageUrl: 'assets/clothing/watch.jpg', description: 'Elegant watch with a classic design.'),
    Product(id: 6, name: 'Sneakers', price: 2500.0, imageUrl: 'assets/clothing/sneakers.jpg', description: 'Comfortable sneakers for everyday wear.'),
    Product(id: 7, name: 'Hat', price: 800.0, imageUrl: 'assets/clothing/hat.jpg', description: 'Stylish hat for sun protection and fashion.'),
    Product(id: 8, name: 'Scarf', price: 1000.0, imageUrl: 'assets/clothing/scarf.jpg', description: 'Warm and soft scarf for cold weather.'),
    Product(id: 9, name: 'Sweater', price: 2000.0, imageUrl: 'assets/clothing/sweater.jpg', description: 'Cozy sweater for casual wear.'),
    Product(id: 10, name: 'Shorts', price: 700.0, imageUrl: 'assets/clothing/shorts.jpg', description: 'Comfortable shorts for summer.'),
    Product(id: 11, name: 'Blouse', price: 1200.0, imageUrl: 'assets/clothing/blouse.jpg', description: 'Elegant blouse for formal occasions.'),
    Product(id: 12, name: 'Cardigan', price: 1800.0, imageUrl: 'assets/clothing/cardigan.jpg', description: 'Stylish cardigan for layering.'),
    Product(id: 13, name: 'Belt', price: 500.0, imageUrl: 'assets/clothing/belt.jpg', description: 'Durable belt for everyday use.'),
    Product(id: 14, name: 'Dress', price: 2500.0, imageUrl: 'assets/clothing/dress.jpg', description: 'Beautiful dress for special events.'),
    Product(id: 15, name: 'Socks', price: 300.0, imageUrl: 'assets/clothing/socks.jpg', description: 'Comfortable socks available in various sizes.'),
    Product(id: 16, name: 'Gloves', price: 600.0, imageUrl: 'assets/clothing/gloves.jpg', description: 'Warm gloves for winter.'),
    Product(id: 17, name: 'Tie', price: 400.0, imageUrl: 'assets/clothing/tie.jpg', description: 'Elegant tie for formal occasions.'),
    Product(id: 18, name: 'Raincoat', price: 1500.0, imageUrl: 'assets/clothing/raincoat.jpg', description: 'Waterproof raincoat for rainy days.'),
    Product(id: 19, name: 'Pants', price: 1400.0, imageUrl: 'assets/clothing/pants.jpg', description: 'Comfortable pants for casual or formal wear.'),
    Product(id: 20, name: 'Overalls', price: 2200.0, imageUrl: 'assets/clothing/overalls.jpg', description: 'Durable overalls for work or casual wear.'),
  ],
  'Home and Kitchen': [
    Product(id: 1, name: 'Mixer', price: 1500.0, imageUrl: 'assets/home_kitchen/mixer.jpg', description: 'High-power mixer for efficient blending.'),
    Product(id: 2, name: 'Cookware Set', price: 7000.0, imageUrl: 'assets/home_kitchen/cookware.jpg', description: 'Complete cookware set for all your cooking needs.'),
    Product(id: 3, name: 'Vacuum Cleaner', price: 4000.0, imageUrl: 'assets/home_kitchen/vacuum_cleaner.jpg', description: 'Powerful vacuum cleaner for home cleaning.'),
    Product(id: 4, name: 'Refrigerator', price: 20000.0, imageUrl: 'assets/home_kitchen/refrigerator.jpg', description: 'Energy-efficient refrigerator with ample storage.'),
    Product(id: 5, name: 'Microwave', price: 3000.0, imageUrl: 'assets/home_kitchen/microwave.jpg', description: 'Microwave oven for quick and easy cooking.'),
    Product(id: 6, name: 'Blender', price: 1200.0, imageUrl: 'assets/home_kitchen/blender.jpg', description: 'Versatile blender for smoothies and soups.'),
    Product(id: 7, name: 'Toaster', price: 800.0, imageUrl: 'assets/home_kitchen/toaster.jpg', description: 'Toaster with multiple settings for perfect toast.'),
    Product(id: 8, name: 'Coffee Maker', price: 1500.0, imageUrl: 'assets/home_kitchen/coffee_maker.jpg', description: 'Coffee maker for brewing fresh coffee.'),
    Product(id: 9, name: 'Electric Kettle', price: 700.0, imageUrl: 'assets/home_kitchen/electric_kettle.jpg', description: 'Electric kettle for boiling water quickly.'),
    Product(id: 10, name: 'Dishwasher', price: 12000.0, imageUrl: 'assets/home_kitchen/dishwasher.jpg', description: 'Dishwasher for convenient dish cleaning.'),
    Product(id: 11, name: 'Air Purifier', price: 5000.0, imageUrl: 'assets/home_kitchen/air_purifier.jpg', description: 'Air purifier for cleaner and fresher air.'),
    Product(id: 12, name: 'Cooktop', price: 6000.0, imageUrl: 'assets/home_kitchen/cooktop.jpg', description: 'Cooktop with multiple burners for efficient cooking.'),
    Product(id: 13, name: 'Oven', price: 10000.0, imageUrl: 'assets/home_kitchen/oven.jpg', description: 'Oven for baking and roasting.'),
    Product(id: 14, name: 'Washing Machine', price: 15000.0, imageUrl: 'assets/home_kitchen/washing_machine.jpg', description: 'Washing machine for easy laundry.'),
    Product(id: 15, name: 'Deep Fryer', price: 2000.0, imageUrl: 'assets/home_kitchen/deep_fryer.jpg', description: 'Deep fryer for cooking crispy fried foods.'),
    Product(id: 16, name: 'Slow Cooker', price: 2500.0, imageUrl: 'assets/home_kitchen/slow_cooker.jpg', description: 'Slow cooker for making delicious stews and soups.'),
    Product(id: 17, name: 'Juicer', price: 1800.0, imageUrl: 'assets/home_kitchen/juicer.jpg', description: 'Juicer for extracting fresh juices.'),
    Product(id: 18, name: 'Rice Cooker', price: 1500.0, imageUrl: 'assets/home_kitchen/rice_cooker.jpg', description: 'Rice cooker for perfectly cooked rice.'),
    Product(id: 19, name: 'Stand Mixer', price: 5000.0, imageUrl: 'assets/home_kitchen/stand_mixer.jpg', description: 'Stand mixer for baking and cooking.'),
    Product(id: 20, name: 'Induction Cooker', price: 4000.0, imageUrl: 'assets/home_kitchen/induction_cooker.jpg', description: 'Induction cooker for fast and efficient cooking.'),
  ],
  'Beauty and Personal Care': [
    Product(id: 1, name: 'Shampoo', price: 500.0, imageUrl: 'assets/beauty_personal_care/shampoo.jpg', description: 'Nourishing shampoo for healthy hair.'),
    Product(id: 2, name: 'Face Cream', price: 800.0, imageUrl: 'assets/beauty_personal_care/face_cream.jpg', description: 'Moisturizing face cream for glowing skin.'),
    Product(id: 3, name: 'Perfume', price: 1500.0, imageUrl: 'assets/beauty_personal_care/perfume.jpg', description: 'Fragrant perfume with a long-lasting scent.'),
    Product(id: 4, name: 'Lipstick', price: 600.0, imageUrl: 'assets/beauty_personal_care/lipstick.jpg', description: 'Vibrant lipstick in various shades.'),
    Product(id: 5, name: 'Hair Dryer', price: 1000.0, imageUrl: 'assets/beauty_personal_care/hair_dryer.jpg', description: 'Powerful hair dryer for quick drying.'),
    Product(id: 6, name: 'Body Lotion', price: 700.0, imageUrl: 'assets/beauty_personal_care/body_lotion.jpg', description: 'Hydrating body lotion for soft skin.'),
    Product(id: 7, name: 'Face Wash', price: 400.0, imageUrl: 'assets/beauty_personal_care/face_wash.jpg', description: 'Gentle face wash for daily use.'),
    Product(id: 8, name: 'Eye Cream', price: 800.0, imageUrl: 'assets/beauty_personal_care/eye_cream.jpg', description: 'Eye cream for reducing dark circles.'),
    Product(id: 9, name: 'Nail Polish', price: 300.0, imageUrl: 'assets/beauty_personal_care/nail_polish.jpg', description: 'Colorful nail polish for manicured nails.'),
    Product(id: 10, name: 'Sunscreen', price: 600.0, imageUrl: 'assets/beauty_personal_care/sunscreen.jpg', description: 'Sunscreen for protecting skin from UV rays.'),
    Product(id: 11, name: 'Deodorant', price: 350.0, imageUrl: 'assets/beauty_personal_care/deodorant.jpg', description: 'Deodorant for all-day freshness.'),
    Product(id: 12, name: 'Hand Cream', price: 400.0, imageUrl: 'assets/beauty_personal_care/hand_cream.jpg', description: 'Moisturizing hand cream for soft hands.'),
    Product(id: 13, name: 'Face Mask', price: 700.0, imageUrl: 'assets/beauty_personal_care/face_mask.jpg', description: 'Face mask for deep cleansing.'),
    Product(id: 14, name: 'Hair Serum', price: 900.0, imageUrl: 'assets/beauty_personal_care/hair_serum.jpg', description: 'Hair serum for smooth and shiny hair.'),
    Product(id: 15, name: 'Makeup Remover', price: 500.0, imageUrl: 'assets/beauty_personal_care/makeup_remover.jpg', description: 'Makeup remover for gentle cleansing.'),
    Product(id: 16, name: 'Eyebrow Pencil', price: 300.0, imageUrl: 'assets/beauty_personal_care/eyebrow_pencil.jpg', description: 'Eyebrow pencil for defined brows.'),
    Product(id: 17, name: 'Body Scrub', price: 800.0, imageUrl: 'assets/beauty_personal_care/body_scrub.jpg', description: 'Exfoliating body scrub for smooth skin.'),
    Product(id: 18, name: 'Face Toner', price: 600.0, imageUrl: 'assets/beauty_personal_care/face_toner.jpg', description: 'Face toner for balanced skin.'),
    Product(id: 19, name: 'Hair Brush', price: 400.0, imageUrl: 'assets/beauty_personal_care/hair_brush.jpg', description: 'Hair brush for detangling and styling.'),
    Product(id: 20, name: 'Shaving Kit', price: 1000.0, imageUrl: 'assets/beauty_personal_care/shaving_kit.jpg', description: 'Complete shaving kit for a smooth shave.'),
  ],
  'Groceries and Gourmet Food': [
    Product(id: 1, name: 'Rice', price: 1000.0, imageUrl: 'assets/groceries/rice.jpg', description: 'Premium quality rice for daily use.'),
    Product(id: 2, name: 'Olive Oil', price: 600.0, imageUrl: 'assets/groceries/olive_oil.jpg', description: 'Extra virgin olive oil for cooking and dressing.'),
    Product(id: 3, name: 'Pasta', price: 300.0, imageUrl: 'assets/groceries/pasta.jpg', description: 'Delicious pasta in various shapes.'),
    Product(id: 4, name: 'Honey', price: 500.0, imageUrl: 'assets/groceries/honey.jpg', description: 'Natural honey with a rich flavor.'),
    Product(id: 5, name: 'Spices Set', price: 800.0, imageUrl: 'assets/groceries/spices_set.jpg', description: 'Variety of spices for enhanced flavors.'),
    Product(id: 6, name: 'Cereal', price: 400.0, imageUrl: 'assets/groceries/cereal.jpg', description: 'Nutritious cereal for a quick breakfast.'),
    Product(id: 7, name: 'Canned Beans', price: 250.0, imageUrl: 'assets/groceries/canned_beans.jpg', description: 'Canned beans for convenient cooking.'),
    Product(id: 8, name: 'Cooking Oil', price: 500.0, imageUrl: 'assets/groceries/cooking_oil.jpg', description: 'Versatile cooking oil for all dishes.'),
    Product(id: 9, name: 'Sugar', price: 300.0, imageUrl: 'assets/groceries/sugar.jpg', description: 'Granulated sugar for sweetening.'),
    Product(id: 10, name: 'Salt', price: 100.0, imageUrl: 'assets/groceries/salt.jpg', description: 'Pure salt for seasoning.'),
    Product(id: 11, name: 'Flour', price: 400.0, imageUrl: 'assets/groceries/flour.jpg', description: 'High-quality flour for baking and cooking.'),
    Product(id: 12, name: 'Milk', price: 200.0, imageUrl: 'assets/groceries/milk.jpg', description: 'Fresh milk for daily consumption.'),
    Product(id: 13, name: 'Tea', price: 300.0, imageUrl: 'assets/groceries/tea.jpg', description: 'Aromatic tea for a relaxing drink.'),
    Product(id: 14, name: 'Coffee', price: 500.0, imageUrl: 'assets/groceries/coffee.jpg', description: 'Rich coffee for a perfect brew.'),
    Product(id: 15, name: 'Chocolate', price: 250.0, imageUrl: 'assets/groceries/chocolate.jpg', description: 'Delicious chocolate in various flavors.'),
    Product(id: 16, name: 'Juice', price: 350.0, imageUrl: 'assets/groceries/juice.jpg', description: 'Refreshing juice with natural flavors.'),
    Product(id: 17, name: 'Biscuits', price: 150.0, imageUrl: 'assets/groceries/biscuits.jpg', description: 'Crunchy biscuits for a tasty snack.'),
    Product(id: 18, name: 'Frozen Vegetables', price: 400.0, imageUrl: 'assets/groceries/frozen_vegetables.jpg', description: 'Frozen vegetables for convenient cooking.'),
    Product(id: 19, name: 'Bread', price: 100.0, imageUrl: 'assets/groceries/bread.jpg', description: 'Fresh bread for daily meals.'),
    Product(id: 20, name: 'Yogurt', price: 250.0, imageUrl: 'assets/groceries/yogurt.jpg', description: 'Creamy yogurt in various flavors.'),
  ],
}[category] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          category,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final cartModel = Provider.of<CartModel>(context);

            int itemCountInCart = cartModel.getItemCount(product.id);

            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12.0),
                leading: CircleAvatar(
                  backgroundImage: AssetImage(product.imageUrl),
                  radius: 30,
                ),
                title: Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '₹${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (itemCountInCart > 0) ...[
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.red),
                        onPressed: () {
                          cartModel.removeItem(product);
                        },
                      ),
                      Text(
                        '$itemCountInCart',
                        style: const TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.green),
                        onPressed: () {
                          cartModel.addItem(product);
                        },
                      ),
                    ] else ...[
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.green),
                        onPressed: () {
                          cartModel.addItem(product);
                        },
                      ),
                    ],
                  ],
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/productDetail',
                    arguments: product,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}