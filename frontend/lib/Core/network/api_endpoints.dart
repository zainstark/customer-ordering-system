class ApiEndpoints {
  ApiEndpoints._();

  static const String menu = '/menu';
  static const String menuCategories = '/menu/categories';
  static const String menuItems = '/menu/items';

  static const String carts = '/carts';
  static const String cartById = '/carts/{cartId}';
  static const String cartItemById = '/carts/{cartId}/items/{cartItemId}';

  static const String orders = '/orders';
  static const String accountOrders = '/accounts/{accountId}/orders';
}
