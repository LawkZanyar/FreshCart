import 'package:flutter/foundation.dart';
import '../dummy_data/dummy_data.dart';

class CartItem {
  final String productId;
  final String name;
  final double price;
  int qty;
  CartItem({required this.productId, required this.name, required this.price, this.qty = 1});
}

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);
  int get totalQty => _items.fold(0, (t, e) => t + e.qty);
  double get totalPrice => _items.fold(0, (t, e) => t + (e.qty * e.price));

  void add(String id) {
    final product = dummyProducts.firstWhere((p) => p['id'] == id);
    final idx = _items.indexWhere((i) => i.productId == id);
    if (idx == -1) {
      _items.add(CartItem(
        productId: id,
        name: product['name'],
        price: product['price'],
      ));
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