import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../routes/routes.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartService>();
    const deliveryFee = 2.0;
    final subtotal = cart.totalPrice;
    final total = subtotal + deliveryFee;

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: cart.items.isEmpty ? const Center(child: Text('Your Cart is Empty, Get to Shopping!'),) : 
      ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          ...List.generate(cart.items.length, (i) {
            final item = cart.items[i];
            return Dismissible(
              key: ValueKey(item.productId), 
              background: Container(color: Colors.red,),
              onDismissed: (_) => cart.remove(item.productId),
              child: ListTile(
                leading: const Icon(Icons.shopping_bag),
                title: Text(item.name),
                subtitle: Text('\$${item.price.toStringAsFixed(2)} each'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton( 
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => cart.decrement(item.productId),
                    ),

                    Text('${item.qty}'),

                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => cart.increment(item.productId),
                    )
                  ],
                ),
              ),
            );
          }),

          const Divider(thickness: 1, height: 1, color: Colors.black,),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Subtotal:', style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(width: 16),
                    Text('\$${subtotal.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Delivery:', style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(width: 16),
                    Text('\$${deliveryFee.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Text('\$${total.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        cart.clear();
                        Navigator.pushNamed(context, AppRoutes.orderConfirmation);
                      },
                      child: const Text('Checkout'),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      )
    );
  }
}