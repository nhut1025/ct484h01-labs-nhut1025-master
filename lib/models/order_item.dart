import 'package:pocketbase/pocketbase.dart';

import 'cart_item.dart';

class OrderItem {
  final String? id;
  final String userId;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  int get productCount {
    return products.length;
  }

  OrderItem({
    this.id,
    required this.userId,
    required this.amount,
    required this.products,
    DateTime? dateTime,
  }) : dateTime = dateTime ?? DateTime.now();

  OrderItem copyWith({
    String? id,
    String? userId,
    double? amount,
    List<CartItem>? products,
    DateTime? dateTime,
  }) {
    return OrderItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      products: products ?? this.products,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  // Dữ liệu gửi lên PocketBase khi tạo order mới
  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'amount': amount,
      'products': products
          .map(
            (item) => {
              'id': item.id,
              'title': item.title,
              'imageUrl': item.imageUrl,
              'quantity': item.quantity,
              'price': item.price,
            },
          )
          .toList(),
    };
  }

  // Đọc từ RecordModel trả về bởi PocketBase
  factory OrderItem.fromRecord(RecordModel record) {
    final rawProducts = record.data['products'] as List<dynamic>? ?? [];

    return OrderItem(
      id: record.id,
      userId: record.data['user'] as String? ?? '',
      amount: (record.data['amount'] as num?)?.toDouble() ?? 0.0,
      products: rawProducts.map((p) {
        final map = p as Map<String, dynamic>;
        return CartItem(
          id: map['id'] as String,
          title: map['title'] as String,
          imageUrl: map['imageUrl'] as String,
          quantity: map['quantity'] as int,
          price: (map['price'] as num).toDouble(),
        );
      }).toList(),
      dateTime: DateTime.tryParse(record.created) ?? DateTime.now(),
    );
  }
}
