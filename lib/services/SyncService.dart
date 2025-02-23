import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stockmanagement/Model/product_model.dart';
import 'package:stockmanagement/Model/vente_model.dart';
import 'package:stockmanagement/database/database_helper.dart';
import 'package:stockmanagement/screens/home_screen.dart';
import 'package:stockmanagement/utils/session_manager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> syncDataToFirebase(BuildContext context) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pas de connexion Internet")),
      );
      return;
    }

    String? userPhone = await SessionManager.getUserSession();
    if (userPhone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Utilisateur non connecté")),
      );
      return;
    }

    try {
      // Synchronisation des produits
      List<Product> products = await _dbHelper.getAllProducts();
      CollectionReference productsRef = _firestore.collection('users').doc(userPhone).collection('products');
      for (var product in products) {
        await productsRef.doc(product.id.toString()).set(product.toMap());
      }

      // Synchronisation des ventes
      List<Sale> sales = await _dbHelper.getAllSales();
      CollectionReference salesRef = _firestore.collection('users').doc(userPhone).collection('sales');
      for (var sale in sales) {
        await salesRef.doc(sale.receiptId).set(sale.toMap());
      }
      Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Synchronisation réussie")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de synchronisation : \$e")),
      );
    }
  }
}