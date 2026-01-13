import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/cart_service.dart';
import '../services/firestore_service.dart';
import '../routes/routes.dart';

class ShopDetailScreen extends StatelessWidget {
  const ShopDetailScreen({super.key});

  IconData _toIcon(String s) {
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

  @override
  Widget build(BuildContext context) {
    final shopId = ModalRoute.of(context)!.settings.arguments as String;
    final fire = FirestoreService();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('shops')
              .doc(shopId)
              .get(),
          builder: (_, snap) {
            if (!snap.hasData) return const Text('Shop');
            return Text(snap.data!['name']);
          },
        ),
      ),
      floatingActionButton: Consumer<CartService>(
        builder: (context, cart, child) {
          final itemCount = cart.totalQty;
          final total = cart.totalPrice;
          return FloatingActionButton.extended(
            onPressed: itemCount > 0
                ? () {
                    Navigator.pushNamed(context, AppRoutes.cart);
                  }
                : null,
            icon: const Icon(Icons.shopping_cart),
            label: Text(
              itemCount > 0
                  ? '\$${total.toStringAsFixed(2)}'
                  : 'Add Items to Cart',
            ),
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: fire.products(shopId),
          builder: (_, snap) {
            if (snap.hasError)
              return Center(child: Text(snap.error.toString()));
            if (!snap.hasData)
              return const Center(child: CircularProgressIndicator());
            final prods = snap.data!;
            return Consumer<CartService>(
              builder: (context, cart, _) {
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: prods.length,
                  itemBuilder: (_, i) {
                    final p = prods[i];
                    final stock = (p['stock'] ?? 0) as int;
                    final productId = p['id'] as String;
                    final cartQty = cart.items
                        .where((item) => item.productId == productId)
                        .fold<int>(0, (sum, item) => sum + item.qty);
                    final availableStock = stock - cartQty;
                    final isOutOfStock = availableStock <= 0;
                    final isLowStock =
                        availableStock > 0 && availableStock <= 10;

                    return Card(
                      elevation: 0,
                      child: Stack(
                        children: [
                          Opacity(
                            opacity: isOutOfStock ? 0.5 : 1.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _toIcon(p['logo'] ?? ''),
                                      size: 48,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    p['name'] ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    '\$${(p['price'] ?? 0.0).toStringAsFixed(2)}',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: isOutOfStock
                                      ? null
                                      : () {
                                          context.read<CartService>().add(
                                            p['id'],
                                            shopId,
                                            p['name'] ?? 'Unknown',
                                            (p['price'] ?? 0.0).toDouble(),
                                          );
                                          _showSuccessNotification(context);
                                        },
                                ),
                              ],
                            ),
                          ),
                          if (isLowStock)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Low Stock: $availableStock left',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          if (isOutOfStock)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.black.withOpacity(0.3),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Out of Stock',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showSuccessNotification(BuildContext context) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => const _AnimatedSuccessNotification(),
    );
    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}

class _AnimatedSuccessNotification extends StatefulWidget {
  const _AnimatedSuccessNotification();

  @override
  State<_AnimatedSuccessNotification> createState() =>
      _AnimatedSuccessNotificationState();
}

class _AnimatedSuccessNotificationState
    extends State<_AnimatedSuccessNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFE8F5E9); // Light pastel green
    const textColor = Color(0xFF66BB6A); // Soft green text
    const borderColor = Color(0xFFA5D6A7); // Pastel green border

    return Positioned(
      top: 100,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Product was successfully added!',
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: 1 - _controller.value,
                      backgroundColor: bgColor,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        borderColor,
                      ),
                      minHeight: 3,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
