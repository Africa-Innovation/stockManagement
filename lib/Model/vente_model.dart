import 'package:stockmanagement/Model/product_model.dart';
import 'package:stockmanagement/Model/sale_item.dart';

class Sale {
  final int? id;
  final String clientName;
  final List<SaleItem> saleItems;
  late final double totalPrice;
  final DateTime date;
  final String receiptId;  // Ce devrait être un UUID unique pour chaque vente

  Sale({
    this.id,
    required this.clientName,
    required this.saleItems,
    required this.totalPrice,
    required this.date,
    required this.receiptId,  // Associer l'ID du reçu lors de la création de la vente
  });

  // Calculer le totalPrice à partir des produits et de leurs quantités
  void calculateTotalPrice() {
    totalPrice = saleItems.fold(0, (sum, saleItem) => sum + (saleItem.product.price * saleItem.quantity));
  }

  Map<String, dynamic> toMap() {
    return {
      'clientName': clientName,
      'totalPrice': totalPrice,
      'date': date.toIso8601String(),
      'saleItems': saleItems.map((item) => {
        'productId': item.product.id,
        'productName': item.product.name,
        'quantity': item.quantity,
        'price': item.product.price,
        'receiptId': receiptId,  // Associer l'ID du reçu
      }).toList(),
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    List<SaleItem> saleItemsList = [];
    if (map['saleItems'] != null) {
      for (var item in map['saleItems']) {
        saleItemsList.add(SaleItem(
          product: Product(
            id: item['productId'],
            name: item['productName'],
            quantity: 0,
            price: item['price'],
            minStock: 0,
          ),
          quantity: item['quantity'],
        ));
      }
    }

    return Sale(
      id: map['id'],
      clientName: map['clientName'],
      saleItems: saleItemsList,
      totalPrice: map['totalPrice'] as double,
      date: DateTime.parse(map['date']),
      receiptId: map['receiptId'] as String,  // Le même receiptId ici
    );
  }
}
