import 'package:flutter/foundation.dart';
import 'package:clothing_erp/models/shop.dart';
import 'package:clothing_erp/network/api_client.dart';
import 'package:clothing_erp/network/api_response.dart';
import 'package:clothing_erp/config/api_config.dart';
import 'package:clothing_erp/utils/storage.dart';

class ShopProvider extends ChangeNotifier {
  Shop? _currentShop;
  List<Shop> _shops = [];
  bool _isLoading = false;
  String? _error;

  Shop? get currentShop => _currentShop;
  List<Shop> get shops => _shops;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadShops() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.get<List<dynamic>>(
        ApiConfig.shopList,
        fromJson: (json) => (json as List).map((e) => Shop.fromJson(e as Map<String, dynamic>)).toList(),
      );

      _isLoading = false;

      if (response.isSuccess && response.data != null) {
        _shops = response.data!;
        final savedShopId = await StorageUtil.getCurrentShopId();
        if (savedShopId != null) {
          _currentShop = _shops.where((s) => s.id == savedShopId).firstOrNull;
        }
        _currentShop ??= _shops.isNotEmpty ? _shops.first : null;
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

  Future<bool> switchShop(String shopId) async {
    try {
      final response = await ApiClient.instance.post(
        ApiConfig.shopSwitch,
        data: {'shopId': shopId},
      );

      if (response.isSuccess) {
        _currentShop = _shops.where((s) => s.id == shopId).firstOrNull;
        if (_currentShop?.id != null) {
          await StorageUtil.saveCurrentShopId(_currentShop!.id!);
        }
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> createShop(String name, {String? address}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post<Map<String, dynamic>>(
        ApiConfig.shopCreate,
        data: {
          'name': name,
          if (address != null) 'address': address,
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      _isLoading = false;

      if (response.isSuccess && response.data != null) {
        final newShop = Shop.fromJson(response.data!);
        _shops.add(newShop);
        _currentShop = newShop;
        if (newShop.id != null) {
          await StorageUtil.saveCurrentShopId(newShop.id!);
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

  Future<bool> joinShop(String inviteCode) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post<Map<String, dynamic>>(
        ApiConfig.shopJoin,
        data: {'inviteCode': inviteCode},
        fromJson: (json) => json as Map<String, dynamic>,
      );

      _isLoading = false;

      if (response.isSuccess && response.data != null) {
        final joinedShop = Shop.fromJson(response.data!);
        _shops.add(joinedShop);
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
}
