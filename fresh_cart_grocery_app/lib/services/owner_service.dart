import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OwnerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  /// The shop owned by the current user (single doc), or null if none.
  Stream<Map<String, dynamic>?> get myShop => _db
      .collection('shops')
      .where('ownerId', isEqualTo: uid)
      .limit(1)
      .snapshots()
      .map(
        (s) => s.docs.isEmpty
            ? null
            : {'id': s.docs.first.id, ...s.docs.first.data()},
      );

  // new orders (status == Pending) with details for this shop
  Stream<List<Map<String, dynamic>>> newOrdersDetailed() =>
      myShop.asyncExpand((shop) {
        final shopId = shop?['id'];
        if (shopId == null) return Stream.value(<Map<String, dynamic>>[]);
        return _db
            .collection('orders')
            .where('shopId', isEqualTo: shopId)
            .where('status', isEqualTo: 'Pending')
            .snapshots()
            .map((s) => s.docs.map((d) => {...d.data(), 'id': d.id}).toList());
      });

  // pending today (status == Pending, last 24h) with details for this shop
  Stream<List<Map<String, dynamic>>> pendingTodayDetailed() =>
      myShop.asyncExpand((shop) {
        final shopId = shop?['id'];
        if (shopId == null) return Stream.value(<Map<String, dynamic>>[]);
        final cutoff = DateTime.now().subtract(const Duration(days: 1));
        return _db
            .collection('orders')
            .where('shopId', isEqualTo: shopId)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map(
              (s) => s.docs
                  .where((d) {
                    final status = (d['status'] ?? '').toString().toLowerCase();
                    if (status != 'pending') return false;
                    final ts = d['createdAt'] as Timestamp?;
                    if (ts == null) return false;
                    return ts.toDate().isAfter(cutoff);
                  })
                  .map((d) => {...d.data(), 'id': d.id})
                  .toList(),
            );
      });

  // sum of orders marked Delivered today for this shop
  Stream<double> revenueToday() => myShop.asyncExpand((shop) {
    final shopId = shop?['id'];
    if (shopId == null) return Stream.value(0.0);
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return _db
        .collection('orders')
        .where('shopId', isEqualTo: shopId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (s) => s.docs.fold(0.0, (t, d) {
            final status = (d['status'] ?? '').toString().toLowerCase();
            if (status != 'delivered') return t;
            final ts = d['createdAt'] as Timestamp?;
            if (ts == null) return t;
            final dt = ts.toDate();
            if (dt.isBefore(todayStart)) return t;
            final total = (d['total'] as num?)?.toDouble() ?? 0.0;
            return t + total;
          }),
        );
  });

  // sum of orders marked Delivered yesterday for this shop
  Stream<double> revenueYesterday() {
    final now = DateTime.now();
    final yesterdayStart = DateTime(now.year, now.month, now.day - 1);
    final todayStart = DateTime(now.year, now.month, now.day);
    return myShop.asyncExpand((shop) {
      final shopId = shop?['id'];
      if (shopId == null) return Stream.value(0.0);
      return _db
          .collection('orders')
          .where('shopId', isEqualTo: shopId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (s) => s.docs.fold(0.0, (t, d) {
              final status = (d['status'] ?? '').toString().toLowerCase();
              if (status != 'delivered') return t;
              final ts = d['createdAt'] as Timestamp?;
              if (ts == null) return t;
              final dt = ts.toDate();
              if (dt.isBefore(yesterdayStart) || !dt.isBefore(todayStart))
                return t;
              final total = (d['total'] as num?)?.toDouble() ?? 0.0;
              return t + total;
            }),
          );
    });
  }
}
