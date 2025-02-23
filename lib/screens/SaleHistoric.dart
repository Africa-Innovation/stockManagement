import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockmanagement/Model/vente_model.dart';
import 'package:stockmanagement/database/database_helper.dart';
import 'package:stockmanagement/screens/SaleDetailScreen.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SaleHistoryScreen extends StatefulWidget {
  @override
  _SaleHistoryScreenState createState() => _SaleHistoryScreenState();
}

class _SaleHistoryScreenState extends State<SaleHistoryScreen> {
  late List<Sale> salesHistory = [];
  late List<Sale> filteredSales = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSalesHistory();
    searchController.addListener(_filterSales);
  }

  Future<void> _loadSalesHistory() async {
    final salesData = await DatabaseHelper.instance.getAllSales();
    setState(() {
      salesData.sort((a, b) => b.date.compareTo(a.date));
      salesHistory = salesData;
      filteredSales = salesData;
      isLoading = false;
    });
  }

  void _filterSales() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredSales = salesHistory.where((sale) {
        return sale.clientName.toLowerCase().contains(query) ||
               sale.receiptId.toString().contains(query);
      }).toList();
    });
  }

  Future<void> _generatePDF() async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Historique des Ventes",
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            ...filteredSales.map((sale) => pw.Container(
                  margin: pw.EdgeInsets.only(bottom: 10),
                  padding: pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey)),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
        "Total des ventes: ${getTotalSalesAmount().toStringAsFixed(2)} \$",
        style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, ),
      ),
                      pw.Text("Client: ${sale.clientName}",
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.Text("Date: ${DateFormat('dd/MM/yyyy HH:mm').format(sale.date)}"),
                      pw.Text("Reçu ID: ${sale.receiptId}"),
                      pw.SizedBox(height: 5),
                      pw.Text("Produits achetés :",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: sale.saleItems.map((item) {
                          return pw.Text(
                              "- ${item.product.name} x${item.quantity} : ${(item.product.price * item.quantity).toStringAsFixed(2)} \$",
                              style: pw.TextStyle(fontSize: 12));
                        }).toList(),
                      ),
                      pw.Divider(),
                      pw.Text("Total: ${sale.totalPrice.toStringAsFixed(2)} \$",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                )),
          ],
        );
      },
    ),
  );

  final output = await getExternalStorageDirectory();
  final file = File("${output!.path}/historique_ventes.pdf");
  await file.writeAsBytes(await pdf.save());

  await Printing.sharePdf(bytes: await pdf.save(), filename: "historique_ventes.pdf");
}

double getTotalSalesAmount() {
  return filteredSales.fold(0.0, (sum, sale) => sum + sale.totalPrice);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique des Ventes'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _generatePDF,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher par nom ou ID reçu...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Padding(
  padding: const EdgeInsets.all(8.0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        "Total des ventes :",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      Text(
        "${getTotalSalesAmount().toStringAsFixed(2)} \$",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
      ),
    ],
  ),
),

          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredSales.isEmpty
                    ? Center(child: Text('Aucune vente trouvée'))
                    : ListView.builder(
                        itemCount: filteredSales.length,
                        itemBuilder: (context, index) {
                          final sale = filteredSales[index];
                          String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(sale.date);

                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: ListTile(
                              title: Text('Client: ${sale.clientName}', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Vente du $formattedDate'),
                                  Text('Reçu: ${sale.receiptId}', style: TextStyle(color: Colors.grey)),
                                  Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: sale.saleItems.map((item) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text('${item.product.name} x${item.quantity} - ${(item.product.price * item.quantity).toStringAsFixed(2)} \$', style: TextStyle(fontSize: 14)),
                              )).toList(),
                            ),
                                  Text('Total: ${sale.totalPrice.toStringAsFixed(2)} \$', style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              trailing: Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SaleDetailScreen(sale: sale),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
