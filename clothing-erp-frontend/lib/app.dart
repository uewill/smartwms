import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clothing_erp/config/theme.dart';
import 'package:clothing_erp/providers/auth_provider.dart';
import 'package:clothing_erp/providers/shop_provider.dart';
import 'package:clothing_erp/providers/product_provider.dart';
import 'package:clothing_erp/providers/sale_provider.dart';
import 'package:clothing_erp/providers/customer_provider.dart';
import 'package:clothing_erp/providers/purchase_provider.dart';
import 'package:clothing_erp/providers/stock_provider.dart';
import 'package:clothing_erp/providers/subscription_provider.dart';
import 'package:clothing_erp/routes/app_routes.dart';
import 'package:clothing_erp/pages/splash/splash_page.dart';

class ClothingErpApp extends StatelessWidget {
  const ClothingErpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => SaleProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseProvider()),
        ChangeNotifierProvider(create: (_) => StockProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
      ],
      child: MaterialApp(
        title: '服装ERP',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: const SplashPage(),
      ),
    );
  }
}
