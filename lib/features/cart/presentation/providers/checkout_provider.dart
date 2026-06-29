import 'package:flutter/foundation.dart';
import 'package:matrial_1123150086_uts/core/constants/app_constants.dart';
import 'package:matrial_1123150086_uts/core/services/dio_client.dart';

class CheckoutProvider extends ChangeNotifier {
  bool _isProcessing = false;
  String? _orderId;

  bool get isProcessing => _isProcessing;
  String? get orderId => _orderId;

  /// Proses checkout/pembayaran menggunakan backend API
  Future<bool> processCheckout(String paymentMethod) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final response = await DioClient.instance.post(
        AppConstants.checkout,
        data: {'payment_method': paymentMethod},
      );
      
      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        _orderId = data['transaction_number'] as String?;
        _isProcessing = false;
        notifyListeners();
        return true;
      }
      
      _isProcessing = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  void resetCheckout() {
    _isProcessing = false;
    _orderId = null;
    notifyListeners();
  }
}
