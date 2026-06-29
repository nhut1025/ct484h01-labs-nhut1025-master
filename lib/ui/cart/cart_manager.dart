import 'package:flutter/foundation.dart';

import '../../models/cart_item.dart';
import '../../models/product.dart';
import '../../services/cart_database.dart';

class CartManager with ChangeNotifier {
  String? _userId;
  Map<String, CartItem> _items = {};

  int get productCount {
    return _items.length;
  }

  List<CartItem> get products {
    return _items.values.toList();
  }

  Iterable<MapEntry<String, CartItem>> get productEntries {
    return {..._items}.entries;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((_, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  // Gọi khi user login/logout hoặc đổi user, để load đúng cart từ SQLite
  Future<void> setUser(String? userId) async {
    if (_userId == userId) return; // tránh load lại không cần thiết
    _userId = userId;

    if (userId == null) {
      _items = {};
    } else {
      _items = await CartDatabase.getItems(userId);
    }
    notifyListeners();
  }

  Future<void> addItem(Product product, {int quantity = 1}) async {
    if (product.id == null || quantity <= 0 || _userId == null) {
      return;
    }

    final userId = _userId!;
    final productId = product.id!;

    if (_items.containsKey(productId)) {
      final updated = _items[productId]!.copyWith(
        quantity: _items[productId]!.quantity + quantity,
      );
      _items[productId] = updated;
      await CartDatabase.upsertItem(userId, productId, updated);
    } else {
      final newItem = CartItem(
        id: 'c${DateTime.now().toIso8601String()}',
        title: product.title,
        imageUrl: product.imageUrl,
        price: product.price,
        quantity: quantity,
      );
      _items[productId] = newItem;
      await CartDatabase.upsertItem(userId, productId, newItem);
    }
    notifyListeners();
  }

  Future<void> removeItem(String productId) async {
    if (!_items.containsKey(productId) || _userId == null) {
      return;
    }

    final userId = _userId!;

    if (_items[productId]!.quantity > 1) {
      final updated = _items[productId]!.copyWith(
        quantity: _items[productId]!.quantity - 1,
      );
      _items[productId] = updated;
      await CartDatabase.upsertItem(userId, productId, updated);
    } else {
      _items.remove(productId);
      await CartDatabase.deleteItem(userId, productId);
    }
    notifyListeners();
  }

  Future<void> clearItem(String productId) async {
    if (_userId == null) return;

    _items.remove(productId);
    await CartDatabase.deleteItem(_userId!, productId);
    notifyListeners();
  }

  Future<void> clearAllItems() async {
    if (_userId == null) return;

    _items = {};
    await CartDatabase.clearAll(_userId!);
    notifyListeners();
  }

  Future<void> clear() async {
    await clearAllItems();
  }
}
