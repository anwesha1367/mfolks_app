import 'package:dio/dio.dart';
import '../config/env.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  ApiClient._internal()
      : dio = Dio(
          BaseOptions(
            baseUrl: EnvConfig.apiBaseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 20),
            headers: const {
              'Content-Type': 'application/json',
            },
          ),
        );

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  final Dio dio;

  // Attach token on each request
  void _ensureAuthInterceptor() {
    if (dio.interceptors.any((i) => i is _AuthInterceptor)) return;
    dio.interceptors.add(_AuthInterceptor());
  }

  // Simple GET wrapper
  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) {
    _ensureAuthInterceptor();
    return dio.get<T>(path, queryParameters: query);
  }

  // Simple POST wrapper
  Future<Response<T>> post<T>(String path, {Object? data, Map<String, dynamic>? query}) {
    _ensureAuthInterceptor();
    return dio.post<T>(path, data: data, queryParameters: query);
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {}
    handler.next(options);
  }
}


