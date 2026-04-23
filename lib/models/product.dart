class Product {
  final String id;
  final String name;
  final int price;
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
  });

  factory Product.fromFirestore(doc) {
    return Product(
      id: doc.id,
      name: doc['name'],
      price: doc['price'],
      image: doc['image'] ?? "",
    );
  }
}
