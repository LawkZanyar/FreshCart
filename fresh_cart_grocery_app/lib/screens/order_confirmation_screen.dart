import 'package:flutter/material.dart';
import '../services/cart_service.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderNumber = DateTime.now().millisecondsSinceEpoch % 100000;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 96),
              const SizedBox(height: 24),
              Text('Order # $orderNumber', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              const Text('Your order has been placed.'),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: (){
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                icon: const Icon(Icons.shopping_bag),
                label: const Text('Continue Shopping'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}