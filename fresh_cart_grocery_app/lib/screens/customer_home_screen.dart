import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../routes/routes.dart';
import '../services/auth_services.dart';
import '../services/firestore_service.dart';

class CustomerHomeScreen extends StatefulWidget {
  final String? username;
  const CustomerHomeScreen({super.key, this.username});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final _fire = FirestoreService();

  IconData _toIcon(dynamic value) {
    if (value is IconData) return value;
    if (value is String) {
      switch (value) {
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
    return Icons.shopping_bag;
  }

  void _openShop(BuildContext context, String shopId) {
    Navigator.pushNamed(context, AppRoutes.shopDetail, arguments: shopId);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final username =
        context.watch<AuthService>().currentUser?.displayName ?? 'Guest';

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              username[0].toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text('Good morning, $username ☀️'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // promo banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Material(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Free delivery on orders over \$20',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // shops stream
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Shops near you',
              style: textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _fire.shops,
            builder: (_, snap) {
              if (snap.hasError)
                return Center(child: Text(snap.error.toString()));
              if (!snap.hasData)
                return const Center(child: CircularProgressIndicator());
              final shops = snap.data!;
              return SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: shops.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final shop = shops[i];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => _openShop(context, shop['id'] as String),
                          borderRadius: BorderRadius.circular(28),
                          child: Container(
                            width: 80,
                            height: 80,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Icon(
                              _toIcon(shop['logo'] ?? ''),
                              size: 36,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 90,
                          child: Text(
                            shop['name'] ?? '',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          // trending vertical list (all shops)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'All shops',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _fire.shops,
            builder: (_, snap) {
              if (snap.hasError)
                return Center(child: Text(snap.error.toString()));
              if (!snap.hasData)
                return const Center(child: CircularProgressIndicator());
              final shops = snap.data!;
              return ListView.separated(
                physics: const ClampingScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: shops.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final shop = shops[i];
                  return Card(
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      onTap: () => _openShop(context, shop['id'] as String),
                      leading: Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(_toIcon(shop['logo'])),
                      ),
                      title: Text(
                        shop['name'] ?? 'Unknown',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        'Fresh groceries delivered',
                        style: TextStyle(color: Colors.white70),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.white70,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}