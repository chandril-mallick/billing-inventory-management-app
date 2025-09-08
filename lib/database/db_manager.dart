//import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  final Logger _logger = Logger();

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('customers.db');
    return _database!;
  }

  Future<Database> _initDB(String dbName) async {
    // Get the documents directory path for Android
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, dbName);
    
    _logger.i('Database path: $path');

    // Open the database
    return await openDatabase(
      path,
      version: 6, // Incremented version to apply changes
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    _logger.i('Creating database with version $version...');
    await db.execute('''
      CREATE TABLE customers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        phone TEXT,
        address TEXT,
        balance REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE suppliers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        phone TEXT,
        address TEXT,
        balance REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productName TEXT,
        purchasePrice REAL,
        salePrice REAL,
        stock INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE purchaseOrders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        orderNo TEXT,
        supplier TEXT,
        purchaseReturn REAL,
        orderAmount REAL,
        discount REAL,
        prevBalance REAL,
        billPaid REAL,
        balance REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE saleOrders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        orderNo TEXT,
        customer TEXT,
        orderAmount REAL,
        discount REAL,
        prevBalance REAL,
        billPaid REAL,
        balance REAL
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    _logger.i('Upgrading database from version $oldVersion to $newVersion...');
    if (oldVersion < 5) {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS saleOrders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        orderNo TEXT,
        customer TEXT,
        orderAmount REAL,
        discount REAL,
        prevBalance REAL,
        billPaid REAL,
        balance REAL
      )
    ''');
    }
  }

  // ---------------- CRUD Operations ------------------

  Future<int> addPurchaseOrder(Map<String, dynamic> purchaseOrder) async {
    final db = await instance.database;
    return await db.insert('purchaseOrders', purchaseOrder);
  }

  Future<List<Map<String, dynamic>>> getAllPurchaseOrders() async {
    final db = await instance.database;
    return await db.query('purchaseOrders');
  }

  Future<Map<String, dynamic>?> getPurchaseOrderById(int id) async {
    final db = await instance.database;
    final results = await db.query(
      'purchaseOrders',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> addSaleOrder(Map<String, dynamic> saleOrder) async {
    final db = await instance.database;
    return await db.insert('saleOrders', saleOrder);
  }

  Future<List<Map<String, dynamic>>> getAllSaleOrders() async {
    final db = await instance.database;
    return await db.query('saleOrders');
  }

  Future<Map<String, dynamic>?> getSaleOrderById(int id) async {
    final db = await instance.database;
    final results = await db.query(
      'saleOrders',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> addCustomer(Map<String, dynamic> customer) async {
    final db = await instance.database;
    return await db.insert('customers', customer);
  }

  Future<List<Map<String, dynamic>>> getAllCustomers() async {
    final db = await instance.database;
    return await db.query('customers');
  }

  Future<int> addSupplier(Map<String, dynamic> supplier) async {
    final db = await instance.database;
    return await db.insert('suppliers', supplier);
  }

  Future<List<Map<String, dynamic>>> getAllSuppliers() async {
    final db = await instance.database;
    return await db.query('suppliers');
  }

  Future<int> addProduct(Map<String, dynamic> product) async {
    final db = await instance.database;
    return await db.insert('products', product);
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await instance.database;
    return await db.query('products');
  }

  Future<List<Map<String, dynamic>>> searchSuppliers(String query) async {
    final db = await instance.database;
    return await db.query(
      'suppliers',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
  }

  Future<List<Map<String, dynamic>>> searchCustomers(String query) async {
    final db = await instance.database;
    return await db.query(
      'customers',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
  }

  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final db = await instance.database;
    return await db.query(
      'products',
      where: 'productName LIKE ?',
      whereArgs: ['%$query%'],
    );
  }

  Future<int> deletePurchaseOrderByOrderNo(String orderNo) async {
    final db = await instance.database;
    return await db.delete(
      'purchaseOrders',
      where: 'orderNo = ?',
      whereArgs: [orderNo],
    );
  }

  Future<int> deleteSaleOrderByOrderNo(String orderNo) async {
    final db = await instance.database;
    return await db.delete(
      'saleOrders',
      where: 'orderNo = ?',
      whereArgs: [orderNo],
    );
  }

  Future<int> deleteCustomerById(int id) async {
    final db = await instance.database;
    return await db.delete(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteSupplierById(int id) async {
    final db = await instance.database;
    return await db.delete(
      'suppliers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteProductById(int id) async {
    final db = await instance.database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteDatabaseFile() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'customers.db');
    await deleteDatabase(path);
    _logger.i('Database deleted successfully at $path.');
  }

  // ---------------- Stats Operations ------------------

  Future<double> getTotalPurchasesAmount() async {
    final db = await instance.database;
    final result =
        await db.rawQuery('SELECT SUM(billPaid) FROM purchaseOrders');
    return result.isNotEmpty && result.first.values.first != null
        ? (result.first.values.first as double)
        : 0.0;
  }

  Future<double> getTotalSalesAmount() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT SUM(billPaid) FROM saleOrders');
    return result.isNotEmpty && result.first.values.first != null
        ? (result.first.values.first as double)
        : 0.0;
  }

  Future<int> getTotalSuppliers() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM suppliers');
    return result.isNotEmpty ? result.first.values.first as int : 0;
  }

  Future<int> getTotalCustomers() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM customers');
    return result.isNotEmpty ? result.first.values.first as int : 0;
  }

  Future<int> getTotalProducts() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM products');
    return result.isNotEmpty ? result.first.values.first as int : 0;
  }
}