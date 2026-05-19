import 'package:shared_preferences/shared_preferences.dart';

class StorageUtil {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    if (_prefs == null) {
      throw StateError('StorageUtil 未初始化，请先调用 StorageUtil.init()');
    }
    return _prefs!;
  }

  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyCurrentShopId = 'current_shop_id';
  static const String _keyUserInfo = 'user_info';
  static const String _keyThemeMode = 'theme_mode';

  static Future<bool> saveToken(String token) async {
    return _instance.setString(_keyToken, token);
  }

  static Future<String?> getToken() async {
    return _instance.getString(_keyToken);
  }

  static Future<bool> removeToken() async {
    return _instance.remove(_keyToken);
  }

  static Future<bool> saveUserId(String userId) async {
    return _instance.setString(_keyUserId, userId);
  }

  static Future<String?> getUserId() async {
    return _instance.getString(_keyUserId);
  }

  static Future<bool> removeUserId() async {
    return _instance.remove(_keyUserId);
  }

  static Future<bool> saveCurrentShopId(String shopId) async {
    return _instance.setString(_keyCurrentShopId, shopId);
  }

  static Future<String?> getCurrentShopId() async {
    return _instance.getString(_keyCurrentShopId);
  }

  static Future<bool> removeCurrentShopId() async {
    return _instance.remove(_keyCurrentShopId);
  }

  static Future<bool> saveUserInfo(String userInfoJson) async {
    return _instance.setString(_keyUserInfo, userInfoJson);
  }

  static String? getUserInfo() async {
    return _instance.getString(_keyUserInfo);
  }

  static Future<bool> saveThemeMode(String mode) async {
    return _instance.setString(_keyThemeMode, mode);
  }

  static String? getThemeMode() {
    return _instance.getString(_keyThemeMode);
  }

  static Future<bool> clearAll() async {
    return _instance.clear();
  }
}
