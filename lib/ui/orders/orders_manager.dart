import 'package:flutter/foundation.dart';

import '../../models/cart_item.dart';
import '../../models/order_item.dart';
import '../../services/orders_service.dart';

class OrdersManager with ChangeNotifier {
  final OrdersService _ordersService = OrdersService();

  List<OrderItem> _orders = [];
  bool _isLoading = false;

  int get orderCount {
    return _orders.length;
  }

  bool get isLoading {
    return _isLoading;
  }

  List<OrderItem> get orders {
    return [..._orders];
  }

  // Gọi khi vào màn hình Orders, hoặc sau khi login/logout
  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await _ordersService.fetchOrders();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final newOrder = await _ordersService.addOrder(cartProducts, total);
    _orders.insert(0, newOrder);
    notifyListeners();
  }

  // Gọi khi logout để không giữ order của user cũ trong RAM
  void clear() {
    _orders = [];
    notifyListeners();
  }

  String? _lastUserId;

  // Dùng bởi ProxyProvider: chỉ load lại khi user thực sự đổi
  void onAuthUserChanged(String? userId, bool isAuth) {
    if (_lastUserId == userId) return;
    _lastUserId = userId;

    if (isAuth) {
      fetchOrders();
    } else {
      clear();
    }
  }
}
