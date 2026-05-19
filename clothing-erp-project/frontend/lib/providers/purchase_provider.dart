import 'package:flutter/foundation.dart';
import 'package:clothing_erp/models/purchase_order.dart';
import 'package:clothing_erp/network/api_client.dart';
import 'package:clothing_erp/network/api_response.dart';
import 'package:clothing_erp/config/api_config.dart';

class PurchaseProvider extends ChangeNotifier {
  List<PurchaseOrder> _purchaseOrders = [];
  bool _isLoading = false;
  String? _error;
  int _page = 1;
  int _totalPages = 1;

  List<PurchaseOrder> get purchaseOrders => _purchaseOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _page < _totalPages;

  Future<void> loadPurchaseOrders({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _purchaseOrders = [];
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiConfig.purchaseOrderList,
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
        _purchaseOrders.addAll(
          list.map((e) => PurchaseOrder.fromJson(e as Map<String, dynamic>)).toList(),
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

  Future<bool> createPurchaseOrder(Map<String, dynamic> orderData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post<Map<String, dynamic>>(
        ApiConfig.purchaseOrderCreate,
        data: orderData,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      _isLoading = false;

      if (response.isSuccess && response.data != null) {
        final newOrder = PurchaseOrder.fromJson(response.data!);
        _purchaseOrders.insert(0, newOrder);
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

  Future<bool> createReturnOrder(Map<String, dynamic> returnData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post<Map<String, dynamic>>(
        ApiConfig.purchaseOrderReturn,
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
