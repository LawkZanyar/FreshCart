import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
	final FirebaseAuth _auth = FirebaseAuth.instance;
	final FirebaseFirestore _db = FirebaseFirestore.instance;

	User? get currentUser => _auth.currentUser;
	Stream<User?> get authStateChanges => _auth.authStateChanges();

Future<String?> register(String email, String password, String username, {bool isOwner = false, String shopName = ''}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      await credential.user?.updateDisplayName(username);
      await credential.user?.reload();

      if (isOwner && shopName.isNotEmpty) {
        final shopRef = _db.collection('shops').doc();
        await shopRef.set({
          'name': shopName,
          'logo': 'store',
          'ownerId': uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      notifyListeners();
			return null;
		} on FirebaseAuthException catch (e) {
			return e.message;
		}
	}

	Future<String?> login(String email, String password) async {
		try {
			await _auth.signInWithEmailAndPassword(email: email, password: password);
			return null;
		} on FirebaseAuthException catch (e) {
			return e.message;
		}
	}

	Future<void> signOut() async => await _auth.signOut();
}
