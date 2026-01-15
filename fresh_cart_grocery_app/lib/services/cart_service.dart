import 'package:flutter/foundation.dart';

class CartItem {
  final String productId;
  final String shopId;
  final String name;
  final double price;
  int qty;
  CartItem({
    required this.productId,
    required this.shopId,
    required this.name,
    required this.price,
    this.qty = 1,
  });
}

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);
  int get totalQty => _items.fold(0, (t, e) => t + e.qty);
  double get totalPrice => _items.fold(0, (t, e) => t + (e.qty * e.price));

  /// Add product with full info; called from product screens
  void add(String productId, String shopId, String name, double price) {
    final idx = _items.indexWhere((i) => i.productId == productId);
    if (idx == -1) {
      _items.add(
        CartItem(
          productId: productId,
          shopId: shopId,
          name: name,
          price: price,
        ),
      );
    } else {
      _items[idx].qty++;
    }
    notifyListeners();
  }

  void increment(String id) {
    final idx = _items.indexWhere((i) => i.productId == id);
    if (idx != -1) {
      _items[idx].qty++;
      notifyListeners();
    }
  }

  void decrement(String id) {
    final idx = _items.indexWhere((i) => i.productId == id);
    if (idx != -1) {
      _items[idx].qty--;
      if (_items[idx].qty == 0) _items.removeAt(idx);
      notifyListeners();
    }
  }

  void remove(String id) {
    _items.removeWhere((i) => i.productId == id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}