import 'package:stockmanagement/Model/product_model.dart';

class SaleItem {
  final Product product;
  final int quantity; // Quantité vendue

  SaleItem({required this.product, required this.quantity});
}
