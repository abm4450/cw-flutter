import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/api_user.dart';

class AuthResponse {
  final bool success;
  final String token;
  final ApiUser user;

  const AuthResponse({
    required this.success,
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        success: json['success'] as bool? ?? false,
        token: json['token'] as String? ?? '',
        user: ApiUser.fromJson(json['user'] as Map<String, dynamic>),
      );
}

class OtpRequestResponse {
  final bool exists;
  final bool sent;
  final List<String> options;

  const OtpRequestResponse({
    required this.exists,
    required this.sent,
    required this.options,
  });

  factory OtpRequestResponse.fromJson(Map<String, dynamic> json) =>
      OtpRequestResponse(
        exists: json['exists'] as bool? ?? false,
        sent: json['sent'] as bool? ?? false,
        options: (json['options'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
}

class OtpVerifyResponse {
  final bool success;
  final String? token;
  final ApiUser? user;

  const OtpVerifyResponse({
    required this.success,
    this.token,
    this.user,
  });

  factory OtpVerifyResponse.fromJson(Map<String, dynamic> json) =>
      OtpVerifyResponse(
        success: json['success'] as bool? ?? false,
        token: json['token'] as String?,
        user: json['user'] != null
            ? ApiUser.fromJson(json['user'] as Map<String, dynamic>)
            : null,
      );
}

class AuthService {
  final ApiClient _client;

  AuthService(this._client);

  Future<AuthResponse> register({
    required String fullName,
    required String phone,
    String? plateNumber,
  }) async {
    final data = await _client.post(
      ApiConstants.register,
      data: {
        'fullName': fullName,
        'phone': phone,
        if (plateNumber != null) 'plateNumber': plateNumber,
      },
      skipAuth: true,
    );
    return AuthResponse.fromJson(data);
  }

  Future<OtpRequestResponse> requestOtp({
    required String phone,
    String purpose = 'login',
  }) async {
    final data = await _client.post(
      ApiConstants.otpRequest,
      data: {'phone': phone, 'purpose': purpose},
      skipAuth: true,
    );
    return OtpRequestResponse.fromJson(data);
  }

  Future<OtpVerifyResponse> verifyOtp({
    required String phone,
    required String code,
    String purpose = 'login',
  }) async {
    final data = await _client.post(
      ApiConstants.otpVerify,
      data: {'phone': phone, 'code': code, 'purpose': purpose},
      skipAuth: true,
    );
    return OtpVerifyResponse.fromJson(data);
  }

  Future<AuthResponse> login({
    required String phone,
    required String password,
  }) async {
    final data = await _client.post(
      ApiConstants.login,
      data: {'phone': phone, 'password': password},
      skipAuth: true,
    );
    return AuthResponse.fromJson(data);
  }

  Future<void> logout() async {
    await _client.post(ApiConstants.logout);
  }
}
