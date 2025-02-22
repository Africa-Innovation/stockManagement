import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockmanagement/Model/vente_model.dart';
import 'package:stockmanagement/database/database_helper.dart';
import 'package:stockmanagement/screens/SaleDetailScreen.dart';

class SaleHistoryScreen extends StatefulWidget {
  @override
  _SaleHistoryScreenState createState() => _SaleHistoryScreenState();
}

class _SaleHistoryScreenState extends State<SaleHistoryScreen> {
  late List<Sale> salesHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSalesHistory();
  }

 Future<void> _loadSalesHistory() async {
  final salesData = await DatabaseHelper.instance.getAllSales();
  setState(() {
    // Trier les ventes par date, de la plus récente à la plus ancienne
    salesData.sort((a, b) => b.date.compareTo(a.date)); // Tri décroissant sur la date
    salesHistory = salesData;
    isLoading = false;
  });

  print("🔍 Vérification des ventes récupérées...");
  for (var sale in salesData) {
    print("Vente #${sale.id} - Client: ${sale.clientName} - Total: ${sale.totalPrice} - Date: ${sale.date}");
    for (var saleItem in sale.saleItems) {
      print("  - Produit: ${saleItem.product.name}, Quantité vendue: ${saleItem.quantity}, Prix: ${saleItem.product.price}");
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique des Ventes'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : salesHistory.isEmpty
              ? Center(child: Text('Aucune vente effectuée'))
              : ListView.builder(
                  itemCount: salesHistory.length,
                  itemBuilder: (context, index) {
                    final sale = salesHistory[index];
                    String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(sale.date);

                    return ListTile(
                      
                      title: Text('Vente du $formattedDate'),
                      subtitle: Column(
                        children: [
                          Text('Total: ${sale.totalPrice.toStringAsFixed(2)} \$'),
                          Text('Reçu: ${sale.receiptId}', style: TextStyle(fontSize: 12, color: Colors.grey)), // 🔥 Ajouté ici
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SaleDetailScreen(sale: sale),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
