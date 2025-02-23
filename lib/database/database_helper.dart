import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:stockmanagement/Model/product_model.dart';
import 'package:stockmanagement/Model/receipt_model.dart';
import 'package:stockmanagement/Model/sale_item.dart';
import 'package:stockmanagement/Model/vente_model.dart';
import 'package:stockmanagement/utils/session_manager.dart';
import 'package:uuid/uuid.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  // Global variable to store the receiptId
String globalReceiptId = '';

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('stock_management.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,  // Numéro de version pour recréer la DB
      onCreate: _createDB,
    );
  }


Future<void> _checkAndCreateProductsTable(Database db) async {
  var result = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='products'");
  if (result.isEmpty) {
    await _createDB(db, 1);  // Créer la table si elle n'existe pas
  }
}


  Future _createDB(Database db, int version) async {
  await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      phone TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      quantity INTEGER NOT NULL,
      price REAL NOT NULL,
      minStock INTEGER NOT NULL,
      userPhone TEXT NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE sales (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      totalPrice REAL NOT NULL,
      date TEXT NOT NULL,
      clientName TEXT,
      receiptId TEXT NOT NULL,
      userPhone TEXT NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE sale_products (
      saleId INTEGER NOT NULL,
      productId INTEGER NOT NULL,
      quantity INTEGER NOT NULL,
      price REAL NOT NULL,
      PRIMARY KEY (saleId, productId),
      FOREIGN KEY (saleId) REFERENCES sales(id) ON DELETE CASCADE,
      FOREIGN KEY (productId) REFERENCES products(id) ON DELETE CASCADE
    )
  ''');
  
}


  Future<int> insertProduct(Product product) async {
  final db = await instance.database;
  String? userPhone = await SessionManager.getUserSession(); // Récupérer l'utilisateur connecté

  if (userPhone == null) {
    throw Exception("Utilisateur non connecté !");
  }

  return await db.insert(
    'products',
    {
      'name': product.name,
      'quantity': product.quantity,
      'price': product.price,
      'minStock': product.minStock,
      'userPhone': userPhone, // Associer le produit à l'utilisateur
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}




Future<List<Product>> getAllProducts() async {
  final db = await instance.database;
  String? userPhone = await SessionManager.getUserSession(); // Récupérer l'utilisateur connecté

  if (userPhone == null) {
    throw Exception("Utilisateur non connecté !");
  }

  final result = await db.query(
    'products',
    where: 'userPhone = ?', // Filtrer par utilisateur
    whereArgs: [userPhone],
  );

  return result.map((e) => Product.fromMap(e)).toList();
}



  Future<int> updateProduct(Product product) async {
  final db = await instance.database;
  return await db.update(
    'products',
    {
      'name': product.name,
      'quantity': product.quantity,
      'price': product.price,
      'minStock': product.minStock,
    },
    where: 'id = ?',
    whereArgs: [product.id],
  );
}


  Future<void> deleteProduct(int id) async {
    final db = await instance.database;
    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> createUser(String name, String phone, String password) async {
    final db = await instance.database;
    return await db.insert('users', {
      'name': name,
      'phone': phone,
      'password': password, // Hachage à implémenter
    });
  }

  Future<Map<String, dynamic>?> getUser(String phone, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'phone = ? AND password = ?',
      whereArgs: [phone, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

Future<void> insertSale(Sale sale) async {
  final db = await instance.database;
  String? userPhone = await SessionManager.getUserSession(); // Récupérer l'utilisateur connecté

  if (userPhone == null) {
    throw Exception("Utilisateur non connecté !");
  }

  await db.transaction((txn) async {
    var uuid = Uuid();
    String receiptId = uuid.v4();  
    globalReceiptId = receiptId;

    int saleId = await txn.insert(
      'sales',
      {
        'totalPrice': sale.totalPrice,
        'date': sale.date.toIso8601String(),
        'clientName': sale.clientName,
        'receiptId': receiptId,
        'userPhone': userPhone,  // Associer la vente à l'utilisateur
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    for (var item in sale.saleItems) {
      await txn.insert(
        'sale_products',
        {
          'saleId': saleId,
          'productId': item.product.id,
          'quantity': item.quantity,
          'price': item.product.price,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  });
}




Future<List<Sale>> getAllSales() async {
  final db = await instance.database;
  String? userPhone = await SessionManager.getUserSession(); // Récupérer l'utilisateur connecté

  if (userPhone == null) {
    throw Exception("Utilisateur non connecté !");
  }

  final salesList = await db.query(
    'sales',
    where: 'userPhone = ?', // Filtrer par utilisateur
    whereArgs: [userPhone],
  );

  List<Sale> sales = [];

  for (var sale in salesList) {
    final saleId = sale['id'];

    final saleItemsList = await db.rawQuery('''
      SELECT p.id, p.name, sp.quantity, sp.price 
      FROM sale_products sp
      JOIN products p ON sp.productId = p.id
      WHERE sp.saleId = ?
    ''', [saleId]);

    List<SaleItem> saleItems = saleItemsList.map((item) {
      return SaleItem(
        product: Product(
          id: item['id'] as int,
          name: item['name'] as String,
          quantity: item['quantity'] as int,
          price: item['price'] as double,
          minStock: 0,
        ),
        quantity: item['quantity'] as int,
      );
    }).toList();

    sales.add(Sale(
      id: saleId as int?,
      clientName: sale['clientName'] as String,
      saleItems: saleItems,
      totalPrice: sale['totalPrice'] as double,
      date: DateTime.parse(sale['date'] as String),
      receiptId: sale['receiptId'] as String,
    ));
  }

  return sales;
}

}


