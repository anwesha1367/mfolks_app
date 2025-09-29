import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final Dio dio = ApiClient().dio;
    final Response response = await dio.post('/auth/login', data: {
      'identifier': identifier,
      'password': password,
    });

    final data = response.data;
    if (data is Map && data['data'] != null) {
      final dynamic payload = data['data'];
      final String token = (payload is Map && payload['token'] is String)
          ? payload['token'] as String
          : '';

      if (token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
      }

      // Return normalized user map
      if (payload is Map && payload['data'] is Map) {
        return Map<String, dynamic>.from(payload['data'] as Map);
      }
      if (payload is Map<String, dynamic>) {
        return payload;
      }
      return {'data': payload};
    }

    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      error: 'Invalid response format',
      type: DioExceptionType.badResponse,
    );
  }

  Future<bool> sendForgotPasswordOTP({
    required String identifier,
    required String method,
  }) async {
    final Dio dio = ApiClient().dio;
    final Response response = await dio.post('/auth/forgot-password/send-otp', data: {
      'identifier': identifier,
      'method': method,
    });

    final data = response.data;
    return data is Map && data['success'] == true;
  }

  Future<bool> verifyForgotPasswordOTP({
    required String identifier,
    required String otp,
    required String method,
  }) async {
    final Dio dio = ApiClient().dio;
    final Response response = await dio.post('/auth/forgot-password/verify-otp', data: {
      'identifier': identifier,
      'otp': otp,
      'method': method,
    });

    final data = response.data;
    return data is Map && data['success'] == true;
  }

  Future<bool> resetPassword({
    required String identifier,
    required String otp,
    required String newPassword,
    required String method,
  }) async {
    final Dio dio = ApiClient().dio;
    final Response response = await dio.post('/auth/forgot-password/reset', data: {
      'identifier': identifier,
      'otp': otp,
      'newPassword': newPassword,
      'method': method,
    });

    final data = response.data;
    return data is Map && data['success'] == true;
  }
}


