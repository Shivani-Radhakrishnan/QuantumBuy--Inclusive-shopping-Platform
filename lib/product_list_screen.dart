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
    Product(id: 1, name: 'Smartphone', price: 10000.0, imageUrl: 'assets/electronics/smartphone.jpg'),
    Product(id: 2, name: 'Laptop', price: 50000.0, imageUrl: 'assets/electronics/laptop.jpg'),
    Product(id: 3, name: 'Smart TV', price: 40000.0, imageUrl: 'assets/electronics/smart_tv.jpg'),
    Product(id: 4, name: 'Headphones', price: 2000.0, imageUrl: 'assets/electronics/headphones.jpg'),
    Product(id: 5, name: 'Camera', price: 25000.0, imageUrl: 'assets/electronics/camera.jpg'),
    Product(id: 6, name: 'Smartwatch', price: 8000.0, imageUrl: 'assets/electronics/smartwatch.jpg'),
    Product(id: 7, name: 'Bluetooth Speaker', price: 1500.0, imageUrl: 'assets/electronics/bluetooth_speaker.jpg'),
    Product(id: 8, name: 'Tablet', price: 25000.0, imageUrl: 'assets/electronics/tablet.jpg'),
    Product(id: 9, name: 'Smart Thermostat', price: 10000.0, imageUrl: 'assets/electronics/smart_thermostat.jpg'),
    Product(id: 10, name: 'External Hard Drive', price: 5000.0, imageUrl: 'assets/electronics/external_hard_drive.jpg'),
    Product(id: 11, name: '4K Monitor', price: 15000.0, imageUrl: 'assets/electronics/4k_monitor.jpg'),
    Product(id: 12, name: 'Digital Camera', price: 35000.0, imageUrl: 'assets/electronics/digital_camera.jpg'),
    Product(id: 13, name: 'Game Console', price: 30000.0, imageUrl: 'assets/electronics/game_console.jpg'),
    Product(id: 14, name: 'Wireless Charger', price: 2000.0, imageUrl: 'assets/electronics/wireless_charger.jpg'),
    Product(id: 15, name: 'Action Camera', price: 15000.0, imageUrl: 'assets/electronics/action_camera.jpg'),
    Product(id: 16, name: 'Home Theater System', price: 60000.0, imageUrl: 'assets/electronics/home_theater.jpg'),
    Product(id: 17, name: 'Smart Doorbell', price: 8000.0, imageUrl: 'assets/electronics/smart_doorbell.jpg'),
    Product(id: 18, name: 'Digital Photo Frame', price: 4000.0, imageUrl: 'assets/electronics/digital_photo_frame.jpg'),
    Product(id: 19, name: 'Projector', price: 20000.0, imageUrl: 'assets/electronics/projector.jpg'),
    Product(id: 20, name: 'Electric Toothbrush', price: 3000.0, imageUrl: 'assets/electronics/electric_toothbrush.jpg'),
  ],
  'Clothing and Accessories': [
    Product(id: 1, name: 'T-shirt', price: 500.0, imageUrl: 'assets/clothing/tshirt.jpg'),
    Product(id: 2, name: 'Jeans', price: 1200.0, imageUrl: 'assets/clothing/jeans.jpg'),
    Product(id: 3, name: 'Jacket', price: 3000.0, imageUrl: 'assets/clothing/jacket.jpg'),
    Product(id: 4, name: 'Sunglasses', price: 1500.0, imageUrl: 'assets/clothing/sunglasses.jpg'),
    Product(id: 5, name: 'Watch', price: 5000.0, imageUrl: 'assets/clothing/watch.jpg'),
    Product(id: 6, name: 'Sneakers', price: 2500.0, imageUrl: 'assets/clothing/sneakers.jpg'),
    Product(id: 7, name: 'Hat', price: 800.0, imageUrl: 'assets/clothing/hat.jpg'),
    Product(id: 8, name: 'Scarf', price: 1000.0, imageUrl: 'assets/clothing/scarf.jpg'),
    Product(id: 9, name: 'Sweater', price: 2000.0, imageUrl: 'assets/clothing/sweater.jpg'),
    Product(id: 10, name: 'Shorts', price: 700.0, imageUrl: 'assets/clothing/shorts.jpg'),
    Product(id: 11, name: 'Blouse', price: 1200.0, imageUrl: 'assets/clothing/blouse.jpg'),
    Product(id: 12, name: 'Cardigan', price: 1800.0, imageUrl: 'assets/clothing/cardigan.jpg'),
    Product(id: 13, name: 'Belt', price: 500.0, imageUrl: 'assets/clothing/belt.jpg'),
    Product(id: 14, name: 'Dress', price: 2500.0, imageUrl: 'assets/clothing/dress.jpg'),
    Product(id: 15, name: 'Socks', price: 300.0, imageUrl: 'assets/clothing/socks.jpg'),
    Product(id: 16, name: 'Gloves', price: 600.0, imageUrl: 'assets/clothing/gloves.jpg'),
    Product(id: 17, name: 'Tie', price: 400.0, imageUrl: 'assets/clothing/tie.jpg'),
    Product(id: 18, name: 'Raincoat', price: 1500.0, imageUrl: 'assets/clothing/raincoat.jpg'),
    Product(id: 19, name: 'Pants', price: 1400.0, imageUrl: 'assets/clothing/pants.jpg'),
    Product(id: 20, name: 'Overalls', price: 2200.0, imageUrl: 'assets/clothing/overalls.jpg'),
  ],
  'Home and Kitchen': [
    Product(id: 1, name: 'Mixer', price: 2000.0, imageUrl: 'assets/home_kitchen/mixer.jpg'),
    Product(id: 2, name: 'Cookware', price: 3000.0, imageUrl: 'assets/home_kitchen/cookware.jpg'),
    Product(id: 3, name: 'Vacuum Cleaner', price: 7000.0, imageUrl: 'assets/home_kitchen/vacuum_cleaner.jpg'),
    Product(id: 4, name: 'Refrigerator', price: 20000.0, imageUrl: 'assets/home_kitchen/refrigerator.jpg'),
    Product(id: 5, name: 'Microwave Oven', price: 10000.0, imageUrl: 'assets/home_kitchen/microwave.jpg'),
    Product(id: 6, name: 'Blender', price: 1500.0, imageUrl: 'assets/home_kitchen/blender.jpg'),
    Product(id: 7, name: 'Toaster', price: 1000.0, imageUrl: 'assets/home_kitchen/toaster.jpg'),
    Product(id: 8, name: 'Coffee Maker', price: 3000.0, imageUrl: 'assets/home_kitchen/coffee_maker.jpg'),
    Product(id: 9, name: 'Electric Kettle', price: 1200.0, imageUrl: 'assets/home_kitchen/electric_kettle.jpg'),
    Product(id: 10, name: 'Dishwasher', price: 25000.0, imageUrl: 'assets/home_kitchen/dishwasher.jpg'),
    Product(id: 11, name: 'Air Purifier', price: 5000.0, imageUrl: 'assets/home_kitchen/air_purifier.jpg'),
    Product(id: 12, name: 'Cooktop', price: 8000.0, imageUrl: 'assets/home_kitchen/cooktop.jpg'),
    Product(id: 13, name: 'Oven', price: 12000.0, imageUrl: 'assets/home_kitchen/oven.jpg'),
    Product(id: 14, name: 'Washing Machine', price: 15000.0, imageUrl: 'assets/home_kitchen/washing_machine.jpg'),
    Product(id: 15, name: 'Deep Fryer', price: 2000.0, imageUrl: 'assets/home_kitchen/deep_fryer.jpg'),
    Product(id: 16, name: 'Slow Cooker', price: 3500.0, imageUrl: 'assets/home_kitchen/slow_cooker.jpg'),
    Product(id: 17, name: 'Juicer', price: 2500.0, imageUrl: 'assets/home_kitchen/juicer.jpg'),
    Product(id: 18, name: 'Rice Cooker', price: 1500.0, imageUrl: 'assets/home_kitchen/rice_cooker.jpg'),
    Product(id: 19, name: 'Stand Mixer', price: 4000.0, imageUrl: 'assets/home_kitchen/stand_mixer.jpg'),
    Product(id: 20, name: 'Induction Cooker', price: 6000.0, imageUrl: 'assets/home_kitchen/induction_cooker.jpg'),
  ],
  'Beauty and Personal Care': [
    Product(id: 1, name: 'Shampoo', price: 200.0, imageUrl: 'assets/beauty_personal_care/shampoo.jpg'),
    Product(id: 2, name: 'Face Cream', price: 400.0, imageUrl: 'assets/beauty_personal_care/face_cream.jpg'),
    Product(id: 3, name: 'Perfume', price: 1500.0, imageUrl: 'assets/beauty_personal_care/perfume.jpg'),
    Product(id: 4, name: 'Lipstick', price: 300.0, imageUrl: 'assets/beauty_personal_care/lipstick.jpg'),
    Product(id: 5, name: 'Hair Dryer', price: 2000.0, imageUrl: 'assets/beauty_personal_care/hair_dryer.jpg'),
    Product(id: 6, name: 'Body Lotion', price: 500.0, imageUrl: 'assets/beauty_personal_care/body_lotion.jpg'),
    Product(id: 7, name: 'Face Wash', price: 250.0, imageUrl: 'assets/beauty_personal_care/face_wash.jpg'),
    Product(id: 8, name: 'Eye Cream', price: 600.0, imageUrl: 'assets/beauty_personal_care/eye_cream.jpg'),
    Product(id: 9, name: 'Nail Polish', price: 150.0, imageUrl: 'assets/beauty_personal_care/nail_polish.jpg'),
    Product(id: 10, name: 'Sunscreen', price: 800.0, imageUrl: 'assets/beauty_personal_care/sunscreen.jpg'),
    Product(id: 11, name: 'Deodorant', price: 200.0, imageUrl: 'assets/beauty_personal_care/deodorant.jpg'),
    Product(id: 12, name: 'Hand Cream', price: 350.0, imageUrl: 'assets/beauty_personal_care/hand_cream.jpg'),
    Product(id: 13, name: 'Face Mask', price: 400.0, imageUrl: 'assets/beauty_personal_care/face_mask.jpg'),
    Product(id: 14, name: 'Hair Serum', price: 600.0, imageUrl: 'assets/beauty_personal_care/hair_serum.jpg'),
    Product(id: 15, name: 'Makeup Remover', price: 300.0, imageUrl: 'assets/beauty_personal_care/makeup_remover.jpg'),
    Product(id: 16, name: 'Eyebrow Pencil', price: 250.0, imageUrl: 'assets/beauty_personal_care/eyebrow_pencil.jpg'),
    Product(id: 17, name: 'Body Scrub', price: 500.0, imageUrl: 'assets/beauty_personal_care/body_scrub.jpg'),
    Product(id: 18, name: 'Face Toner', price: 300.0, imageUrl: 'assets/beauty_personal_care/face_toner.jpg'),
    Product(id: 19, name: 'Hair Brush', price: 200.0, imageUrl: 'assets/beauty_personal_care/hair_brush.jpg'),
    Product(id: 20, name: 'Shaving Kit', price: 1000.0, imageUrl: 'assets/beauty_personal_care/shaving_kit.jpg'),
  ],
  'Groceries and Gourmet Food': [
    Product(id: 1, name: 'Rice', price: 50.0, imageUrl: 'assets/groceries/rice.jpg'),
    Product(id: 2, name: 'Olive Oil', price: 300.0, imageUrl: 'assets/groceries/olive_oil.jpg'),
    Product(id: 3, name: 'Pasta', price: 100.0, imageUrl: 'assets/groceries/pasta.jpg'),
    Product(id: 4, name: 'Organic Honey', price: 400.0, imageUrl: 'assets/groceries/honey.jpg'),
    Product(id: 5, name: 'Spices Set', price: 500.0, imageUrl: 'assets/groceries/spices_set.jpg'),
    Product(id: 6, name: 'Cereal', price: 250.0, imageUrl: 'assets/groceries/cereal.jpg'),
    Product(id: 7, name: 'Canned Beans', price: 150.0, imageUrl: 'assets/groceries/canned_beans.jpg'),
    Product(id: 8, name: 'Cooking Oil', price: 200.0, imageUrl: 'assets/groceries/cooking_oil.jpg'),
    Product(id: 9, name: 'Sugar', price: 100.0, imageUrl: 'assets/groceries/sugar.jpg'),
    Product(id: 10, name: 'Salt', price: 50.0, imageUrl: 'assets/groceries/salt.jpg'),
    Product(id: 11, name: 'Flour', price: 80.0, imageUrl: 'assets/groceries/flour.jpg'),
    Product(id: 12, name: 'Milk', price: 60.0, imageUrl: 'assets/groceries/milk.jpg'),
    Product(id: 13, name: 'Tea', price: 150.0, imageUrl: 'assets/groceries/tea.jpg'),
    Product(id: 14, name: 'Coffee', price: 300.0, imageUrl: 'assets/groceries/coffee.jpg'),
    Product(id: 15, name: 'Chocolate', price: 200.0, imageUrl: 'assets/groceries/chocolate.jpg'),
    Product(id: 16, name: 'Juice', price: 120.0, imageUrl: 'assets/groceries/juice.jpg'),
    Product(id: 17, name: 'Biscuits', price: 80.0, imageUrl: 'assets/groceries/biscuits.jpg'),
    Product(id: 18, name: 'Frozen Vegetables', price: 250.0, imageUrl: 'assets/groceries/frozen_vegetables.jpg'),
    Product(id: 19, name: 'Bread', price: 60.0, imageUrl: 'assets/groceries/bread.jpg'),
    Product(id: 20, name: 'Yogurt', price: 120.0, imageUrl: 'assets/groceries/yogurt.jpg'),
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
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      cartModel.removeItem(product);
                    },
                  ),
                  Text('$itemCountInCart'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      cartModel.addItem(product);
                    },
                  ),
                ] else ...[
                  IconButton(
                    icon: const Icon(Icons.add),
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
