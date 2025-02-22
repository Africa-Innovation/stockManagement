import 'package:stockmanagement/Model/product_model.dart';

class Receipt {
  final String id;  // ID du reçu, peut-être un UUID
  final String clientName;
  final List<ReceiptItem> items;
  double totalAmount;
  final String date;
  final int saleId; // Ajout du saleId pour lier le reçu à la vente
  final String receiptId;  // Utilise le même ID ici pour relier le reçu à la vente

  Receipt({
    required this.id,
    required this.clientName,
    required this.items,
    required this.totalAmount,
    required this.date,
    required this.saleId,  // Associer le saleId ici
    required this.receiptId,  // Recevoir le même receiptId pour le reçu
  });

  void calculateTotalAmount() {
    totalAmount = items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  }
}


class ReceiptItem {
  final Product product;
  final int quantity;

  ReceiptItem({
    required this.product,
    required this.quantity,
  });
}
