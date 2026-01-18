import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../services/cart_service.dart'; // local models

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid;

  OrderService({required this.uid});

  Future<String> createOrder(List<CartItem> items, double total) async {
    if (items.isEmpty) throw Exception('Cannot create order with no items');

    // All items should be from the same shop
    final shopId = items.first.shopId;

    final orderRef = _db.collection('orders').doc();
    await orderRef.set({
      'userId': uid,
      'shopId': shopId,
      'items': items
          .map(
            (i) => {
              'productId': i.productId,
              'name': i.name,
              'price': i.price,
              'qty': i.qty,
            },
          )
          .toList(),
      'total': total,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Decrease stock for each product
    final batch = _db.batch();
    for (final item in items) {
      final productRef = _db
          .collection('shops')
          .doc(shopId)
          .collection('products')
          .doc(item.productId);
      batch.update(productRef, {'stock': FieldValue.increment(-item.qty)});
    }
    await batch.commit();

    // Auto-update status to Delivered after 2 minutes
    _scheduleStatusUpdate(orderRef.id, 'Delivered', Duration(minutes: 2));

    return orderRef.id;
  }

  /// Schedule automatic status update for an order
  void _scheduleStatusUpdate(String orderId, String newStatus, Duration delay) {
    Timer(delay, () async {
      try {
        await updateStatus(orderId, newStatus);
      } catch (e) {
        // Silently fail if update doesn't work
      }
    });
  }

  Stream<List<Map<String, dynamic>>> userOrders() => _db
      .collection('orders')
      .where('userId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());

  /// Orders for a specific shop (scoped owner view)
  Stream<List<Map<String, dynamic>>> myShopOrders(String shopId) => _db
      .collection('orders')
      .where('shopId', isEqualTo: shopId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());

  Future<void> updateStatus(String orderId, String status) =>
      _db.collection('orders').doc(orderId).update({'status': status});
}
