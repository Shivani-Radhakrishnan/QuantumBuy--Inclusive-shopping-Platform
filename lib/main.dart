import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_model.dart';
import 'user_model.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'product_list_screen.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'categories_screen.dart';
import 'edit_profile_screen.dart';
import 'checkout_screen.dart';
import 'splash_screen.dart';
import 'voice_order_screen.dart';  // Import the VoiceOrderScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartModel()),
        ChangeNotifierProvider(create: (context) => UserModel()),
      ],
      child: MaterialApp(
        title: 'QuantumBuy',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // Initial route set to SplashScreen
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => SplashScreen(), // Route to SplashScreen
          '/login': (context) => LoginScreen(),
          '/categories': (context) => CategoriesScreen(),
          '/home': (context) => HomeScreen(),
          '/register': (context) => RegistrationScreen(),
          '/productList': (context) => ProductListScreen(),
          '/productDetail': (context) => ProductDetailScreen(),
          '/cart': (context) => CartScreen(),
          '/profile': (context) => ProfileScreen(),
          '/editProfile': (context) => EditProfileScreen(),
          '/checkout': (context) => CheckoutScreen(),
          '/voice_order_screen': (context) => VoiceOrderScreen(),  // Route to VoiceOrderScreen
        },
      ),
    );
  }
}
