import '../models/product.dart';

/// The single source of product data for the app.
///
/// Screens, voice ordering and tests all read products from here, so nothing
/// else hard-codes product lists. Provided to the widget tree with Provider.
class ProductRepository {
  const ProductRepository();

  /// Category names, in display order.
  List<String> get categories => _catalog.keys.toList(growable: false);

  /// Products in [category], or an empty list for an unknown category.
  List<Product> productsIn(String category) => _catalog[category] ?? const [];

  /// Every product, in category order.
  List<Product> get allProducts => [for (final list in _catalog.values) ...list];

  Product? byId(int id) {
    for (final product in allProducts) {
      if (product.id == id) return product;
    }
    return null;
  }

  /// The category [product] belongs to, or null if it isn't in the catalogue.
  String? categoryOf(Product product) {
    for (final entry in _catalog.entries) {
      if (entry.value.contains(product)) return entry.key;
    }
    return null;
  }
}

// Product ids are unique across the whole catalogue: category number * 100 + n.
const Map<String, List<Product>> _catalog = {
  'Electronics': [
    Product(id: 101, name: 'Smartphone', price: 10000.0, imageUrl: 'assets/electronics/smartphone.jpg', description: 'Latest model with high-end features.'),
    Product(id: 102, name: 'Laptop', price: 50000.0, imageUrl: 'assets/electronics/laptop.jpg', description: 'High-performance laptop for gaming and work.'),
    Product(id: 103, name: 'Smart TV', price: 40000.0, imageUrl: 'assets/electronics/smart_tv.jpg', description: 'Ultra HD Smart TV with multiple streaming apps.'),
    Product(id: 104, name: 'Headphones', price: 2000.0, imageUrl: 'assets/electronics/headphones.jpg', description: 'Noise-cancelling headphones with excellent sound quality.'),
    Product(id: 105, name: 'Camera', price: 25000.0, imageUrl: 'assets/electronics/camera.jpg', description: 'DSLR camera with high-resolution image capture.'),
    Product(id: 106, name: 'Smartwatch', price: 8000.0, imageUrl: 'assets/electronics/smartwatch.jpg', description: 'Wearable smartwatch with fitness tracking capabilities.'),
    Product(id: 107, name: 'Bluetooth Speaker', price: 1500.0, imageUrl: 'assets/electronics/bluetooth_speaker.jpg', description: 'Portable Bluetooth speaker with powerful sound.'),
    Product(id: 108, name: 'Tablet', price: 25000.0, imageUrl: 'assets/electronics/tablet.jpg', description: 'High-resolution tablet for entertainment and work.'),
    Product(id: 109, name: 'Smart Thermostat', price: 10000.0, imageUrl: 'assets/electronics/smart_thermostat.jpg', description: 'Smart thermostat for energy-efficient climate control.'),
    Product(id: 110, name: 'External Hard Drive', price: 5000.0, imageUrl: 'assets/electronics/external_hard_drive.jpg', description: 'High-capacity external hard drive for data storage.'),
    Product(id: 111, name: '4K Monitor', price: 15000.0, imageUrl: 'assets/electronics/4k_monitor.jpg', description: '4K monitor with exceptional color accuracy.'),
    Product(id: 112, name: 'Digital Camera', price: 35000.0, imageUrl: 'assets/electronics/digital_camera.jpg', description: 'Professional digital camera for high-quality photography.'),
    Product(id: 113, name: 'Game Console', price: 30000.0, imageUrl: 'assets/electronics/game_console.jpg', description: 'Latest game console with a wide range of games.'),
    Product(id: 114, name: 'Wireless Charger', price: 2000.0, imageUrl: 'assets/electronics/wireless_charger.jpg', description: 'Convenient wireless charger for quick and easy charging.'),
    Product(id: 115, name: 'Action Camera', price: 15000.0, imageUrl: 'assets/electronics/action_camera.jpg', description: 'Compact action camera for capturing adventures.'),
    Product(id: 116, name: 'Home Theater System', price: 60000.0, imageUrl: 'assets/electronics/home_theater.jpg', description: 'Complete home theater system with surround sound.'),
    Product(id: 117, name: 'Smart Doorbell', price: 8000.0, imageUrl: 'assets/electronics/smart_doorbell.jpg', description: 'Smart doorbell with video and audio capabilities.'),
    Product(id: 118, name: 'Digital Photo Frame', price: 4000.0, imageUrl: 'assets/electronics/digital_photo_frame.jpg', description: 'Digital photo frame with high-resolution display.'),
    Product(id: 119, name: 'Projector', price: 20000.0, imageUrl: 'assets/electronics/projector.jpg', description: 'Projector for home theater or presentations.'),
    Product(id: 120, name: 'Electric Toothbrush', price: 3000.0, imageUrl: 'assets/electronics/electric_toothbrush.jpg', description: 'Electric toothbrush with multiple cleaning modes.'),
  ],
  'Clothing and Accessories': [
    Product(id: 201, name: 'T-shirt', price: 500.0, imageUrl: 'assets/clothing/tshirt.jpg', description: 'Comfortable cotton t-shirt available in various colors.'),
    Product(id: 202, name: 'Jeans', price: 1200.0, imageUrl: 'assets/clothing/jeans.jpg', description: 'Stylish jeans with a perfect fit.'),
    Product(id: 203, name: 'Jacket', price: 3000.0, imageUrl: 'assets/clothing/jacket.jpg', description: 'Warm and trendy jacket for winter.'),
    Product(id: 204, name: 'Sunglasses', price: 1500.0, imageUrl: 'assets/clothing/sunglasses.jpg', description: 'Fashionable sunglasses with UV protection.'),
    Product(id: 205, name: 'Watch', price: 5000.0, imageUrl: 'assets/clothing/watch.jpg', description: 'Elegant watch with a classic design.'),
    Product(id: 206, name: 'Sneakers', price: 2500.0, imageUrl: 'assets/clothing/sneakers.jpg', description: 'Comfortable sneakers for everyday wear.'),
    Product(id: 207, name: 'Hat', price: 800.0, imageUrl: 'assets/clothing/hat.jpg', description: 'Stylish hat for sun protection and fashion.'),
    Product(id: 208, name: 'Scarf', price: 1000.0, imageUrl: 'assets/clothing/scarf.jpg', description: 'Warm and soft scarf for cold weather.'),
    Product(id: 209, name: 'Sweater', price: 2000.0, imageUrl: 'assets/clothing/sweater.jpg', description: 'Cozy sweater for casual wear.'),
    Product(id: 210, name: 'Shorts', price: 700.0, imageUrl: 'assets/clothing/shorts.jpg', description: 'Comfortable shorts for summer.'),
    Product(id: 211, name: 'Blouse', price: 1200.0, imageUrl: 'assets/clothing/blouse.jpg', description: 'Elegant blouse for formal occasions.'),
    Product(id: 212, name: 'Cardigan', price: 1800.0, imageUrl: 'assets/clothing/cardigan.jpg', description: 'Stylish cardigan for layering.'),
    Product(id: 213, name: 'Belt', price: 500.0, imageUrl: 'assets/clothing/belt.jpg', description: 'Durable belt for everyday use.'),
    Product(id: 214, name: 'Dress', price: 2500.0, imageUrl: 'assets/clothing/dress.jpg', description: 'Beautiful dress for special events.'),
    Product(id: 215, name: 'Socks', price: 300.0, imageUrl: 'assets/clothing/socks.jpg', description: 'Comfortable socks available in various sizes.'),
    Product(id: 216, name: 'Gloves', price: 600.0, imageUrl: 'assets/clothing/gloves.jpg', description: 'Warm gloves for winter.'),
    Product(id: 217, name: 'Tie', price: 400.0, imageUrl: 'assets/clothing/tie.jpg', description: 'Elegant tie for formal occasions.'),
    Product(id: 218, name: 'Raincoat', price: 1500.0, imageUrl: 'assets/clothing/raincoat.jpg', description: 'Waterproof raincoat for rainy days.'),
    Product(id: 219, name: 'Pants', price: 1400.0, imageUrl: 'assets/clothing/pants.jpg', description: 'Comfortable pants for casual or formal wear.'),
    Product(id: 220, name: 'Overalls', price: 2200.0, imageUrl: 'assets/clothing/overalls.jpg', description: 'Durable overalls for work or casual wear.'),
  ],
  'Home and Kitchen': [
    Product(id: 301, name: 'Mixer', price: 1500.0, imageUrl: 'assets/home_kitchen/mixer.jpg', description: 'High-power mixer for efficient blending.'),
    Product(id: 302, name: 'Cookware Set', price: 7000.0, imageUrl: 'assets/home_kitchen/cookware.jpg', description: 'Complete cookware set for all your cooking needs.'),
    Product(id: 303, name: 'Vacuum Cleaner', price: 4000.0, imageUrl: 'assets/home_kitchen/vacuum_cleaner.jpg', description: 'Powerful vacuum cleaner for home cleaning.'),
    Product(id: 304, name: 'Refrigerator', price: 20000.0, imageUrl: 'assets/home_kitchen/refrigerator.jpg', description: 'Energy-efficient refrigerator with ample storage.'),
    Product(id: 305, name: 'Microwave', price: 3000.0, imageUrl: 'assets/home_kitchen/microwave.jpg', description: 'Microwave oven for quick and easy cooking.'),
    Product(id: 306, name: 'Blender', price: 1200.0, imageUrl: 'assets/home_kitchen/blender.jpg', description: 'Versatile blender for smoothies and soups.'),
    Product(id: 307, name: 'Toaster', price: 800.0, imageUrl: 'assets/home_kitchen/toaster.jpg', description: 'Toaster with multiple settings for perfect toast.'),
    Product(id: 308, name: 'Coffee Maker', price: 1500.0, imageUrl: 'assets/home_kitchen/coffee_maker.jpg', description: 'Coffee maker for brewing fresh coffee.'),
    Product(id: 309, name: 'Electric Kettle', price: 700.0, imageUrl: 'assets/home_kitchen/electric_kettle.jpg', description: 'Electric kettle for boiling water quickly.'),
    Product(id: 310, name: 'Dishwasher', price: 12000.0, imageUrl: 'assets/home_kitchen/dishwasher.jpg', description: 'Dishwasher for convenient dish cleaning.'),
    Product(id: 311, name: 'Air Purifier', price: 5000.0, imageUrl: 'assets/home_kitchen/air_purifier.jpg', description: 'Air purifier for cleaner and fresher air.'),
    Product(id: 312, name: 'Cooktop', price: 6000.0, imageUrl: 'assets/home_kitchen/cooktop.jpg', description: 'Cooktop with multiple burners for efficient cooking.'),
    Product(id: 313, name: 'Oven', price: 10000.0, imageUrl: 'assets/home_kitchen/oven.jpg', description: 'Oven for baking and roasting.'),
    Product(id: 314, name: 'Washing Machine', price: 15000.0, imageUrl: 'assets/home_kitchen/washing_machine.jpg', description: 'Washing machine for easy laundry.'),
    Product(id: 315, name: 'Deep Fryer', price: 2000.0, imageUrl: 'assets/home_kitchen/deep_fryer.jpg', description: 'Deep fryer for cooking crispy fried foods.'),
    Product(id: 316, name: 'Slow Cooker', price: 2500.0, imageUrl: 'assets/home_kitchen/slow_cooker.jpg', description: 'Slow cooker for making delicious stews and soups.'),
    Product(id: 317, name: 'Juicer', price: 1800.0, imageUrl: 'assets/home_kitchen/juicer.jpg', description: 'Juicer for extracting fresh juices.'),
    Product(id: 318, name: 'Rice Cooker', price: 1500.0, imageUrl: 'assets/home_kitchen/rice_cooker.jpg', description: 'Rice cooker for perfectly cooked rice.'),
    Product(id: 319, name: 'Stand Mixer', price: 5000.0, imageUrl: 'assets/home_kitchen/stand_mixer.jpg', description: 'Stand mixer for baking and cooking.'),
    Product(id: 320, name: 'Induction Cooker', price: 4000.0, imageUrl: 'assets/home_kitchen/induction_cooker.jpg', description: 'Induction cooker for fast and efficient cooking.'),
  ],
  'Beauty and Personal Care': [
    Product(id: 401, name: 'Shampoo', price: 500.0, imageUrl: 'assets/beauty_personal_care/shampoo.jpg', description: 'Nourishing shampoo for healthy hair.'),
    Product(id: 402, name: 'Face Cream', price: 800.0, imageUrl: 'assets/beauty_personal_care/face_cream.jpg', description: 'Moisturizing face cream for glowing skin.'),
    Product(id: 403, name: 'Perfume', price: 1500.0, imageUrl: 'assets/beauty_personal_care/perfume.jpg', description: 'Fragrant perfume with a long-lasting scent.'),
    Product(id: 404, name: 'Lipstick', price: 600.0, imageUrl: 'assets/beauty_personal_care/lipstick.jpg', description: 'Vibrant lipstick in various shades.'),
    Product(id: 405, name: 'Hair Dryer', price: 1000.0, imageUrl: 'assets/beauty_personal_care/hair_dryer.jpg', description: 'Powerful hair dryer for quick drying.'),
    Product(id: 406, name: 'Body Lotion', price: 700.0, imageUrl: 'assets/beauty_personal_care/body_lotion.jpg', description: 'Hydrating body lotion for soft skin.'),
    Product(id: 407, name: 'Face Wash', price: 400.0, imageUrl: 'assets/beauty_personal_care/face_wash.jpg', description: 'Gentle face wash for daily use.'),
    Product(id: 408, name: 'Eye Cream', price: 800.0, imageUrl: 'assets/beauty_personal_care/eye_cream.jpg', description: 'Eye cream for reducing dark circles.'),
    Product(id: 409, name: 'Nail Polish', price: 300.0, imageUrl: 'assets/beauty_personal_care/nail_polish.jpg', description: 'Colorful nail polish for manicured nails.'),
    Product(id: 410, name: 'Sunscreen', price: 600.0, imageUrl: 'assets/beauty_personal_care/sunscreen.jpg', description: 'Sunscreen for protecting skin from UV rays.'),
    Product(id: 411, name: 'Deodorant', price: 350.0, imageUrl: 'assets/beauty_personal_care/deodorant.jpg', description: 'Deodorant for all-day freshness.'),
    Product(id: 412, name: 'Hand Cream', price: 400.0, imageUrl: 'assets/beauty_personal_care/hand_cream.jpg', description: 'Moisturizing hand cream for soft hands.'),
    Product(id: 413, name: 'Face Mask', price: 700.0, imageUrl: 'assets/beauty_personal_care/face_mask.jpg', description: 'Face mask for deep cleansing.'),
    Product(id: 414, name: 'Hair Serum', price: 900.0, imageUrl: 'assets/beauty_personal_care/hair_serum.jpg', description: 'Hair serum for smooth and shiny hair.'),
    Product(id: 415, name: 'Makeup Remover', price: 500.0, imageUrl: 'assets/beauty_personal_care/makeup_remover.jpg', description: 'Makeup remover for gentle cleansing.'),
    Product(id: 416, name: 'Eyebrow Pencil', price: 300.0, imageUrl: 'assets/beauty_personal_care/eyebrow_pencil.jpg', description: 'Eyebrow pencil for defined brows.'),
    Product(id: 417, name: 'Body Scrub', price: 800.0, imageUrl: 'assets/beauty_personal_care/body_scrub.jpg', description: 'Exfoliating body scrub for smooth skin.'),
    Product(id: 418, name: 'Face Toner', price: 600.0, imageUrl: 'assets/beauty_personal_care/face_toner.jpg', description: 'Face toner for balanced skin.'),
    Product(id: 419, name: 'Hair Brush', price: 400.0, imageUrl: 'assets/beauty_personal_care/hair_brush.jpg', description: 'Hair brush for detangling and styling.'),
    Product(id: 420, name: 'Shaving Kit', price: 1000.0, imageUrl: 'assets/beauty_personal_care/shaving_kit.jpg', description: 'Complete shaving kit for a smooth shave.'),
  ],
  'Groceries and Gourmet Food': [
    Product(id: 501, name: 'Rice', price: 1000.0, imageUrl: 'assets/groceries/rice.jpg', description: 'Premium quality rice for daily use.'),
    Product(id: 502, name: 'Olive Oil', price: 600.0, imageUrl: 'assets/groceries/olive_oil.jpg', description: 'Extra virgin olive oil for cooking and dressing.'),
    Product(id: 503, name: 'Pasta', price: 300.0, imageUrl: 'assets/groceries/pasta.jpg', description: 'Delicious pasta in various shapes.'),
    Product(id: 504, name: 'Honey', price: 500.0, imageUrl: 'assets/groceries/honey.jpg', description: 'Natural honey with a rich flavor.'),
    Product(id: 505, name: 'Spices Set', price: 800.0, imageUrl: 'assets/groceries/spices_set.jpg', description: 'Variety of spices for enhanced flavors.'),
    Product(id: 506, name: 'Cereal', price: 400.0, imageUrl: 'assets/groceries/cereal.jpg', description: 'Nutritious cereal for a quick breakfast.'),
    Product(id: 507, name: 'Canned Beans', price: 250.0, imageUrl: 'assets/groceries/canned_beans.jpg', description: 'Canned beans for convenient cooking.'),
    Product(id: 508, name: 'Cooking Oil', price: 500.0, imageUrl: 'assets/groceries/cooking_oil.jpg', description: 'Versatile cooking oil for all dishes.'),
    Product(id: 509, name: 'Sugar', price: 300.0, imageUrl: 'assets/groceries/sugar.jpg', description: 'Granulated sugar for sweetening.'),
    Product(id: 510, name: 'Salt', price: 100.0, imageUrl: 'assets/groceries/salt.jpg', description: 'Pure salt for seasoning.'),
    Product(id: 511, name: 'Flour', price: 400.0, imageUrl: 'assets/groceries/flour.jpg', description: 'High-quality flour for baking and cooking.'),
    Product(id: 512, name: 'Milk', price: 200.0, imageUrl: 'assets/groceries/milk.jpg', description: 'Fresh milk for daily consumption.'),
    Product(id: 513, name: 'Tea', price: 300.0, imageUrl: 'assets/groceries/tea.jpg', description: 'Aromatic tea for a relaxing drink.'),
    Product(id: 514, name: 'Coffee', price: 500.0, imageUrl: 'assets/groceries/coffee.jpg', description: 'Rich coffee for a perfect brew.'),
    Product(id: 515, name: 'Chocolate', price: 250.0, imageUrl: 'assets/groceries/chocolate.jpg', description: 'Delicious chocolate in various flavors.'),
    Product(id: 516, name: 'Juice', price: 350.0, imageUrl: 'assets/groceries/juice.jpg', description: 'Refreshing juice with natural flavors.'),
    Product(id: 517, name: 'Biscuits', price: 150.0, imageUrl: 'assets/groceries/biscuits.jpg', description: 'Crunchy biscuits for a tasty snack.'),
    Product(id: 518, name: 'Frozen Vegetables', price: 400.0, imageUrl: 'assets/groceries/frozen_vegetables.jpg', description: 'Frozen vegetables for convenient cooking.'),
    Product(id: 519, name: 'Bread', price: 100.0, imageUrl: 'assets/groceries/bread.jpg', description: 'Fresh bread for daily meals.'),
    Product(id: 520, name: 'Yogurt', price: 250.0, imageUrl: 'assets/groceries/yogurt.jpg', description: 'Creamy yogurt in various flavors.'),
  ],
};
