class TransactionModel {
  final int id;
  final String transactionNumber;
  final double totalAmount;
  final String paymentMethod;
  final String status;
  final String date;
  final List<TransactionItemModel> items;

  TransactionModel({
    required this.id,
    required this.transactionNumber,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    required this.date,
    required this.items,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List<dynamic>? ?? [];
    List<TransactionItemModel> items = itemsList
        .map((i) => TransactionItemModel.fromJson(i as Map<String, dynamic>))
        .toList();

    return TransactionModel(
      id: json['id'] as int? ?? 0,
      transactionNumber: json['transaction_number'] as String? ?? '',
      totalAmount: (json['total_amount'] as num? ?? 0.0).toDouble(),
      paymentMethod: json['payment_method'] as String? ?? 'Dompet Kampus',
      status: json['status'] as String? ?? 'Selesai',
      date: json['created_at'] as String? ?? '',
      items: items,
    );
  }
}

class TransactionItemModel {
  final int id;
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final String imageUrl;

  TransactionItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      id: json['id'] as int? ?? 0,
      productId: json['product_id'] as int? ?? 0,
      productName: json['product_name'] as String? ?? '',
      price: (json['price'] as num? ?? 0.0).toDouble(),
      quantity: json['quantity'] as int? ?? 1,
      imageUrl: json['image_url'] as String? ?? '',
    );
  }
}
