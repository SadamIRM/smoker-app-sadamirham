class CartItem {
  final String id;
  final String productId;
  final String productName;
  final double price;
  int quantity;
  final String? imageUrl;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  double get totalPrice => price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] != null ? json['id'].toString() : '',
      productId: json['product_id'] != null ? json['product_id'].toString() : '',
      productName: json['product_name'] as String? ?? '',
      price: (json['price'] as num? ?? 0.0).toDouble(),
      quantity: json['quantity'] as int? ?? 1,
      imageUrl: json['image_url'] as String? ?? json['ImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': int.tryParse(id),
      'product_id': int.tryParse(productId) ?? 0,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'image_url': imageUrl,
    };
  }

  CartItem copyWith({
    String? id,
    String? productId,
    String? productName,
    double? price,
    int? quantity,
    String? imageUrl,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
