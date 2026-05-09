class AppConfig {
  static const String appName = 'SmartWMS';
  static const String appVersion = '1.0.0';
  
  // 修改为实际部署的 API 地址
  static const String baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8080/api');
  
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  static const String tokenKey = 'auth_token';
  static const String userInfoKey = 'user_info';
}
