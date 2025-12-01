import 'package:flutter/material.dart';
import '../dummy_data/dummy_data.dart';
import '../routes/routes.dart';
import '../core_models/user_state.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  void _openShop(BuildContext context,String id){
    Navigator.pushNamed(context, AppRoutes.shopDetail, arguments: id);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final username = UserState.of(context)?.username ?? 'Guest';
    
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
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Text('Free delivery on orders over \$20',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // shops horizontal list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text('Shops near you', style: textTheme.titleMedium),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: 5,
              separatorBuilder: (_,__)=> const SizedBox(width: 12),
              itemBuilder: (_,i){
                final shop = dummyShops[i];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: ()=> _openShop(context, shop['id'] as String),
                      borderRadius: BorderRadius.circular(28),
                      child: Container(
                        width: 80, height: 80,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Icon(shop['logo'] as IconData, size: 36, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(width: 90, child: Text(shop['name'], textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          // trending vertical list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text('Trending today', style: textTheme.titleMedium),
          ),
          const SizedBox(height: 8),
          ListView.separated(
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: 10,
            separatorBuilder: (_,__)=> const SizedBox(height: 12),
            itemBuilder: (_,i){
              final shop = dummyShops[i + 5];
              return Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                child: ListTile(
                  onTap: () => _openShop(context, shop['id'] as String),
                  leading: Container(
                    width: 48, height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(shop['logo'] as IconData),
                  ),
                  title: Text(shop['name']),
                  subtitle: const Text('Fresh groceries delivered'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}