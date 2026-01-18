import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/order_service.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

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

  Future<String> _getShopName(String shopId) async {
    final doc = await FirebaseFirestore.instance
        .collection('shops')
        .doc(shopId)
        .get();
    return doc.exists
        ? (doc.data()?['name'] ?? 'Unknown Shop')
        : 'Unknown Shop';
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view order history')),
      );
    }

    final orderService = OrderService(uid: uid);

    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: orderService.userOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!;
          if (orders.isEmpty) {
            return Center(
              child: Text(
                'No orders yet',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final order = orders[i];
              return _OrderCard(
                order: order,
                getShopName: _getShopName,
                statusColor: _statusColor,
              );
            },
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatefulWidget {
  final Map<String, dynamic> order;
  final Future<String> Function(String) getShopName;
  final Color Function(String) statusColor;

  const _OrderCard({
    required this.order,
    required this.getShopName,
    required this.statusColor,
  });

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final orderId = widget.order['id'] as String?;
    final status = (widget.order['status'] ?? 'Pending') as String;
    final total = (widget.order['total'] ?? 0.0) as double;
    final createdAt = widget.order['createdAt'] as Timestamp?;
    final items =
        (widget.order['items'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    final shopId = widget.order['shopId'] as String?;

    final createdDate = createdAt?.toDate() ?? DateTime.now();
    final dateStr =
        '${createdDate.month}/${createdDate.day}/${createdDate.year}';

    return Card(
      elevation: 0,
      child: Column(
        children: [
          ListTile(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            leading: Container(
              width: 8,
              height: double.infinity,
              decoration: BoxDecoration(
                color: widget.statusColor(status),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            title: FutureBuilder<String>(
              future: shopId != null
                  ? widget.getShopName(shopId)
                  : Future.value('Unknown Shop'),
              builder: (context, shopSnap) {
                return Text(
                  shopSnap.data ?? 'Loading...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            subtitle: Text(
              '$dateStr • ${items.length} item${items.length != 1 ? 's' : ''}',
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      status,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: widget.statusColor(status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 24,
                ),
              ],
            ),
          ),
          if (_isExpanded)
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white24)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Details',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Order ID: ${orderId?.substring(0, 8) ?? 'Unknown'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Items:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item['name']} × ${item['qty']}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            '\$${((item['price'] ?? 0.0) * (item['qty'] ?? 1)).toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
