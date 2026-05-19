import 'package:flutter/foundation.dart';
import 'package:clothing_erp/models/sale_order.dart';
import 'package:clothing_erp/network/api_client.dart';
import 'package:clothing_erp/network/api_response.dart';
import 'package:clothing_erp/config/api_config.dart';

class TodaySummary {
  final double? totalSales;
  final double? totalProfit;
  final int? orderCount;

  TodaySummary({this.totalSales, this.totalProfit, this.orderCount});

  factory TodaySummary.fromJson(Map<String, dynamic> json) {
    return TodaySummary(
      totalSales: (json['totalSales'] as num?)?.toDouble(),
      totalProfit: (json['totalProfit'] as num?)?.toDouble(),
      orderCount: json['orderCount'] as int?,
    );
  }
}

class SaleProvider extends ChangeNotifier {
  List<SaleOrder> _saleOrders = [];
  TodaySummary? _todaySummary;
  bool _isLoading = false;
  String? _error;
  int _page = 1;
  int _totalPages = 1;

  List<SaleOrder> get saleOrders => _saleOrders;
  TodaySummary? get todaySummary => _todaySummary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _page < _totalPages;

  Future<void> loadSaleOrders({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _saleOrders = [];
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiConfig.saleOrderList,
        queryParameters: {
          'page': _page,
          'pageSize': 20,
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      _isLoading = false;

      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        final List<dynamic> list = data['list'] ?? data['items'] ?? [];
        _saleOrders.addAll(
          list.map((e) => SaleOrder.fromJson(e as Map<String, dynamic>)).toList(),
        );
        _totalPages = data['totalPages'] as int? ?? 1;
        _page++;
      } else {
        _error = response.message;
      }
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createSaleOrder(Map<String, dynamic> orderData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post<Map<String, dynamic>>(
        ApiConfig.saleOrderCreate,
        data: orderData,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      _isLoading = false;

      if (response.isSuccess && response.data != null) {
        final newOrder = SaleOrder.fromJson(response.data!);
        _saleOrders.insert(0, newOrder);
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadTodaySummary() async {
    try {
      final response = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiConfig.saleTodaySummary,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        _todaySummary = TodaySummary.fromJson(response.data!);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createReturnOrder(Map<String, dynamic> returnData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post<Map<String, dynamic>>(
        ApiConfig.saleOrderReturn,
        data: returnData,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      _isLoading = false;

      if (response.isSuccess) {
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
