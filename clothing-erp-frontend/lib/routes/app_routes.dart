import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clothing_erp/providers/auth_provider.dart';
import 'package:clothing_erp/pages/splash/splash_page.dart';
import 'package:clothing_erp/pages/auth/login_page.dart';
import 'package:clothing_erp/pages/auth/register_page.dart';
import 'package:clothing_erp/pages/home/home_page.dart';
import 'package:clothing_erp/pages/product/product_list_page.dart';
import 'package:clothing_erp/pages/product/product_form_page.dart';
import 'package:clothing_erp/pages/sale/sale_order_page.dart';
import 'package:clothing_erp/pages/sale/cart_page.dart';
import 'package:clothing_erp/pages/customer/customer_list_page.dart';
import 'package:clothing_erp/pages/customer/customer_detail_page.dart';
import 'package:clothing_erp/pages/purchase/purchase_order_page.dart';
import 'package:clothing_erp/pages/stock/stock_list_page.dart';
import 'package:clothing_erp/pages/stock/inventory_check_page.dart';
import 'package:clothing_erp/pages/report/report_page.dart';
import 'package:clothing_erp/pages/settings/settings_page.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String productList = '/product/list';
  static const String productForm = '/product/form';
  static const String saleOrder = '/sale/order';
  static const String cart = '/sale/cart';
  static const String customerList = '/customer/list';
  static const String customerDetail = '/customer/detail';
  static const String purchaseOrder = '/purchase/order';
  static const String stockList = '/stock/list';
  static const String inventoryCheck = '/stock/inventory-check';
  static const String report = '/report';
  static const String settings = '/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name;

    if (!_isPublicRoute(routeName)) {
      return MaterialPageRoute(
        builder: (context) {
          final authProvider = context.watch<AuthProvider>();
          if (!authProvider.isLoggedIn) {
            return const LoginPage();
          }
          return _getPageRoute(routeName, settings.arguments);
        },
      );
    }

    return MaterialPageRoute(
      builder: (context) => _getPageRoute(routeName, settings.arguments),
    );
  }

  static Widget _getPageRoute(String? routeName, Object? arguments) {
    switch (routeName) {
      case splash:
        return const SplashPage();
      case login:
        return const LoginPage();
      case register:
        return const RegisterPage();
      case home:
        return const HomePage();
      case productList:
        return const ProductListPage();
      case productForm:
        return ProductFormPage(product: arguments);
      case saleOrder:
        return const SaleOrderPage();
      case cart:
        return const CartPage();
      case customerList:
        return const CustomerListPage();
      case customerDetail:
        return CustomerDetailPage(customerId: arguments as String?);
      case purchaseOrder:
        return const PurchaseOrderPage();
      case stockList:
        return const StockListPage();
      case inventoryCheck:
        return const InventoryCheckPage();
      case report:
        return const ReportPage();
      case settings:
        return const SettingsPage();
      default:
        return const Scaffold(
          body: Center(child: Text('页面不存在')),
        );
    }
  }

  static bool _isPublicRoute(String? routeName) {
    return routeName == splash ||
        routeName == login ||
        routeName == register;
  }

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashPage(),
    login: (context) => const LoginPage(),
    register: (context) => const RegisterPage(),
    home: (context) => const HomePage(),
  };
}
