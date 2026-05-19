import 'package:flutter/foundation.dart';
import 'package:clothing_erp/models/stock.dart';
import 'package:clothing_erp/network/api_client.dart';
import 'package:clothing_erp/network/api_response.dart';
import 'package:clothing_erp/config/api_config.dart';

class StockProvider extends ChangeNotifier {
  List<StockSku> _stockList = [];
  bool _isLoading = false;
  String? _error;
  int _page = 1;
  int _totalPages = 1;

  List<StockSku> get stockList => _stockList;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _page < _totalPages;

  List<StockSku> get warningList =>
      _stockList.where((s) => s.isWarning == true).toList();

  Future<void> loadStockList({
    bool refresh = false,
    String? styleNo,
    String? colorName,
    String? sizeName,
  }) async {
    if (refresh) {
      _page = 1;
      _stockList = [];
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiConfig.stockList,
        queryParameters: {
          'page': _page,
          'pageSize': 20,
          if (styleNo != null && styleNo.isNotEmpty) 'styleNo': styleNo,
          if (colorName != null && colorName.isNotEmpty) 'colorName': colorName,
          if (sizeName != null && sizeName.isNotEmpty) 'sizeName': sizeName,
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      _isLoading = false;

      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        final List<dynamic> list = data['list'] ?? data['items'] ?? [];
        _stockList.addAll(
          list.map((e) => StockSku.fromJson(e as Map<String, dynamic>)).toList(),
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

  Future<StockSku?> queryStock(String skuId) async {
    try {
      final response = await ApiClient.instance.get<Map<String, dynamic>>(
        '${ApiConfig.stockQuery}/$skuId',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        return StockSku.fromJson(response.data!);
      } else {
        _error = response.message;
        return null;
      }
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  Future<bool> createInventoryCheck(Map<String, dynamic> checkData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post<Map<String, dynamic>>(
        ApiConfig.stockInventoryCheck,
        data: checkData,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      _isLoading = false;

      if (response.isSuccess) {
        await loadStockList(refresh: true);
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

  Future<bool> createTransfer(Map<String, dynamic> transferData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post<Map<String, dynamic>>(
        ApiConfig.stockTransfer,
        data: transferData,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      _isLoading = false;

      if (response.isSuccess) {
        await loadStockList(refresh: true);
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
