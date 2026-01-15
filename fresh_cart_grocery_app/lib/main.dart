import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_freshcart/services/cart_service.dart';
import 'package:flutter_freshcart/services/auth_services.dart';
import 'package:flutter_freshcart/screens/login_screen.dart';
import 'package:flutter_freshcart/screens/customer_bottom_shell.dart';
import 'package:flutter_freshcart/screens/owner_bottom_shell.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'routes/routes.dart';
import 'package:provider/provider.dart';
import 'theme/theme.dart';
import 'firebase_options.dart';

void main()async{

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, 
      systemNavigationBarColor: Colors.grey[50],
      systemNavigationBarIconBrightness: Brightness.dark,
    )
  );


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<CartService>(create: (_) => CartService()),
      ],
      child: const ShopApp(),
    ),
  );
}

class ShopApp extends StatelessWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shop App',
      theme: appTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: StreamBuilder<User?>(
        stream: auth.authStateChanges,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final user = snap.data;
          if (user == null) return const LoginScreen();
          // Determine role by checking if the user owns a shop
          return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance
                .collection('shops')
                .where('ownerId', isEqualTo: user.uid)
                .limit(1)
                .get(),
            builder: (context, shopSnap) {
              if (shopSnap.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              final isOwner = (shopSnap.data?.docs.isNotEmpty ?? false);
              return isOwner ? const OwnerBottomShell() : const CustomerBottomShell();
            },
          );
        },
      ),
    );
  }
}
