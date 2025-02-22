class Product {
  int? id;
  String name;
  int quantity;
  double price;
  int minStock;

  // Vous pouvez aussi ajouter un constructeur nommé si besoin
  Product({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.minStock,
  });

  // Ajoutez une méthode pour convertir de Map en objet Product (si elle n'est pas déjà présente)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      price: map['price'],
      minStock: map['minStock'],
    );
  }

  // Méthode pour convertir Product en Map (si elle n'est pas déjà présente)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'minStock': minStock,
    };
  }
}
