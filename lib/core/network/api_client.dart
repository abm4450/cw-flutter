import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../errors/api_error.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  late final Dio _dio;
  final SecureStorageService _storage;

  ApiClient(this._storage) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      contentType: 'application/json',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));

    _dio.interceptors.add(_AuthInterceptor(_storage));
    _dio.interceptors.add(_ErrorInterceptor());
  }

  Future<Map<String, dynamic>> get(
    String path, {
    bool skipAuth = false,
  }) async {
    final response = await _dio.get(
      path,
      options: Options(extra: {'skipAuth': skipAuth}),
    );
    return response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : {};
  }

  Future<List<dynamic>> getList(
    String path, {
    bool skipAuth = false,
  }) async {
    final response = await _dio.get(
      path,
      options: Options(extra: {'skipAuth': skipAuth}),
    );
    return response.data is List ? response.data as List<dynamic> : [];
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
    bool skipAuth = false,
  }) async {
    final response = await _dio.post(
      path,
      data: data,
      options: Options(extra: {'skipAuth': skipAuth}),
    );
    return response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : {};
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? data,
    bool skipAuth = false,
  }) async {
    final response = await _dio.put(
      path,
      data: data,
      options: Options(extra: {'skipAuth': skipAuth}),
    );
    return response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : {};
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    bool skipAuth = false,
  }) async {
    final response = await _dio.delete(
      path,
      options: Options(extra: {'skipAuth': skipAuth}),
    );
    return response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : {};
  }
}

class _AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;

  _AuthInterceptor(this._storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final skipAuth = options.extra['skipAuth'] == true;
    if (!skipAuth) {
      final token = await _storage.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final data = err.response?.data;
    final statusCode = err.response?.statusCode ?? 500;

    if (data is Map<String, dynamic>) {
      throw ApiError(
        statusCode: statusCode,
        message: data['error'] as String? ?? 'Server error',
        code: data['code'] as String?,
      );
    }

    throw ApiError(
      statusCode: statusCode,
      message: err.message ?? 'حدث خطأ في الاتصال.',
    );
  }
}
