import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'routes/routes.dart';
import 'theme/theme.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, 
      systemNavigationBarColor: Colors.grey[50],
      systemNavigationBarIconBrightness: Brightness.dark,
    )
  );

  runApp(const ShopApp());
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