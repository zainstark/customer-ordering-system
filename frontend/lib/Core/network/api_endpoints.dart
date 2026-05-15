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

  static const String orders = '/orders';
  static const String accountOrders = '/accounts/{accountId}/orders';
}
