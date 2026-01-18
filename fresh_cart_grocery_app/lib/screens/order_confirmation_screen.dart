import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';

class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({super.key});
  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  String? orderId;
  double total = 0;

  @override
  void initState() {
    super.initState();
    _create();
  }

  Future<void> _create() async {
    final cart = context.read<CartService>();
    final items = cart.items;
    if (items.isEmpty) return;
    total = cart.totalPrice;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final id = await OrderService(uid: uid).createOrder(items, total);
    cart.clear();                       // local clear only
    if (mounted) setState(() => orderId = id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 96),
            const SizedBox(height: 24),
            if (orderId == null)
              const CircularProgressIndicator()
            else ...[
              Text(
                'Order # $orderId',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total: \$${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
            const SizedBox(height: 32),
            FilledButton.icon(
              style: FilledButton.styleFrom(foregroundColor: Colors.white),
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              icon: const Icon(Icons.shopping_bag),
              label: const Text('Continue Shopping'),
            ),
          ],
        ),
      ),
    );
  }
}