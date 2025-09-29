import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class SignupService {
  SignupService._();
  static final SignupService instance = SignupService._();

  /// Register a new user with the provided details
  Future<Map<String, dynamic>> register({
    required String fullname,
    required String email,
    required String phone,
    required int countryCode,
    required String password,
    required int industryId,
  }) async {
    final Dio dio = ApiClient().dio;
    
    final response = await dio.post('/auth/register', data: {
      'fullname': fullname,
      'email': email,
      'phone': phone,
      'country_code': countryCode,
      'password': password,
      'industry_id': industryId,
      'is_email_verified': false,
      'is_phone_verified': false,
    });

    final data = response.data;
    if (data is Map && data['error'] != null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: data['error'],
        type: DioExceptionType.badResponse,
      );
    }

    // Store token if provided
    if (data is Map && data['token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
    }

    // Store verification data for OTP verification
    if (data is Map && data['user'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('verificationData', 
        '{"email":"$email","phone":"$phone","country_code":"$countryCode"}');
    }

    return data is Map ? Map<String, dynamic>.from(data) : {'data': data};
  }

  /// Get list of industries
  Future<List<Map<String, dynamic>>> getIndustries() async {
    final Dio dio = ApiClient().dio;
    final response = await dio.get('/industries');
    
    final data = response.data;
    if (data is List) {
      return data.map((item) => Map<String, dynamic>.from(item)).toList();
    }
    return [];
  }

  /// Send email OTP for verification
  Future<void> sendEmailOtp(String email) async {
    final Dio dio = ApiClient().dio;
    await dio.post('/resend-otp/email', data: {'email': email});
  }

  /// Send phone OTP for verification
  Future<void> sendPhoneOtp({
    required String phone,
    required int countryCode,
    String? userId,
  }) async {
    final Dio dio = ApiClient().dio;
    final data = {
      'phone': phone,
      'country_code': countryCode,
    };
    
    if (userId != null) {
      data['user_id'] = userId;
    }
    
    await dio.post('/resend-otp/phone', data: data);
  }

  /// Verify email OTP
  Future<void> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    final Dio dio = ApiClient().dio;
    await dio.post('/otp/verify-email', data: {
      'email': email,
      'otp': otp,
    });
  }

  /// Verify phone OTP
  Future<void> verifyPhoneOtp({
    required String phone,
    required String otp,
    required int countryCode,
    String? userId,
  }) async {
    final Dio dio = ApiClient().dio;
    final data = {
      'phone': phone,
      'otp': otp,
      'country_code': countryCode,
    };
    
    if (userId != null) {
      data['user_id'] = userId;
    }
    
    await dio.post('/otp/verify-phone', data: data);
  }

  /// Complete social auth phone verification
  Future<Map<String, dynamic>> completeSocialAuthPhoneVerification({
    required String userId,
    required String phone,
    required int countryCode,
    required String provider,
    required String providerUserId,
  }) async {
    final Dio dio = ApiClient().dio;
    final response = await dio.post('/auth/social/complete-phone-verification', data: {
      'user_id': userId,
      'phone': phone,
      'country_code': countryCode,
      'provider': provider,
      'provider_user_id': providerUserId,
    });

    final data = response.data;
    if (data is Map && data['token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
    }

    return data is Map ? Map<String, dynamic>.from(data) : {'data': data};
  }
}
