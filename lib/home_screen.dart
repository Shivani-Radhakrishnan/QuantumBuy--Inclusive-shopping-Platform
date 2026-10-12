import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'package:flutter_cube/flutter_cube.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const iconColor = Colors.grey; // Set the icon color to grey
    const buttonTextColor = Color.fromARGB(255, 5, 5, 5); // Set the button text color to grey

    return Scaffold(
      body: Stack(
        children: [
          // Conditional Background
          isDarkMode
              ? Container(
                  color: Colors.black, // Use a solid color for dark mode
                )
              : Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage('assets/background.jpg'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.2),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
          // Profile Icon
          Positioned(
            top: 30,
            right: 20, // Adjusted the position to avoid overlap with the settings icon
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: Icon(
                Icons.person,
                
                size: 40,
                color: iconColor, // Set the icon color to grey
              ),
            ),
          ),
          // Settings Icon
          Positioned(
            top: 80,
            right: 20, // Positioned to the right of the profile icon
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
              child: Icon(
                Icons.settings,
                size: 40,
                color: iconColor, // Set the icon color to grey
              ),
            ),
          ),
          // Foreground content
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Home Screen Title
                  const Text(
                    'QuantumBuy',
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black,
                          offset: Offset(5.0, 5.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 250),
                  // Button for Categories List
                  Semantics(
                    label: 'Navigate to Categories',
                    child: Tooltip(
                      message: 'Navigate to Categories',
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/categories');
                        },
                        icon: Icon(Icons.category, color: iconColor), // Set icon color to grey
                        label: Text(
                          'Categories',
                          style: TextStyle(color: buttonTextColor), // Set text color to grey
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 237, 239, 244),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Button for Cart
                  Semantics(
                    label: 'Navigate to Cart',
                    child: Tooltip(
                      message: 'Navigate to Cart',
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/cart');
                        },
                        icon: Icon(Icons.shopping_cart, color: iconColor), // Set icon color to grey
                        label: Text(
                          'Cart',
                          style: TextStyle(color: buttonTextColor), // Set text color to grey
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 237, 239, 244),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Button for Voice Order
                  Semantics(
                    label: 'Order with Voice',
                    child: Tooltip(
                      message: 'Order with Voice',
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/voice_order_screen');
                        },
                        icon: Icon(Icons.mic, color: iconColor), // Set icon color to grey
                        label: Text(
                          'Voice Order',
                          style: TextStyle(color: buttonTextColor), // Set text color to grey
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 237, 239, 244),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
