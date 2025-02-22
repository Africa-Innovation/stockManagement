import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:stockmanagement/Model/product_model.dart';
import 'package:stockmanagement/Model/receipt_model.dart';
import 'package:stockmanagement/Model/sale_item.dart';
import 'package:stockmanagement/Model/vente_model.dart';
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
      minStock INTEGER NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE sales (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      totalPrice REAL NOT NULL,
      date TEXT NOT NULL,
      clientName TEXT,
      receiptId TEXT NOT NULL 
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
  print("Insertion du produit : ${product.name}, ${product.quantity}, ${product.price}, ${product.minStock}"); // Debug
  return await db.insert(
    'products',
    {
      'name': product.name,
      'quantity': product.quantity,
      'price': product.price,
      'minStock': product.minStock,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}



  Future<List<Product>> getAllProducts() async {
  final db = await instance.database;
  final result = await db.query('products');
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

  try {
    await db.transaction((txn) async {
      // Générer un UUID unique pour le receiptId
      var uuid = Uuid();
      String receiptId = uuid.v4();  // Génère un ID unique pour le reçu

      // Stocker le receiptId dans la variable globale
      globalReceiptId = receiptId;

      // Insérer la vente avec le receiptId unique
      int saleId = await txn.insert(
        'sales',
        {
          'totalPrice': sale.totalPrice,
          'date': sale.date.toIso8601String(),
          'clientName': sale.clientName,
          'receiptId': receiptId,  // Utilisation du même receiptId pour la vente
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insérer les produits associés à la vente dans la table sale_products
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

      // Récupère et affiche correctement l'ID du reçu ici
      print("🧾 Reçu généré avec ID de vente : $saleId, ID de reçu : $receiptId");
      
      // Autres opérations d'insertion...
    });
  } catch (e) {
    print("❌ Erreur lors de l'insertion de la vente : $e");
  }
}



Future<List<Sale>> getAllSales() async {
  final db = await instance.database;

  final salesList = await db.query('sales');

  List<Sale> sales = [];

  print("📦 Données brutes récupérées de la table sales: $salesList");

  for (var sale in salesList) {
    final saleId = sale['id'];

    // Vérification que receiptId est bien récupéré
    print("📝 Vente récupérée - ID: $saleId, Client: ${sale['clientName']}, Reçu: ${sale['receiptId']}");

    // Récupérer les produits vendus pour cette vente
    final saleItemsList = await db.rawQuery('''
      SELECT p.id, p.name, sp.quantity, sp.price 
      FROM sale_products sp
      JOIN products p ON sp.productId = p.id
      WHERE sp.saleId = ?
    ''', [saleId]);

    // Transformer la liste des produits en liste de SaleItem
    List<SaleItem> saleItems = saleItemsList.map((item) {
      return SaleItem(
        product: Product(
          id: item['id'] as int,
          name: item['name'] as String,
          quantity: item['quantity'] as int,
          price: item['price'] as double,
          minStock: 0,  // Valeur par défaut
        ),
        quantity: item['quantity'] as int,  // Quantité vendue
      );
    }).toList();

    sales.add(Sale(
      id: saleId as int?,
      clientName: sale['clientName'] as String,
      saleItems: saleItems,  
      totalPrice: sale['totalPrice'] as double,
      date: DateTime.parse(sale['date'] as String),
      receiptId: sale['receiptId'] as String,  // Vérification que receiptId est bien récupéré
    ));
  }

  return sales;
}
}


