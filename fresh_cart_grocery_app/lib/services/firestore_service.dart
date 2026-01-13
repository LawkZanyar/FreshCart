import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // shops collection
  Stream<List<Map<String, dynamic>>> get shops =>
      _db.collection('shops').orderBy('name').snapshots().map(
        (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
      );

  // products sub-collection of a shop
  Stream<List<Map<String, dynamic>>> products(String shopId) =>
      _db.collection('shops').doc(shopId).collection('products').orderBy('name').snapshots().map(
        (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
      );
}
