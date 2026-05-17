class ApiEndpoints {
  ApiEndpoints._();

  static const String menu = '/menu';
  static const String menuCategories = '/menu/categories';
  static const String menuItems = '/menu/items';

  static const String cart = '/api/cart/';
  static const String cartItems = '/api/cart/items/';
  static const String cartItemById = '/api/cart/items/{cartItemId}/';
  static const String validateCart = '/api/cart/validate/';
  static const String clearCart = '/api/cart/clear/';


  static const String orders = '/api/order/';
  static const String placeOrder = '/api/order/place/';

  static const String accountOrders = '/accounts/{accountId}/orders';

  static const String createOrder = '/api/orders/';
  static const String createPaymentSession = '/api/payments/create-session/';
  static const String paymentStatusById = '/api/payments/{paymentId}/status/';
  static const String retryPaymentById = '/api/payments/{paymentId}/retry/';

  static const String register     = '/auth/register/';
  static const String login        = '/auth/login/';
  static const String logout       = '/auth/logout/';
  static const String tokenRefresh = '/auth/token/refresh/';
}
