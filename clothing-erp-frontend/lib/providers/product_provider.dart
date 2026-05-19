import 'package:flutter/foundation.dart';
import 'package:clothing_erp/models/product.dart';
import 'package:clothing_erp/network/api_client.dart';
import 'package:clothing_erp/network/api_response.dart';
import 'package:clothing_erp/config/api_config.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  Product? _currentProduct;
  bool _isLoading = false;
  String? _error;
  int _page = 1;
  int _totalPages = 1;
  String _keyword = '';

  List<Product> get products => _products;
  Product? get currentProduct => _currentProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _page < _totalPages;

  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _products = [];
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiConfig.productList,
        queryParameters: {
          'page': _page,
          'pageSize': 20,
          if (_keyword.isNotEmpty) 'keyword': _keyword,
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      _isLoading = false;

      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        final List<dynamic> list = data['list'] ?? data['items'] ?? [];
        _products.addAll(
          list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList(),
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

  Future<bool> createProduct(Map<String, dynamic> productData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post<Map<String, dynamic>>(
        ApiConfig.productCreate,
        data: productData,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      _isLoading = false;

      if (response.isSuccess && response.data != null) {
        final newProduct = Product.fromJson(response.data!);
        _products.insert(0, newProduct);
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

  Future<Product?> getProduct(String productId) async {
    try {
      final response = await ApiClient.instance.get<Map<String, dynamic>>(
        '${ApiConfig.productDetail}/$productId',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        _currentProduct = Product.fromJson(response.data!);
        notifyListeners();
        return _currentProduct;
      } else {
        _error = response.message;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<Product?> searchByBarcode(String barcode) async {
    try {
      final response = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiConfig.productSearchByBarcode,
        queryParameters: {'barcode': barcode},
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        return Product.fromJson(response.data!);
      } else {
        _error = response.message;
        return null;
      }
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  void setKeyword(String keyword) {
    _keyword = keyword;
    loadProducts(refresh: true);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
