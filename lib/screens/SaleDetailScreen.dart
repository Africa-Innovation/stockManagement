import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stockmanagement/Model/vente_model.dart';

class SaleDetailScreen extends StatefulWidget {
  final Sale sale;

  SaleDetailScreen({required this.sale});

  @override
  _SaleDetailScreenState createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends State<SaleDetailScreen> {
  ScreenshotController screenshotController = ScreenshotController();

  Future<void> _saveSaleAsImage() async {
    try {
      if (await Permission.storage.request().isGranted) {
        final Uint8List? image = await screenshotController.capture();
        if (image == null) return;

        final directory = await getApplicationDocumentsDirectory();
        final imagePath =
            '${directory.path}/sale_${DateTime.now().millisecondsSinceEpoch}.png';
        final File imageFile = File(imagePath);
        await imageFile.writeAsBytes(image);

        await GallerySaver.saveImage(imageFile.path,
            albumName: "StockManagement");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vente enregistrée dans la galerie ! 📸')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Permission refusée, activez l’accès au stockage.')),
        );
      }
    } catch (e) {
      print("Erreur lors de l'enregistrement : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de lenregistrement.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('dd/MM/yyyy HH:mm').format(widget.sale.date);
    String formattedTotal =
        NumberFormat.simpleCurrency().format(widget.sale.totalPrice);

    return Scaffold(
      appBar: AppBar(
        title: Text("Détails de la Vente"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Screenshot(
                controller: screenshotController,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text("Reçu de Vente",
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                      ),
                      Text('ID du reçu: ${widget.sale.receiptId}'),
                      Divider(thickness: 1, color: Colors.black),
                      SizedBox(height: 10),
                      Text("Client: ${widget.sale.clientName}",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Divider(thickness: 1, color: Colors.black),
                      SizedBox(height: 10),
                      for (var item in widget.sale.saleItems)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Produit: ${item.product.name}",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                Text("${item.product.price.toStringAsFixed(2)} \$",
                                    style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Quantité: ${item.quantity}",
                                    style: TextStyle(fontSize: 14)),
                                Text(
                                    "Total: ${(item.product.price * item.quantity).toStringAsFixed(2)} \$",
                                    style: TextStyle(fontSize: 14)),
                              ],
                            ),
                            SizedBox(height: 8),
                          ],
                        ),
                      Divider(thickness: 1, color: Colors.black),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total général",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(formattedTotal,
                              style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text("Date : $formattedDate",
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saveSaleAsImage,
                icon: Icon(Icons.download),
                label:
                    Text("Télécharger la vente", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
