import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import 'models/auth_tokens.dart';

class AuthApi {
  final Dio _dio;
  final SecureStorage _storage;

  AuthApi({Dio? dio, SecureStorage? storage})
    : _dio = dio ?? ApiClient.build(),
      _storage = storage ?? SecureStorage();

  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    // Clear any existing tokens before login
    await _storage.clearTokens();

    final res = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    print('Login response data: ${res.data}');

    final tokens = AuthTokens.fromJson(
      res.data is Map<String, dynamic>
          ? res.data
          : Map<String, dynamic>.from(res.data),
    );

    print('Parsed userName: ${tokens.userName}');
    print('Parsed userEmail: ${tokens.userEmail}');
    print('Parsed identification_type: ${tokens.identificationType}');
    print('Parsed identification_number: ${tokens.identificationNumber}');

    // Only save non-null values
    await _storage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      userName: tokens.userName ?? '',
      userEmail: tokens.userEmail ?? '',
      identificationType: tokens.identificationType ?? '',
      identificationNumber: tokens.identificationNumber ?? '',
    );

    // Verify what was saved
    final savedUserName = await _storage.readUserName();
    final savedUserEmail = await _storage.readUserEmail();
    print('Saved userName: $savedUserName');
    print('Saved userEmail: $savedUserEmail');

    return tokens;
  }

  Future<void> register(Map<String, dynamic> payload) async {
    await _dio.post('/auth/signup', data: payload);
  }

  Future<AuthTokens> refresh() async {
    final refreshToken = await _storage.readRefreshToken();
    final res = await _dio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    final tokens = AuthTokens.fromJson(
      res.data is Map<String, dynamic>
          ? res.data
          : Map<String, dynamic>.from(res.data),
    );
    await _storage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    return tokens;
  }

  Future<void> logout() async {
    await _storage.clearTokens();
  }

  Future<Map<String, dynamic>> getMe() async {
    final res = await _dio.get('/auth/me');
    print('getMe response data: ${res.data}');
    final data = res.data is Map<String, dynamic>
        ? res.data
        : Map<String, dynamic>.from(res.data);
    print('getMe parsed data: $data');
    return data;
  }
}
