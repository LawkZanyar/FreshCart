import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../dummy_data/dummy_data.dart';
import '../services/cart_service.dart';

class ShopDetailScreen extends StatelessWidget {
  final String? shopId;
  
  const ShopDetailScreen({super.key, this.shopId});

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

  @override
  Widget build(BuildContext context) {
    print('Shop ID received: $shopId');
    print('Available shops: ${dummyShops.map((s) => s['id']).toList()}');
    
    if (shopId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('No shop ID provided')),
      );
    }

    final shop = dummyShops.firstWhere(
      (s) => s['id'] == shopId,
      orElse: () => {'id': '', 'name': 'Unknown Shop', 'logo': Icons.store},
    );

    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(shop['name']),),
      floatingActionButton: Consumer<CartService>(
        builder: (context, cart, child) {
          final total = cart.totalQty;
          if (total == 0) return const SizedBox.shrink();
          
          return FloatingActionButton.extended(
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            icon: const Icon(Icons.shopping_cart),
            label: Text('\$${cart.totalPrice.toStringAsFixed(2)}'),
          );
        },
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12
          ),
          itemCount: dummyProducts.length,
          itemBuilder: (_, i) {
            final p = dummyProducts[i];
            return Card(
              elevation: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(p['icon'] as IconData, size: 48,),
                    )
                  ),
                  const SizedBox(height: 8,),

                  Padding(
                    padding: const EdgeInsetsGeometry.symmetric(horizontal: 8),
                    child: Text(p['name'], maxLines: 1, overflow: TextOverflow.ellipsis,),
                  ),

                  Padding(
                    padding: const EdgeInsetsGeometry.symmetric(horizontal: 8),
                    child: Text('\$${p['price']} / ${p['unit']}', style: textTheme.bodySmall),
                  ),

                  IconButton(
                    onPressed: () {
                      context.read<CartService>().add(p['id']);
                      _showSuccessNotification(context);
                    }, 
                    icon: Icon(Icons.add_circle_outline)
                  )
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}

class _AnimatedSuccessNotification extends StatefulWidget {
  const _AnimatedSuccessNotification();

  @override
  State<_AnimatedSuccessNotification> createState() => _AnimatedSuccessNotificationState();
}

class _AnimatedSuccessNotificationState extends State<_AnimatedSuccessNotification>
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
                      valueColor: const AlwaysStoppedAnimation<Color>(borderColor),
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