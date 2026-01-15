import 'package:flutter/material.dart';
import 'package:flutter_freshcart/screens/customer_bottom_shell.dart';
import '../core_models/user_state.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
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
import '../screens/owner_bottom_shell.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
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
  static const customerShell = '/customer_bottom_shell';
  static const ownerShell = '/owner_shell';

  static IconData _toIcon(String s) {
    switch (s) {
      case 'store':
        return Icons.store;
      case 'apple':
        return Icons.apple;
      case 'set_meal':
        return Icons.set_meal;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'local_drink':
        return Icons.local_drink;
      case 'bakery_dining':
        return Icons.bakery_dining;
      case 'favorite':
        return Icons.favorite;
      case 'local_cafe':
        return Icons.local_cafe;
      default:
        return Icons.shopping_bag;
    }
  }
  
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case customerHome:
        final username = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (context) => UserState(
            username: username,
            child: const CustomerBottomShell(),
          ),
        );
      case shopDetail:
        return MaterialPageRoute(
          builder: (_) => const ShopDetailScreen(),
          settings: settings,
        );
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
      case customerShell:
        return MaterialPageRoute(builder: (_) => const CustomerBottomShell());
      case ownerShell:
        return MaterialPageRoute(builder: (_) => const OwnerBottomShell());
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