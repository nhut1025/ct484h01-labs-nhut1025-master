import 'package:pocketbase/pocketbase.dart';

import '../models/cart_item.dart';
import '../models/order_item.dart';
import 'pocketbase_client.dart';

class OrdersService {
  Future<List<OrderItem>> fetchOrders() async {
    final pb = await getPocketbaseInstance();
    final userId = pb.authStore.record?.id;

    if (userId == null) {
      return [];
    }

    try {
      final records = await pb
          .collection('orders')
          .getFullList(
            filter: "user = '$userId'",
            sort: '-created',
          );
      return records.map((r) => OrderItem.fromRecord(r)).toList();
    } catch (error) {
      if (error is ClientException) {
        throw Exception(error.response['message']);
      }
      throw Exception('Không thể tải danh sách đơn hàng');
    }
  }

  Future<OrderItem> addOrder(List<CartItem> cartProducts, double total) async {
    final pb = await getPocketbaseInstance();
    final userId = pb.authStore.record?.id;

    if (userId == null) {
      throw Exception('Bạn cần đăng nhập để đặt hàng');
    }

    final order = OrderItem(
      userId: userId,
      amount: total,
      products: cartProducts,
    );

    try {
      final record = await pb
          .collection('orders')
          .create(
            body: order.toJson(),
          );
      return OrderItem.fromRecord(record);
    } catch (error) {
      if (error is ClientException) {
        throw Exception(error.response['message']);
      }
      throw Exception('Không thể tạo đơn hàng');
    }
  }
}
