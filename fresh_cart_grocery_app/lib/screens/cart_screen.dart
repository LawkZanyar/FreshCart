import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      body: cart.items.isEmpty
          ? Center(
              child: Text(
                'Your Cart is Empty, Get to Shopping!',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                ...List.generate(cart.items.length, (i) {
                  final item = cart.items[i];
                  return Dismissible(
                    key: ValueKey(item.productId),
                    background: Container(color: Colors.red),
                    onDismissed: (_) => cart.remove(item.productId),
                    child: ListTile(
                      leading: const Icon(
                        Icons.shopping_bag,
                        color: Colors.white70,
                      ),
                      title: Text(
                        item.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '\$${item.price.toStringAsFixed(2)} each',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.white70,
                            ),
                            onPressed: () => cart.decrement(item.productId),
                          ),
                          Text(
                            '${item.qty}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Colors.white70,
                            ),
                            onPressed: () async {
                              final doc = await FirebaseFirestore.instance
                                  .collection('shops')
                                  .doc(item.shopId)
                                  .collection('products')
                                  .doc(item.productId)
                                  .get();
                              final stock = (doc.data()?['stock'] ?? 0) as int;
                              // If current qty already equals or exceeds stock, show notification
                              if (item.qty >= stock) {
                                final msg = stock <= 0
                                    ? 'Product is out of stock'
                                    : 'Cannot add more — only $stock available';
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      msg,
                                      style: TextStyle(
                                        color: Colors.red.shade900,
                                        fontSize: 13,
                                      ),
                                    ),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: const Color(0xFFFFCDD2),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    margin: const EdgeInsets.only(
                                      top: 16,
                                      left: 16,
                                      right: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                                return;
                              }
                              cart.increment(item.productId, maxStock: stock);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const Divider(thickness: 1, height: 1, color: Colors.white24),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Subtotal:',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '\$${subtotal.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Delivery:',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '\$${deliveryFee.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.orderConfirmation,
                              );
                            },
                            child: const Text('Checkout'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
