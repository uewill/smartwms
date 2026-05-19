class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8080';

  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String logout = '/api/auth/logout';
  static const String userProfile = '/api/auth/profile';

  static const String shopList = '/api/shops';
  static const String shopCreate = '/api/shops';
  static const String shopJoin = '/api/shops/join';
  static const String shopSwitch = '/api/shops/switch';

  static const String productList = '/api/products';
  static const String productCreate = '/api/products';
  static const String productDetail = '/api/products';
  static const String productSearchByBarcode = '/api/products/search/barcode';

  static const String saleOrderList = '/api/sale-orders';
  static const String saleOrderCreate = '/api/sale-orders';
  static const String saleOrderReturn = '/api/sale-orders/return';
  static const String saleTodaySummary = '/api/sale-orders/today-summary';

  static const String customerList = '/api/customers';
  static const String customerCreate = '/api/customers';
  static const String customerDetail = '/api/customers';
  static const String customerCollectDebt = '/api/customers/collect-debt';
  static const String customerDebtDetail = '/api/customers/debt-detail';

  static const String purchaseOrderList = '/api/purchase-orders';
  static const String purchaseOrderCreate = '/api/purchase-orders';
  static const String purchaseOrderReturn = '/api/purchase-orders/return';

  static const String stockList = '/api/stocks';
  static const String stockQuery = '/api/stocks/query';
  static const String stockInventoryCheck = '/api/stocks/inventory-check';
  static const String stockTransfer = '/api/stocks/transfer';

  static const String subscriptionDetail = '/api/subscriptions';
  static const String subscriptionPlanCompare = '/api/subscriptions/plan-compare';
  static const String subscriptionCheckFeature = '/api/subscriptions/check-feature';
}
