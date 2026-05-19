import 'package:dio/dio.dart';
import 'package:clothing_erp/utils/storage.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await StorageUtil.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await StorageUtil.clearAll();
    }
    handler.next(err);
  }
}

class ShopInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final shopId = await StorageUtil.getCurrentShopId();
    if (shopId != null && shopId.isNotEmpty) {
      if (options.method == 'GET') {
        options.queryParameters['shopId'] = shopId;
      } else {
        if (options.data is Map) {
          (options.data as Map)['shopId'] = shopId;
        }
      }
    }
    handler.next(options);
  }
}

class LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('REQUEST[${options.method}] => ${options.uri}');
    print('Headers: ${options.headers}');
    if (options.data != null) {
      print('Data: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}');
    print('Data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('ERROR[${err.response?.statusCode}] => ${err.requestOptions.uri}');
    print('Message: ${err.message}');
    handler.next(err);
  }
}
