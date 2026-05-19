import 'package:flutter/foundation.dart';
import 'package:clothing_erp/models/user.dart';
import 'package:clothing_erp/network/api_client.dart';
import 'package:clothing_erp/network/api_response.dart';
import 'package:clothing_erp/config/api_config.dart';
import 'package:clothing_erp/utils/storage.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post<Map<String, dynamic>>(
        ApiConfig.login,
        data: {
          'phone': phone,
          'password': password,
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      _isLoading = false;

      if (response.isSuccess && response.data != null) {
        _user = User.fromJson(response.data!);
        _isLoggedIn = true;

        if (_user?.token != null) {
          await StorageUtil.saveToken(_user!.token!);
        }
        if (_user?.id != null) {
          await StorageUtil.saveUserId(_user!.id!);
        }

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

  Future<bool> register(String phone, String password, String nickname) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post<Map<String, dynamic>>(
        ApiConfig.register,
        data: {
          'phone': phone,
          'password': password,
          'nickname': nickname,
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      _isLoading = false;

      if (response.isSuccess && response.data != null) {
        _user = User.fromJson(response.data!);
        _isLoggedIn = true;

        if (_user?.token != null) {
          await StorageUtil.saveToken(_user!.token!);
        }
        if (_user?.id != null) {
          await StorageUtil.saveUserId(_user!.id!);
        }

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

  Future<void> logout() async {
    try {
      await ApiClient.instance.post(ApiConfig.logout);
    } catch (_) {}

    _user = null;
    _isLoggedIn = false;
    await StorageUtil.clearAll();
    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    final token = await StorageUtil.getToken();
    if (token != null && token.isNotEmpty) {
      _isLoggedIn = true;
      final userId = await StorageUtil.getUserId();
      _user = User(id: userId, token: token);
      notifyListeners();

      try {
        final response = await ApiClient.instance.get<Map<String, dynamic>>(
          ApiConfig.userProfile,
          fromJson: (json) => json as Map<String, dynamic>,
        );
        if (response.isSuccess && response.data != null) {
          _user = User.fromJson(response.data!);
          notifyListeners();
        }
      } catch (_) {}
    } else {
      _isLoggedIn = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
