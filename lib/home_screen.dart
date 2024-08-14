import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'), // Add a background image
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.2),
                  BlendMode.darken,
                ), // Reduce opacity
              ),
            ),
          ),
          // Profile Icon
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.white.withOpacity(0.8), // Increased opacity for better contrast
              ),
            ),
          ),
          // Foreground content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Home Screen Title
                Text(
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
                SizedBox(height: 250),
                // Button for Categories List
                Semantics(
                  label: 'Navigate to Categories',
                  child: Tooltip(
                    message: 'Navigate to Categories',
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/categories');
                      },
                      icon: Icon(Icons.category),
                      label: Text('Categories'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 237, 239, 244),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        textStyle: TextStyle(fontSize: 18), // High-contrast color
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Button for Cart
                Semantics(
                  label: 'Navigate to Cart',
                  child: Tooltip(
                    message: 'Navigate to Cart',
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/cart');
                      },
                      icon: Icon(Icons.shopping_cart),
                      label: Text('Cart'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 237, 239, 244),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        textStyle: TextStyle(fontSize: 18), // High-contrast color
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Button for Voice Order
                Semantics(
                  label: 'Order with Voice',
                  child: Tooltip(
                    message: 'Order with Voice',
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/voiceOrder');
                      },
                      icon: Icon(Icons.mic),
                      label: Text('Voice Order'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 237, 239, 244),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        textStyle: TextStyle(fontSize: 18), // High-contrast color
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
