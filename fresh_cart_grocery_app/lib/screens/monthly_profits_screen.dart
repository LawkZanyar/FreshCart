import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/owner_service.dart';

class MonthlyProfitsScreen extends StatefulWidget {
  const MonthlyProfitsScreen({super.key});

  @override
  State<MonthlyProfitsScreen> createState() => _MonthlyProfitsScreenState();
}

class _MonthlyProfitsScreenState extends State<MonthlyProfitsScreen> {
  final Map<int, bool> _expandedMonths = {};

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  Future<Map<int, List<Map<String, dynamic>>>> _getMonthlyOrders(
    FirebaseFirestore db,
    String shopId,
  ) async {
    final snapshot = await db
        .collection('orders')
        .where('shopId', isEqualTo: shopId)
        .where('status', isEqualTo: 'Delivered')
        .get();

    final monthlyOrders = <int, List<Map<String, dynamic>>>{};
    for (final doc in snapshot.docs) {
      final createdAt = doc['createdAt'] as Timestamp?;
      if (createdAt != null) {
        final date = createdAt.toDate();
        final monthKey = date.year * 100 + date.month;
        final orderData = {'id': doc.id, ...doc.data()};
        monthlyOrders.putIfAbsent(monthKey, () => []).add(orderData);
      }
    }
    return monthlyOrders;
  }

  @override
  Widget build(BuildContext context) {
    final ownerService = OwnerService();
    final db = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Profits')),
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

          return FutureBuilder<Map<int, List<Map<String, dynamic>>>>(
            future: _getMonthlyOrders(db, shopId),
            builder: (context, orderSnap) {
              if (orderSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (orderSnap.hasError) {
                return Center(
                  child: Text(
                    'Error: ${orderSnap.error}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                );
              }

              final monthlyOrders = orderSnap.data ?? {};
              if (monthlyOrders.isEmpty) {
                return Center(
                  child: Text(
                    'No delivery data yet',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                  ),
                );
              }

              // Sort by month key descending (most recent first)
              final sortedKeys = monthlyOrders.keys.toList()
                ..sort((a, b) => b.compareTo(a));

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: sortedKeys.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final monthKey = sortedKeys[i];
                  final year = monthKey ~/ 100;
                  final month = monthKey % 100;
                  final orders = monthlyOrders[monthKey] ?? [];
                  final monthlyTotal = orders.fold<double>(
                    0.0,
                    (sum, order) =>
                        sum + ((order['total'] as num?)?.toDouble() ?? 0.0),
                  );
                  final isExpanded = _expandedMonths[monthKey] ?? false;

                  return Card(
                    elevation: 2,
                    child: Column(
                      children: [
                        ListTile(
                          onTap: () {
                            setState(() {
                              _expandedMonths[monthKey] = !isExpanded;
                            });
                          },
                          title: Text(
                            '${_monthName(month)} $year',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '\$${monthlyTotal.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: Colors.white70,
                              ),
                            ],
                          ),
                        ),
                        if (isExpanded)
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.white24),
                              ),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: orders.length,
                              itemBuilder: (context, orderIndex) {
                                final order = orders[orderIndex];
                                final total =
                                    (order['total'] as num?)?.toDouble() ?? 0.0;
                                final itemCount =
                                    (order['items'] as List<dynamic>?)
                                        ?.length ??
                                    0;

                                return Container(
                                  decoration: BoxDecoration(
                                    border: orderIndex < orders.length - 1
                                        ? Border(
                                            bottom: BorderSide(
                                              color: Colors.white24,
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: ListTile(
                                    dense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    title: Text(
                                      '$itemCount item${itemCount != 1 ? 's' : ''}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                    trailing: Text(
                                      '\$${total.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                );
                              },
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
    );
  }
}