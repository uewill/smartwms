import 'package:flutter/foundation.dart';
import 'package:clothing_erp/models/customer.dart';
import 'package:clothing_erp/network/api_client.dart';
import 'package:clothing_erp/network/api_response.dart';
import 'package:clothing_erp/config/api_config.dart';

class DebtDetail {
  final String? orderId;
  final String? orderNo;
  final double? amount;
  final String? createdAt;

  DebtDetail({this.orderId, this.orderNo, this.amount, this.createdAt});

  factory DebtDetail.fromJson(Map<String, dynamic> json) {
    return DebtDetail(
      orderId: json['orderId'] as String?,
      orderNo: json['orderNo'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      createdAt: json['createdAt'] as String?,
    );
  }
}

class CustomerProvider extends ChangeNotifier {
  List<Customer> _customers = [];
  Customer? _currentCustomer;
  List<DebtDetail> _debtDetails = [];
  bool _isLoading = false;
  String? _error;
  int _page = 1;
  int _totalPages = 1;

  List<Customer> get customers => _customers;
  Customer? get currentCustomer => _currentCustomer;
  List<DebtDetail> get debtDetails => _debtDetails;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _page < _totalPages;

  Future<void> loadCustomers({bool refresh = false, String? keyword}) async {
    if (refresh) {
      _page = 1;
      _customers = [];
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiConfig.customerList,
        queryParameters: {
          'page': _page,
          'pageSize': 20,
          if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      _isLoading = false;

      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        final List<dynamic> list = data['list'] ?? data['items'] ?? [];
        _customers.addAll(
          list.map((e) => Customer.fromJson(e as Map<String, dynamic>)).toList(),
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

  Future<bool> createCustomer(Map<String, dynamic> customerData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post<Map<String, dynamic>>(
        ApiConfig.customerCreate,
        data: customerData,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      _isLoading = false;

      if (response.isSuccess && response.data != null) {
        final newCustomer = Customer.fromJson(response.data!);
        _customers.insert(0, newCustomer);
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

  Future<bool> collectDebt(String customerId, double amount) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        ApiConfig.customerCollectDebt,
        data: {
          'customerId': customerId,
          'amount': amount,
        },
      );

      _isLoading = false;

      if (response.isSuccess) {
        await loadCustomerDetail(customerId);
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

  Future<void> loadCustomerDetail(String customerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.get<Map<String, dynamic>>(
        '${ApiConfig.customerDetail}/$customerId',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      _isLoading = false;

      if (response.isSuccess && response.data != null) {
        _currentCustomer = Customer.fromJson(response.data!);
        notifyListeners();
      }

      await loadDebtDetail(customerId);
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadDebtDetail(String customerId) async {
    try {
      final response = await ApiClient.instance.get<List<dynamic>>(
        '${ApiConfig.customerDebtDetail}/$customerId',
        fromJson: (json) =>
            (json as List).map((e) => DebtDetail.fromJson(e as Map<String, dynamic>)).toList(),
      );

      if (response.isSuccess && response.data != null) {
        _debtDetails = response.data!;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
