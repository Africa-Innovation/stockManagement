

import 'package:flutter/material.dart';
import 'package:stockmanagement/Model/product_model.dart';
import '../database/database_helper.dart';
 
class ProductManagementScreen extends StatefulWidget {
  @override
  _ProductManagementScreenState createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  late List<Product> products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
  final data = await DatabaseHelper.instance.getAllProducts();
  print("Produits chargés : $data"); // Debug
  setState(() {
    products = data;
  });
}


  void _showProductDialog({Product? product}) {
  final nameController = TextEditingController(text: product?.name ?? '');
  final quantityController = TextEditingController(text: product?.quantity.toString() ?? '');
  final priceController = TextEditingController(text: product?.price.toString() ?? '');
  final minStockController = TextEditingController(text: product?.minStock.toString() ?? '');

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(product == null ? 'Ajouter un produit' : 'Modifier le produit'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Nom')),
            TextField(controller: quantityController, decoration: InputDecoration(labelText: 'Quantité'), keyboardType: TextInputType.number),
            TextField(controller: priceController, decoration: InputDecoration(labelText: 'Prix'), keyboardType: TextInputType.number),
            TextField(controller: minStockController, decoration: InputDecoration(labelText: 'Stock minimum'), keyboardType: TextInputType.number),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler')),
        ElevatedButton(
          onPressed: () async {
            final name = nameController.text.trim();
            final quantity = int.tryParse(quantityController.text);
            final price = double.tryParse(priceController.text);
            final minStock = int.tryParse(minStockController.text);

            // Vérifier si tous les champs sont renseignés
            if (name.isEmpty || quantity == null || price == null || minStock == null) {
              _showErrorDialog('Tous les champs doivent être remplis correctement.');
              return;
            }

            // Vérification si le stock minimum est supérieur à la quantité
            if (minStock > quantity) {
              _showErrorDialog('Le stock minimum ne peut pas être supérieur à la quantité.');
              return;
            }

            final newProduct = Product(
              id: product?.id,
              name: name,
              quantity: quantity,
              price: price,
              minStock: minStock,
            );

            if (product == null) {
              await DatabaseHelper.instance.insertProduct(newProduct);
            } else {
              await DatabaseHelper.instance.updateProduct(newProduct);
            }

            _loadProducts();
            Navigator.pop(context);
          },
          child: Text(product == null ? 'Ajouter' : 'Modifier'),
        ),
      ],
    ),
  );
}

void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Erreur'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}


  void _deleteProduct(int id) async {
  // Afficher un dialogue de confirmation avant la suppression
  bool? confirmDelete = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer ce produit ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Annuler la suppression
            },
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Confirmer la suppression
            },
            child: Text('Supprimer'),
          ),
        ],
      );
    },
  );

  // Si la suppression est confirmée, on supprime le produit
  if (confirmDelete == true) {
    await DatabaseHelper.instance.deleteProduct(id);
    _loadProducts(); // Recharger la liste des produits
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestion des produits')),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            title: Text(product.name),
            subtitle: Text('Stock: ${product.quantity} - Prix: ${product.price} \$'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Icons.edit), onPressed: () => _showProductDialog(product: product)),
                IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteProduct(product.id!)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
