import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  Staff? _staff;
  Tenant? _tenant;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  Staff? get staff => _staff;
  Tenant? get tenant => _tenant;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _token != null && _user != null;

  bool hasPermission(String permission) {
    return _staff?.hasPermission(permission) ?? false;
  }

  bool get canManageStaff => _staff?.canManageStaff ?? false;
  bool get canManageWarehouse => _staff?.canManageWarehouse ?? false;
  bool get canManageProduct => _staff?.canManageProduct ?? false;
  bool get canInbound => _staff?.canInbound ?? false;
  bool get canOutbound => _staff?.canOutbound ?? false;
  bool get canViewReport => _staff?.canViewReport ?? true;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConfig.tokenKey);
    if (_token != null) {
      await ApiService().init();
      ApiService().setToken(_token!);
      await loadUserInfo();
    }
    notifyListeners();
  }

  Future<bool> loginByCode(String phone, String code) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.loginByCode(phone, code);
      if (response.isSuccess && response.data != null) {
        _user = response.data!.user;
        _staff = response.data!.staff;
        _tenant = response.data!.tenant;
        _token = response.data!.token;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConfig.tokenKey, _token!);

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> loginByPassword(String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.loginByPassword(phone, password);
      if (response.isSuccess && response.data != null) {
        _user = response.data!.user;
        _staff = response.data!.staff;
        _tenant = response.data!.tenant;
        _token = response.data!.token;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConfig.tokenKey, _token!);

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String phone, String? password, String name) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.register(phone, password, name);
      if (response.isSuccess && response.data != null) {
        _user = response.data!.user;
        _staff = response.data!.staff;
        _tenant = response.data!.tenant;
        _token = response.data!.token;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConfig.tokenKey, _token!);

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Register error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> wxLogin(String wxOpenid) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.wxLogin(wxOpenid);
      if (response.isSuccess && response.data != null) {
        _user = response.data!.user;
        _staff = response.data!.staff;
        _tenant = response.data!.tenant;
        _token = response.data!.token;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConfig.tokenKey, _token!);

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('WeChat login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> loadUserInfo() async {
    try {
      final response = await _authService.getUserInfo();
      if (response.isSuccess && response.data != null) {
        _user = response.data!.user;
        _staff = response.data!.staff;
        _tenant = response.data!.tenant;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Load user info error: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      debugPrint('Logout error: $e');
    }

    _user = null;
    _staff = null;
    _tenant = null;
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.tokenKey);

    notifyListeners();
  }
}
