import 'package:flutter/foundation.dart';
import 'package:matrial_1123150086_uts/core/constants/app_constants.dart';
import 'package:matrial_1123150086_uts/core/services/dio_client.dart';
import 'package:matrial_1123150086_uts/features/cart/data/models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<CartItem> get items => _items;
  int get itemCount => _items.length;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalPrice {
    return _items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  /// Ambil data keranjang dari backend database
  Future<void> fetchCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await DioClient.instance.get(AppConstants.cart);
      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        _items.clear();
        _items.addAll(data.map((json) => CartItem.fromJson(json as Map<String, dynamic>)));
      } else {
        _error = 'Gagal memuat keranjang';
      }
    } catch (e) {
      _error = 'Koneksi error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tambah barang ke cart di database backend
  Future<void> addItem(String productId, String productName, double price, {String? imageUrl}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await DioClient.instance.post(
        AppConstants.cart,
        data: {
          'product_id': int.tryParse(productId) ?? 0,
          'product_name': productName,
          'price': price,
          'quantity': 1,
          'image_url': imageUrl ?? '',
        },
      );
      if (response.statusCode == 200) {
        await fetchCart(); // Refresh data terbaru dari database
      } else {
        _error = 'Gagal menambah item';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Gagal menambah item: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Hapus barang dari cart di database backend
  Future<void> removeItem(String productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await DioClient.instance.delete(
        '${AppConstants.cart}/$productId',
      );
      if (response.statusCode == 200) {
        await fetchCart();
      } else {
        _error = 'Gagal menghapus item';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Gagal menghapus item: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update quantity barang di database backend
  Future<void> updateItemQuantity(String productId, int quantity) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await DioClient.instance.put(
        AppConstants.cartQuantity,
        data: {
          'product_id': int.tryParse(productId) ?? 0,
          'quantity': quantity,
        },
      );
      if (response.statusCode == 200) {
        await fetchCart();
      } else {
        _error = 'Gagal memperbarui kuantitas';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Gagal memperbarui kuantitas: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear semua item di database backend
  Future<void> clearCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await DioClient.instance.delete(AppConstants.cart);
      if (response.statusCode == 200) {
        _items.clear();
      } else {
        _error = 'Gagal mengosongkan keranjang';
      }
    } catch (e) {
      _error = 'Gagal mengosongkan keranjang: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Bersihkan data keranjang lokal setelah checkout sukses
  void clearLocalCart() {
    _items.clear();
    notifyListeners();
  }
}
