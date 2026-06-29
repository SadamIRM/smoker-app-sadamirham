class AppConstants{
  static const String baseUrl = 'http://192.168.8.196:8080/v1';
 
  // Auth endpoints
  static const String verifyToken = '/auth/verify-token';
 
  // Product endpoints
  static const String products = '/products';
 
  // Cart endpoints
  static const String cart = '/cart';
  static const String cartQuantity = '/cart/quantity';

  // Transaction endpoints
  static const String checkout = '/transactions/checkout';
  static const String transactions = '/transactions';

  // Timeout
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
}