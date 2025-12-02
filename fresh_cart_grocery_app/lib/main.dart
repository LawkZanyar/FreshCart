import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_freshcart/services/cart_service.dart';
import 'routes/routes.dart';
import 'package:provider/provider.dart';
import 'theme/theme.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, 
      systemNavigationBarColor: Colors.grey[50],
      systemNavigationBarIconBrightness: Brightness.dark,
    )
  );


  runApp(
    ChangeNotifierProvider<CartService>(
      create: (_) => CartService(),
      child: const ShopApp(),
    ),
  );
}

class ShopApp extends StatelessWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shop App',
      theme: appTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}