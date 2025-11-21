import 'package:flutter/material.dart';
import 'package:fresh_cart_grocery_app/screens/customer_bottom_shell.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/login_screen.dart';
import '../screens/customer_home_screen.dart';
import '../screens/shop_detail_screen.dart';
import '../screens/search_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/order_confirmation_screen.dart';
import '../screens/order_history_screen.dart';
import '../screens/order_detail_screen.dart';
import '../screens/customer_profile_screen.dart';
import '../screens/owner_dashboard_screen.dart';
import '../screens/inventory_screen.dart';
import '../screens/monthly_profits_screen.dart';
import '../screens/owner_profile_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const customerHome = '/customer_home';
  static const shopDetail = '/shop_detail';
  static const search = '/search';
  static const cart = '/cart';
  static const orderConfirmation = '/order_confirmation';
  static const orderHistory = '/order_history';
  static const orderDetail = '/order_detail';
  static const customerProfile = '/customer_profile';
  static const ownerDashboard = '/owner_dashboard';
  static const inventory = '/inventory';
  static const monthlyProfits = '/monthly_profits';
  static const ownerProfile = '/owner_profile';
  
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case customerHome:
        final username = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => CustomerBottomShell(username: username),
        );
      case shopDetail:
        return MaterialPageRoute(builder: (_) => const ShopDetailScreen());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      case orderConfirmation:
        return MaterialPageRoute(builder: (_) => const OrderConfirmationScreen());
      case orderHistory:
        return MaterialPageRoute(builder: (_) => const OrderHistoryScreen());
      case orderDetail:
        return MaterialPageRoute(builder: (_) => const OrderDetailScreen());
      case customerProfile:
        return MaterialPageRoute(builder: (_) => const CustomerProfileScreen());
      case ownerDashboard:
        return MaterialPageRoute(builder: (_) => const OwnerDashboardScreen());
      case inventory:
        return MaterialPageRoute(builder: (_) => const InventoryScreen());
      case monthlyProfits:
        return MaterialPageRoute(builder: (_) => const MonthlyProfitsScreen());
      case ownerProfile:
        return MaterialPageRoute(builder: (_) => const OwnerProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('404')),
            body: const Center(child: Text('Route not found')),
          ),
        );
    }
  }
}