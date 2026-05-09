import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/response.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _token;

  Future<void> init() async {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        return handler.next(error);
      },
    ));

    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConfig.tokenKey);
  }

  void setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.tokenKey, token);
  }

  void clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.tokenKey);
  }

  bool get isLoggedIn => _token != null;

  Future<ApiResponse<T>> get<T>(String path, {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get(path, queryParameters: params);
      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse.error(500, e.toString());
    }
  }

  Future<ApiResponse<T>> post<T>(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse.error(500, e.toString());
    }
  }

  Future<ApiResponse<T>> put<T>(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse.error(500, e.toString());
    }
  }

  Future<ApiResponse<T>> delete<T>(String path) async {
    try {
      final response = await _dio.delete(path);
      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse.error(500, e.toString());
    }
  }

  ApiResponse<T> _handleResponse<T>(Response response) {
    final data = response.data;
    if (data is Map) {
      final code = data['code'] ?? 0;
      final message = data['message'] ?? '';
      final result = data['data'];
      return ApiResponse(code: code, message: message, data: result);
    }
    return ApiResponse.error(500, 'Unknown error');
  }
}

class AuthService {
  final ApiService _api = ApiService();

  Future<ApiResponse<Map<String, dynamic>>> sendCode(String phone, {String type = 'login'}) async {
    return await _api.post('/auth/send-code', data: {'phone': phone, 'type': type});
  }

  Future<ApiResponse<AuthResult>> loginByCode(String phone, String code) async {
    final response = await _api.post('/auth/login-by-code', data: {'phone': phone, 'code': code});
    if (response.isSuccess && response.data != null) {
      final authResult = AuthResult.fromJson(response.data!);
      _api.setToken(authResult.token);
      return ApiResponse(code: 0, message: 'success', data: authResult);
    }
    return ApiResponse.error(response.code, response.message);
  }

  Future<ApiResponse<AuthResult>> loginByPassword(String phone, String password) async {
    final response = await _api.post('/auth/login-by-pwd', data: {'phone': phone, 'password': password});
    if (response.isSuccess && response.data != null) {
      final authResult = AuthResult.fromJson(response.data!);
      _api.setToken(authResult.token);
      return ApiResponse(code: 0, message: 'success', data: authResult);
    }
    return ApiResponse.error(response.code, response.message);
  }

  Future<ApiResponse<AuthResult>> register(String phone, String? password, String name) async {
    final response = await _api.post('/auth/register', data: {
      'phone': phone,
      'password': password,
      'name': name,
    });
    if (response.isSuccess && response.data != null) {
      final authResult = AuthResult.fromJson(response.data!);
      _api.setToken(authResult.token);
      return ApiResponse(code: 0, message: 'success', data: authResult);
    }
    return ApiResponse.error(response.code, response.message);
  }

  Future<ApiResponse<AuthResult>> wxLogin(String wxOpenid) async {
    final response = await _api.post('/auth/wx-login', data: {'wx_openid': wxOpenid});
    if (response.isSuccess && response.data != null) {
      final authResult = AuthResult.fromJson(response.data!);
      _api.setToken(authResult.token);
      return ApiResponse(code: 0, message: 'success', data: authResult);
    }
    return ApiResponse.error(response.code, response.message);
  }

  Future<ApiResponse<AuthResult>> bindWechat(String wxOpenid) async {
    final response = await _api.post('/auth/bind-wechat', data: {'wx_openid': wxOpenid});
    if (response.isSuccess && response.data != null) {
      return ApiResponse(code: 0, message: 'success', data: response.data!);
    }
    return ApiResponse.error(response.code, response.message);
  }

  Future<ApiResponse<AuthResult>> getUserInfo() async {
    final response = await _api.get('/auth/user-info');
    if (response.isSuccess && response.data != null) {
      return ApiResponse(code: 0, message: 'success', data: AuthResult.fromJson(response.data!));
    }
    return ApiResponse.error(response.code, response.message);
  }

  Future<ApiResponse<void>> changePassword(String oldPwd, String newPwd) async {
    return await _api.post('/auth/change-password', data: {
      'oldPassword': oldPwd,
      'newPassword': newPwd,
    });
  }

  Future<List<OperationLog>> getOperationLogs() async {
    final response = await _api.get('/auth/operation-logs');
    if (response.isSuccess && response.data != null) {
      final logs = (response.data as List).map((e) => OperationLog.fromJson(e as Map<String, dynamic>)).toList();
      return logs;
    }
    return [];
  }

  Future<ApiResponse<void>> logout() async {
    final response = await _api.post('/auth/logout');
    _api.clearToken();
    return response;
  }
}

class ProductService {
  final ApiService _api = ApiService();

  Future<List<Product>> getProducts({String? keyword, String? category}) async {
    final response = await _api.get('/products', params: {
      if (keyword != null) 'keyword': keyword,
      if (category != null) 'category': category,
    });
    if (response.isSuccess && response.data != null) {
      return (response.data as List).map((e) => Product.fromJson(e)).toList();
    }
    return [];
  }

  Future<Product?> getProduct(String id) async {
    final response = await _api.get('/products/$id');
    if (response.isSuccess && response.data != null) {
      return Product.fromJson(response.data!);
    }
    return null;
  }

  Future<bool> createProduct(Map<String, dynamic> data) async {
    final response = await _api.post('/products', data: data);
    return response.isSuccess;
  }

  Future<bool> updateProduct(String id, Map<String, dynamic> data) async {
    final response = await _api.put('/products/$id', data: data);
    return response.isSuccess;
  }

  Future<bool> deleteProduct(String id) async {
    final response = await _api.delete('/products/$id');
    return response.isSuccess;
  }
}

class WarehouseService {
  final ApiService _api = ApiService();

  Future<List<Warehouse>> getWarehouses() async {
    final response = await _api.get('/warehouses');
    if (response.isSuccess && response.data != null) {
      return (response.data as List).map((e) => Warehouse.fromJson(e)).toList();
    }
    return [];
  }

  Future<Warehouse?> getWarehouse(String id) async {
    final response = await _api.get('/warehouses/$id');
    if (response.isSuccess && response.data != null) {
      return Warehouse.fromJson(response.data!);
    }
    return null;
  }

  Future<bool> createWarehouse({
    required String name,
    String? address,
    String? contact,
    String? phone,
    String? status,
  }) async {
    final response = await _api.post('/warehouses', data: {
      'name': name,
      if (address != null) 'address': address,
      if (contact != null) 'contact': contact,
      if (phone != null) 'phone': phone,
      if (status != null) 'status': status,
    });
    return response.isSuccess;
  }

  Future<bool> updateWarehouse({
    required String id,
    required String name,
    String? address,
    String? contact,
    String? phone,
    String? status,
  }) async {
    final response = await _api.put('/warehouses/$id', data: {
      'name': name,
      if (address != null) 'address': address,
      if (contact != null) 'contact': contact,
      if (phone != null) 'phone': phone,
      if (status != null) 'status': status,
    });
    return response.isSuccess;
  }

  Future<bool> deleteWarehouse(String id) async {
    final response = await _api.delete('/warehouses/$id');
    return response.isSuccess;
  }
}

class InboundService {
  final ApiService _api = ApiService();

  Future<List<InboundOrder>> getOrders() async {
    final response = await _api.get('/inbound');
    if (response.isSuccess && response.data != null) {
      return (response.data as List).map((e) => InboundOrder.fromJson(e)).toList();
    }
    return [];
  }

  Future<InboundOrder?> getOrder(String id) async {
    final response = await _api.get('/inbound/$id');
    if (response.isSuccess && response.data != null) {
      return InboundOrder.fromJson(response.data!);
    }
    return null;
  }

  Future<bool> createOrder({
    required String warehouseId,
    required String warehouseName,
    required List<Map<String, dynamic>> items,
    String? remark,
    String? operatorId,
    String? operatorName,
  }) async {
    final response = await _api.post('/inbound', data: {
      'warehouseId': warehouseId,
      'warehouseName': warehouseName,
      'items': items,
      if (remark != null) 'remark': remark,
      if (operatorId != null) 'operatorId': operatorId,
      if (operatorName != null) 'operatorName': operatorName,
    });
    return response.isSuccess;
  }

  Future<bool> updateStatus(String id, String status) async {
    final response = await _api.post('/inbound/$id/status', data: {'status': status});
    return response.isSuccess;
  }

  Future<bool> deleteOrder(String id) async {
    final response = await _api.delete('/inbound/$id');
    return response.isSuccess;
  }
}

class OutboundService {
  final ApiService _api = ApiService();

  Future<List<OutboundOrder>> getOrders() async {
    final response = await _api.get('/outbound');
    if (response.isSuccess && response.data != null) {
      return (response.data as List).map((e) => OutboundOrder.fromJson(e)).toList();
    }
    return [];
  }

  Future<OutboundOrder?> getOrder(String id) async {
    final response = await _api.get('/outbound/$id');
    if (response.isSuccess && response.data != null) {
      return OutboundOrder.fromJson(response.data!);
    }
    return null;
  }

  Future<bool> createOrder({
    required String warehouseId,
    required String warehouseName,
    required List<Map<String, dynamic>> items,
    String? remark,
    String? operatorId,
    String? operatorName,
  }) async {
    final response = await _api.post('/outbound', data: {
      'warehouseId': warehouseId,
      'warehouseName': warehouseName,
      'items': items,
      if (remark != null) 'remark': remark,
      if (operatorId != null) 'operatorId': operatorId,
      if (operatorName != null) 'operatorName': operatorName,
    });
    return response.isSuccess;
  }

  Future<bool> updateStatus(String id, String status) async {
    final response = await _api.post('/outbound/$id/status', data: {'status': status});
    return response.isSuccess;
  }

  Future<bool> deleteOrder(String id) async {
    final response = await _api.delete('/outbound/$id');
    return response.isSuccess;
  }
}

class ReportService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _api.get('/reports/dashboard');
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    return {};
  }

  Future<InventoryReport> getInventoryReport() async {
    final response = await _api.get('/reports/inventory');
    if (response.isSuccess && response.data != null) {
      return InventoryReport.fromJson(response.data!);
    }
    return InventoryReport(
      totalProductTypes: 0,
      totalQuantity: 0,
      warehouseStats: [],
      lowStockProducts: [],
      productInventory: [],
    );
  }

  Future<CostReport> getCostReport() async {
    final response = await _api.get('/reports/cost');
    if (response.isSuccess && response.data != null) {
      return CostReport.fromJson(response.data!);
    }
    return CostReport(
      monthInboundCost: 0,
      monthOutboundCost: 0,
      totalInventoryValue: 0,
      averageCost: 0,
      monthlyTrend: [],
    );
  }
}

class StaffService {
  final ApiService _api = ApiService();

  Future<List<Staff>> getStaffs() async {
    final response = await _api.get('/staffs');
    if (response.isSuccess && response.data != null) {
      return (response.data as List).map((e) => Staff.fromJson(e)).toList();
    }
    return [];
  }

  Future<Staff?> getStaff(String id) async {
    final response = await _api.get('/staffs/$id');
    if (response.isSuccess && response.data != null) {
      return Staff.fromJson(response.data!);
    }
    return null;
  }

  Future<bool> createStaff({
    required String name,
    required String phone,
    String? email,
    String? password,
    required int level,
    String? remark,
  }) async {
    final response = await _api.post('/staffs', data: {
      'name': name,
      'phone': phone,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
      'level': level,
      if (remark != null) 'remark': remark,
    });
    return response.isSuccess;
  }

  Future<bool> updateStaff({
    required String id,
    required String name,
    required String phone,
    String? email,
    required int level,
    String? status,
    String? remark,
  }) async {
    final response = await _api.put('/staffs/$id', data: {
      'name': name,
      'phone': phone,
      if (email != null) 'email': email,
      'level': level,
      if (status != null) 'status': status,
      if (remark != null) 'remark': remark,
    });
    return response.isSuccess;
  }

  Future<bool> deleteStaff(String id) async {
    final response = await _api.delete('/staffs/$id');
    return response.isSuccess;
  }
}
