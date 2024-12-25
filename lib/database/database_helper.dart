import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/item.dart';
import '../models/transaction.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'inventory.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        category TEXT,
        price REAL,
        stock INTEGER,
        imagePath TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        itemId INTEGER,
        type TEXT,
        quantity INTEGER,
        date TEXT,
        FOREIGN KEY (itemId) REFERENCES items (id)
      )
    ''');
  }

  // CRUD untuk Item
  Future<int> insertItem(Item item) async {
    final db = await database;
    return await db.insert('items', item.toMap());
  }

  Future<List<Item>> getItems() async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query('items');
    return results.map((map) => Item.fromMap(map)).toList();
  }

  Future<int> updateItemStock(int id, int stock) async {
    final db = await database;
    return await db.update('items', {'stock': stock},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    await db.delete('transactions', where: 'itemId = ?', whereArgs: [id]);
    return await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateItem(Item item) async {
    final db = await database;
    return await db
        .update('items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  // CRUD untuk Transactions
  Future<int> insertTransaction(ItemTransaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<ItemTransaction>> getTransactions(int itemId) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db
        .query('transactions', where: 'itemId = ?', whereArgs: [itemId]);
    return results.map((map) => ItemTransaction.fromMap(map)).toList();
  }
}
