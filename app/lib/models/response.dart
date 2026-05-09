class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;

  ApiResponse({required this.code, required this.message, this.data});

  factory ApiResponse.success(T data) {
    return ApiResponse(code: 0, message: 'success', data: data);
  }

  factory ApiResponse.error(int code, String message) {
    return ApiResponse(code: code, message: message);
  }

  bool get isSuccess => code == 0;
}

class PageResult<T> {
  final List<T> list;
  final int total;
  final int page;
  final int pageSize;

  PageResult({
    required this.list,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  bool get hasMore => page * pageSize < total;
}
