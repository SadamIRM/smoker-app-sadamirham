import 'package:flutter/material.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => _items;

  void addToCart(Product product) {
    _items.add(product);
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _items.remove(product);
    notifyListeners();
  }

  int get totalPrice {
    return _items.fold(0, (sum, item) => sum + item.price);
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
