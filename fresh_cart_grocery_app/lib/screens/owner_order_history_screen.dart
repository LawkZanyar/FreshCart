import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/owner_service.dart';
import '../services/order_service.dart';

class OwnerOrderHistoryScreen extends StatelessWidget {
  const OwnerOrderHistoryScreen({super.key});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ownerService = OwnerService();
    final orderService = OrderService(uid: '');

    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: ownerService.myShop,
        builder: (context, shopSnap) {
          if (!shopSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final shop = shopSnap.data;
          if (shop == null) {
            return const Center(child: Text('No shop found'));
          }
          final shopId = shop['id'] as String;

          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: orderService.myShopOrders(shopId),
            builder: (context, orderSnap) {
              if (orderSnap.hasError) {
                return Center(
                  child: Text(
                    'Error: ${orderSnap.error}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                );
              }
              if (!orderSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final orders = orderSnap.data!;
              if (orders.isEmpty) {
                return Center(
                  child: Text(
                    'No orders yet',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final order = orders[i];
                  final orderId = order['id'] as String?;
                  final status = (order['status'] ?? 'Pending') as String;
                  final total = (order['total'] ?? 0.0) as double;
                  final createdAt = order['createdAt'] as Timestamp?;
                  final items =
                      (order['items'] as List<dynamic>?)
                          ?.cast<Map<String, dynamic>>() ??
                      [];

                  final createdDate = createdAt?.toDate() ?? DateTime.now();
                  final dateStr =
                      '${createdDate.month}/${createdDate.day}/${createdDate.year}';

                  return Card(
                    elevation: 0,
                    child: ListTile(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (bsContext) {
                            return Padding(
                              padding: EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: 16,
                                bottom:
                                    MediaQuery.of(bsContext).viewInsets.bottom +
                                    16,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order #${orderId?.substring(0, 8) ?? 'Unknown'}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(color: Colors.white),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Date: $dateStr',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.white),
                                  ),
                                  Text(
                                    'Total: \$${total.toStringAsFixed(2)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.white),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Items:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(color: Colors.white),
                                  ),
                                  ...items.map(
                                    (item) => Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        '${item['name']} (×${item['qty']}) - \$${(item['price'] * item['qty']).toStringAsFixed(2)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.white70),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(bsContext).pop(),
                                      child: const Text('Close'),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      leading: Container(
                        width: 12,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: _statusColor(status),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      title: Text(
                        'Order #${orderId?.substring(0, 8) ?? 'Unknown'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '$dateStr • ${items.length} item${items.length != 1 ? 's' : ''}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            status,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: _statusColor(status),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
