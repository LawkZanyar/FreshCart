import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/owner_service.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = OwnerService();
    return Scaffold(
      appBar: AppBar(title: const Text('Owner Dashboard')),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: service.myShop,
        builder: (context, shopSnap) {
          if (shopSnap.hasError) {
            return Center(
              child: Text(
                shopSnap.error.toString(),
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }
          if (!shopSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final shop = shopSnap.data;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (shop != null) ...[
                  Text(
                    shop['name'] ?? 'My Shop',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                _ordersSection(
                  context,
                  stream: service.pendingTodayDetailed(),
                  label: 'Pending Orders',
                  color: Colors.orange,
                  icon: Icons.pending,
                ),
                const SizedBox(height: 12),
                _revenueSection(context, service),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _ordersSection(
    BuildContext context, {
    required Stream<List<Map<String, dynamic>>> stream,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (_, snap) {
        final orders = snap.data ?? const <Map<String, dynamic>>[];
        return Card(
          elevation: 2,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 32),
                  ),
                  title: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Text(
                    orders.length.toString(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (orders.isNotEmpty)
                ...orders.map((order) => _orderItem(context, order)),
            ],
          ),
        );
      },
    );
  }

  Widget _orderItem(BuildContext context, Map<String, dynamic> order) {
    final createdAt = order['createdAt'] as Timestamp?;
    final timeStr = createdAt != null
        ? _formatTime(createdAt.toDate())
        : 'Unknown';
    final total = order['total'] ?? 0.0;

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white24)),
      ),
      child: ListTile(
        dense: true,
        title: Text(
          '$timeStr • ${order['items']?.length ?? 0} items',
          style: const TextStyle(fontSize: 14, color: Colors.white),
        ),
        trailing: Text(
          '\$${total.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _revenueSection(BuildContext context, OwnerService service) {
    return StreamBuilder<double>(
      stream: service.revenueToday(),
      builder: (_, todaySnap) {
        return StreamBuilder<double>(
          stream: service.revenueYesterday(),
          builder: (_, yesterdaySnap) {
            final today = todaySnap.data ?? 0.0;
            final yesterday = yesterdaySnap.data ?? 0.0;
            final diff = yesterday > 0
                ? ((today - yesterday) / yesterday * 100)
                : 0.0;
            final isPositive = diff >= 0;

            return Card(
              elevation: 2,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.attach_money,
                          color: Colors.green,
                          size: 32,
                        ),
                      ),
                      title: Text(
                        'Revenue Today',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      trailing: Text(
                        '\$${today.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.white24)),
                    ),
                    child: ListTile(
                      dense: true,
                      title: const Text(
                        'vs Yesterday',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: isPositive ? Colors.green : Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${isPositive ? '+' : ''}${diff.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: isPositive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
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
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}