import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_model.dart';
import 'user_model.dart';
import 'settings_model.dart';
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
import 'voice_order_screen.dart';
import 'settings_screen.dart';
import 'impairment_screen.dart'; // Ensure this is the correct name

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartModel()),
        ChangeNotifierProvider(create: (context) => UserModel()),
        ChangeNotifierProvider(create: (context) => SettingsModel()),
      ],
      child: Consumer<SettingsModel>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'QuantumBuy',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: settings.isDarkMode ? Brightness.dark : Brightness.light,
              textTheme: settings.isLargeText
                  ? const TextTheme(bodyLarge: TextStyle(fontSize: 18), bodyMedium: TextStyle(fontSize: 18))
                  : const TextTheme(bodyLarge: TextStyle(fontSize: 14), bodyMedium: TextStyle(fontSize: 14)),
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: settings.isDarkMode ? Brightness.dark : Brightness.light,
                primary: settings.isDarkMode ? const Color.fromARGB(255, 92, 120, 134) : Colors.blue,
                secondary: settings.isDarkMode ? const Color.fromARGB(255, 119, 169, 210) : Colors.grey,
              ),
            ),
            initialRoute: '/splash',
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/categories': (context) => const CategoriesScreen(),
              '/home': (context) => HomeScreen(),
              '/register': (context) => const RegistrationScreen(),
              '/productList': (context) => const ProductListScreen(),
              '/productDetail': (context) => const ProductDetailScreen(),
              '/cart': (context) => const CartScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/editProfile': (context) => const EditProfileScreen(),
              '/checkout': (context) => const CheckoutScreen(),
              '/voice_order_screen': (context) => VoiceOrderScreen(),
              '/settings': (context) => SettingsScreen(),
              '/impairment': (context) => VisualImpairmentSurveyPage(), // Ensure the route name matches
            },
          );
        },
      ),
    );
  }
}
