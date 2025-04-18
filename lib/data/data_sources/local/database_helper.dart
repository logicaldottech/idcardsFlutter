import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('orders.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Table for manual entries
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT NOT NULL,
        templateId TEXT,
        logo TEXT,
        signature TEXT
      )
    ''');

    // Table for Excel uploads
    await db.execute('''
      CREATE TABLE excel_orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT NOT NULL,
        templateId TEXT,
        logo TEXT,
        signature TEXT

      )
    ''');
  }

  /// Fetches orders from the specified table (default is 'orders').
  Future<List<Map<String, dynamic>>> getOrders(String templateId,
      {String tableName = 'orders'}) async {
    final db = await database;
    return await db
        .query(tableName, where: 'templateId = ?', whereArgs: [templateId]);
  }

  /// Updates a specific order in the specified table (default is 'orders').
  Future<void> updateOrder(int id, String jsonData,
      {String tableName = 'orders'}) async {
    final db = await database;
    await db.update(
      tableName,
      {'data': jsonData},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deletes a specific order from the specified table (default is 'orders').
  Future<void> deleteOrder(int id, {String tableName = 'orders'}) async {
    final db = await database;
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  /// Clears all entries from a specified table.
  Future<void> clearTable(String tableName) async {
    final db = await database;
    await db.delete(tableName);
  }

  Future<void> clearTableWithTemplateId(String tableName,
      {required String templateId}) async {
    final db = await database;
    await db
        .delete(tableName, where: "templateId = ?", whereArgs: [templateId]);
  }

  /// Deletes the entire database file.
  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'orders.db');
    await database; // Ensure the database is initialized.
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    await deleteDatabase(path);
  }

  /// Closes the database connection.
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
