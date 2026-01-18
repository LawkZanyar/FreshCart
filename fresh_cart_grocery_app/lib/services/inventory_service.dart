import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InventoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String get uid => FirebaseAuth.instance.currentUser!.uid;

  // real-time products sub-collection of **my** shop
  Stream<List<Map<String, dynamic>>> get myProducts => _db
      .collection('shops')
      .where('ownerId', isEqualTo: uid)
      .limit(1)
      .snapshots()
      .map((s) => s.docs.first.id) // shopId
      .asyncExpand(
        (shopId) => _db
            .collection('shops')
            .doc(shopId)
            .collection('products')
            .orderBy('name')
            .snapshots()
            .map(
              (snap) =>
                  snap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
            ),
      );

  Future<void> updateStock(String productId, int newStock) async {
    final shopId = await _shopId();
    await _db
        .collection('shops')
        .doc(shopId)
        .collection('products')
        .doc(productId)
        .update({'stock': newStock});
  }

  Future<void> updateProduct(
    String productId,
    String name,
    double price,
  ) async {
    final shopId = await _shopId();
    await _db
        .collection('shops')
        .doc(shopId)
        .collection('products')
        .doc(productId)
        .update({'name': name, 'price': price});
  }

  Future<void> addProduct(
    String name,
    int stock,
    double price,
    String logo,
  ) async {
    final shopId = await _shopId();
    await _db.collection('shops').doc(shopId).collection('products').add({
      'name': name,
      'stock': stock,
      'price': price,
      'logo': logo,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> _shopId() async =>
      (await _db
              .collection('shops')
              .where('ownerId', isEqualTo: uid)
              .limit(1)
              .get())
          .docs
          .first
          .id;
}
