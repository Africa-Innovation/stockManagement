import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pour formater la date et la devise
import 'package:stockmanagement/Model/vente_model.dart';

class SaleDetailScreen extends StatelessWidget {
  final Sale sale;

  SaleDetailScreen({required this.sale});

  @override
  Widget build(BuildContext context) {
    // Formater la date
    String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(sale.date);

    // Formater le total
    String formattedTotal = NumberFormat.simpleCurrency().format(sale.totalPrice);

    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la vente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client: ${sale.clientName}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Reçu: ${sale.receiptId}', style: TextStyle(fontSize: 12, color: Colors.grey)), // 🔥 Ajouté ici
            SizedBox(height: 10),
            Text('Date: $formattedDate', style: TextStyle(fontSize: 14)),
            Divider(),
            Text('Produits:', style: TextStyle(fontSize: 18)),
            // Vérification si la vente contient des produits
            if (sale.saleItems.isEmpty)
              Text('Aucun produit associé',
                  style: TextStyle(fontSize: 14, color: Colors.grey))
            else
              ...sale.saleItems.map((saleItem) {
                return ListTile(
                  title: Text('Produit: ${saleItem.product.name}', style: TextStyle(fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quantité vendue: ${saleItem.quantity}', style: TextStyle(fontSize: 14)),
                      Text('Prix: ${saleItem.product.price.toStringAsFixed(2)} \$', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                );
              }).toList(),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(formattedTotal, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
