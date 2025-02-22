import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:stockmanagement/Model/receipt_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stockmanagement/database/database_helper.dart';

class ReceiptPreviewScreen extends StatefulWidget {
  final Receipt receipt;

  ReceiptPreviewScreen({required this.receipt});

  @override
  _ReceiptPreviewScreenState createState() => _ReceiptPreviewScreenState();
}

class _ReceiptPreviewScreenState extends State<ReceiptPreviewScreen> {
  ScreenshotController screenshotController = ScreenshotController();

  Future<void> _saveReceiptAsImage() async {
    try {
      // Vérifier et demander l'autorisation de stockage
      if (await Permission.storage.request().isGranted) {
        final Uint8List? image = await screenshotController.capture();
        if (image == null) return;

        final directory = await getApplicationDocumentsDirectory();
        final imagePath =
            '${directory.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.png';
        final File imageFile = File(imagePath);
        await imageFile.writeAsBytes(image);

        await GallerySaver.saveImage(imageFile.path,
            albumName: "StockManagement");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reçu enregistré dans la galerie ! 📸')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Permission refusée, activez l’accès au stockage.')),
        );
      }
    } catch (e) {
      print("Erreur lors de l'enregistrement du reçu : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'enregistrement du reçu.')),
      );
    }
  }

  @override
Widget build(BuildContext context) {
  print("🧾 ID du reçu sur l'écran de prévisualisation : ${DatabaseHelper.instance.globalReceiptId}");
        
  return Scaffold(
    appBar: AppBar(
        title: Text("Aperçu du Reçu",
            style: TextStyle(fontWeight: FontWeight.bold))),
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
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ),
                    Text('ID du reçu: ${DatabaseHelper.instance.globalReceiptId}'),

                    Divider(thickness: 1, color: Colors.black),
                    SizedBox(height: 10),
                    Text("Client: ${widget.receipt.clientName}",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Divider(thickness: 1, color: Colors.black),
                    SizedBox(height: 10),
                    for (var item in widget.receipt.items)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Produit: ${item.product.name}",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text("${item.product.price.toStringAsFixed(2)} \$",
                                  style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Quantité: ${item.quantity}", style: TextStyle(fontSize: 14)),
                              Text("Total: ${(item.product.price * item.quantity).toStringAsFixed(2)} \$",
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
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("${widget.receipt.totalAmount.toStringAsFixed(2)} \$", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text("Date : ${widget.receipt.date}",
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveReceiptAsImage,
              icon: Icon(Icons.download),
              label: Text("Télécharger le reçu", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    ),
  );
}

}
