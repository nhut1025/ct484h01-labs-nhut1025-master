import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/cart_item.dart';

class CartDatabase {
  static Database? _db;

  static Future<Database> _getDatabase() async {
    if (_db != null) {
      return _db!;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cart.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE cart_items (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            product_id TEXT NOT NULL,
            title TEXT NOT NULL,
            image_url TEXT NOT NULL,
            price REAL NOT NULL,
            quantity INTEGER NOT NULL
          )
        ''');
      },
    );

    return _db!;
  }

  // Lấy toàn bộ cart của 1 user, trả về Map<productId, CartItem>
  static Future<Map<String, CartItem>> getItems(String userId) async {
    final db = await _getDatabase();
    final rows = await db.query(
      'cart_items',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    final Map<String, CartItem> items = {};
    for (final row in rows) {
      items[row['product_id'] as String] = CartItem(
        id: row['id'] as String,
        title: row['title'] as String,
        imageUrl: row['image_url'] as String,
        price: row['price'] as double,
        quantity: row['quantity'] as int,
      );
    }
    return items;
  }

  // Thêm hoặc cập nhật 1 item (upsert theo user_id + product_id)
  static Future<void> upsertItem(
    String userId,
    String productId,
    CartItem item,
  ) async {
    final db = await _getDatabase();
    await db.insert(
      'cart_items',
      {
        'id': item.id,
        'user_id': userId,
        'product_id': productId,
        'title': item.title,
        'image_url': item.imageUrl,
        'price': item.price,
        'quantity': item.quantity,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteItem(String userId, String productId) async {
    final db = await _getDatabase();
    await db.delete(
      'cart_items',
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId, productId],
    );
  }

  static Future<void> clearAll(String userId) async {
    final db = await _getDatabase();
    await db.delete(
      'cart_items',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
