


import 'package:flutter/material.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:stockmanagement/Model/receipt_model.dart';
import 'package:stockmanagement/Model/sale_item.dart';
import 'package:stockmanagement/Model/vente_model.dart';
import 'package:stockmanagement/database/database_helper.dart';
import 'package:stockmanagement/Model/product_model.dart';
import 'package:stockmanagement/screens/ReceiptPreviewScreen.dart';
import 'package:uuid/uuid.dart';


class SaleScreen extends StatefulWidget {
  @override
  _SaleScreenState createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  late List<Product> products = [];
  final Map<int, int> selectedProducts = {};  // key: productId, value: quantity
  double totalAmount = 0.0;
  final TextEditingController clientNameController = TextEditingController();  // Pour saisir le nom du client
  //String generatedReceiptId = Uuid().v4();  // Remplacer la génération de l'ID par un UUID
// Générer un identifiant unique pour le reçu
final String receiptId = Uuid().v4(); 

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final data = await DatabaseHelper.instance.getAllProducts();
    setState(() {
      products = data;
    });
  }

  void _onProductQuantityChanged(int productId, int quantity) {
    final product = products.firstWhere((p) => p.id == productId);

    if (quantity > product.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quantité supérieure au stock disponible')),
      );
    } else {
      setState(() {
        selectedProducts[productId] = quantity;
        _calculateTotalAmount();
      });
    }
  }

  void _calculateTotalAmount() {
    double amount = 0.0;
    selectedProducts.forEach((productId, quantity) {
      final product = products.firstWhere((p) => p.id == productId);
      amount += product.price * quantity;
    });
    setState(() {
      totalAmount = amount;
    });
  }

  void _processSale() async {
  String clientName = clientNameController.text.trim();

  if (clientName.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Veuillez entrer un nom de client')),
    );
    return;
  }

  // Afficher la boîte de dialogue de confirmation
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmer la vente'),
        content: Text('Êtes-vous sûr de vouloir valider cette vente pour le client "$clientName" ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _confirmSale(clientName);
            },
            child: Text('Confirmer'),
          ),
        ],
      );
    },
  );
}

Future<void> _confirmSale(String clientName) async {
  final db = await DatabaseHelper.instance.database;
  double totalAmount = 0.0;

  // Générer un ID unique pour le reçu (juste ici une fois)
  final String receiptId = Uuid().v4();  // ID unique pour chaque vente

  await db.transaction((txn) async {
    for (var entry in selectedProducts.entries) {
      final productId = entry.key;
      final quantity = entry.value;
      final product = products.firstWhere((p) => p.id == productId);

      if (quantity > product.quantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quantité supérieure au stock disponible pour ${product.name}')),
        );
        return;
      }

      product.quantity -= quantity;
      await txn.update(
        'products',
        {'quantity': product.quantity},
        where: 'id = ?',
        whereArgs: [product.id],
      );
    }
  });

  totalAmount = selectedProducts.entries.fold(0.0, (sum, entry) {
    final product = products.firstWhere((p) => p.id == entry.key);
    return sum + product.price * entry.value;
  });

  // Créer la liste des items du reçu
  List<ReceiptItem> receiptItems = selectedProducts.entries.map((entry) {
    final product = products.firstWhere((p) => p.id == entry.key);
    return ReceiptItem(product: product, quantity: entry.value);
  }).toList();

  // Créer la vente avec l'ID du reçu généré
  Sale sale = Sale(
    id: DateTime.now().millisecondsSinceEpoch, 
    clientName: clientName,
    saleItems: selectedProducts.entries.map((entry) {
      final product = products.firstWhere((p) => p.id == entry.key);
      return SaleItem(product: product, quantity: entry.value);
    }).toList(),
    totalPrice: totalAmount,
    date: DateTime.now(),
    receiptId: receiptId,  // Associer l'ID généré à la vente
  );

  // Ajouter la vente à la base de données
  await DatabaseHelper.instance.insertSale(sale);

  // Créer l'objet Receipt avec le même ID
  final receipt = Receipt(
    id: sale.id.toString(),
    clientName: clientName,
    items: receiptItems,
    totalAmount: totalAmount,
    date: DateTime.now().toString(),
    saleId: sale.id!,
    receiptId: receiptId,  // Utilisation de l'ID unique pour le reçu
  );

  // Naviguer vers la page de prévisualisation du reçu
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ReceiptPreviewScreen(receipt: receipt),
    ),
  );

  // Vider la sélection après la vente
  setState(() {
    selectedProducts.clear();
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Vente réussie !')),
  );

  _loadProducts();
  clientNameController.clear();
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Écran de vente'),
      ),
      body: Column(
        children: [
          // Champ pour saisir le nom du client
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: clientNameController,
              decoration: InputDecoration(labelText: "Nom du client"),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('Prix: ${product.price} \$'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          if (selectedProducts[product.id] != null &&
                              selectedProducts[product.id]! > 0) {
                            _onProductQuantityChanged(
                              product.id!,
                              selectedProducts[product.id]! - 1,
                            );
                          }
                        },
                      ),
                      Text(selectedProducts[product.id]?.toString() ?? '0'),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          _onProductQuantityChanged(
                            product.id!,
                            (selectedProducts[product.id] ?? 0) + 1,
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total: \$${totalAmount.toStringAsFixed(2)}'),
                ElevatedButton(
                  onPressed: totalAmount > 0 ? _processSale : null,
                  child: Text('Valider la vente'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
