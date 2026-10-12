import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/product_catalog.dart';
import 'models/cart_model.dart';
import 'models/order.dart';
import 'models/product.dart';
import 'models/settings_model.dart';
import 'models/user_model.dart';
import 'routes.dart';
import 'screens/cart_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/home_screen.dart';
import 'screens/impairment_screen.dart';
import 'screens/login_screen.dart';
import 'screens/order_confirmation_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/product_list_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/voice_order_screen.dart';
import 'services/ml_client.dart';
import 'services/speaker.dart';
import 'services/speech_service.dart';
import 'theme/app_theme.dart';

/// The QuantumBuy app. Services can be replaced, which the widget tests use
/// to run without a microphone or speech engine.
class QuantumBuyApp extends StatelessWidget {
  const QuantumBuyApp({
    super.key,
    this.speaker,
    this.speech,
    this.ml,
    this.repository = const ProductRepository(),
    this.initialRoute = Routes.splash,
  });

  final Speaker? speaker;
  final SpeechService? speech;

  /// The ML service client; null uses the address from `--dart-define=ML_URL`.
  final MlClient? ml;
  final ProductRepository repository;
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ProductRepository>.value(value: repository),
        Provider<Speaker>(create: (_) => speaker ?? TtsSpeaker()),
        Provider<SpeechService>(create: (_) => speech ?? PlatformSpeechService()),
        Provider<MlClient>(create: (_) => ml ?? MlClient()),
        ChangeNotifierProvider(create: (_) => CartModel()),
        ChangeNotifierProvider(create: (_) => UserModel()),
        ChangeNotifierProvider(create: (_) => SettingsModel()),
      ],
      child: Consumer<SettingsModel>(
        builder: (context, settings, _) => MaterialApp(
          title: 'QuantumBuy',
          debugShowCheckedModeBanner: false,
          theme: themeFor(settings),
          builder: (context, child) => AppTextScaling(enabled: settings.isTextScaling, child: child!),
          initialRoute: initialRoute,
          onGenerateRoute: _onGenerateRoute,
          onUnknownRoute: (_) => MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
        ),
      ),
    );
  }

  static Route<void>? _onGenerateRoute(RouteSettings settings) {
    Widget? page;
    final args = settings.arguments;
    switch (settings.name) {
      case Routes.splash:
        page = const SplashScreen();
      case Routes.login:
        page = const LoginScreen();
      case Routes.register:
        page = const RegistrationScreen();
      case Routes.home:
        page = const HomeScreen();
      case Routes.categories:
        page = const CategoriesScreen();
      case Routes.productList:
        if (args is String) page = ProductListScreen(category: args);
      case Routes.productDetail:
        if (args is Product) page = ProductDetailScreen(product: args);
      case Routes.cart:
        page = const CartScreen();
      case Routes.checkout:
        page = const CheckoutScreen();
      case Routes.orderConfirmation:
        if (args is Order) page = OrderConfirmationScreen(order: args);
      case Routes.profile:
        page = const ProfileScreen();
      case Routes.search:
        page = SearchScreen(initialQuery: args is String ? args : '');
      case Routes.voiceOrder:
        page = const VoiceOrderScreen();
      case Routes.settings:
        page = const SettingsScreen();
      case Routes.impairmentSurvey:
        page = const VisualImpairmentSurveyPage();
    }
    if (page == null) return null; // unknown route or missing arguments
    return MaterialPageRoute<void>(builder: (_) => page!, settings: settings);
  }
}
