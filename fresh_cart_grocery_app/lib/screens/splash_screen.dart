import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes/routes.dart';
import '../services/auth_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      if (!hasSeenOnboarding) {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
        return;
      }

      final auth = context.read<AuthService>();
      final target = auth.currentUser == null ? AppRoutes.login : AppRoutes.customerShell;
      Navigator.pushReplacementNamed(context, target);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.primary,
      body: Center(
        child: Icon(
          Icons.shopping_cart_sharp,
          size: 96,
          color: scheme.onPrimary,
        ),
      ),
    );
  }
}