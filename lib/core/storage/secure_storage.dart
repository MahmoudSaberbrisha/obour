import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kUserName = 'user_name';
  static const _kUserEmail = 'user_email';
  static const _kIdentificationType = 'identification_type';
  static const _kIdentificationNumber = 'identification_number';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    String? userName,
    String? userEmail,
    String? identificationType,
    String? identificationNumber,
  }) async {
    await _storage.write(key: _kAccessToken, value: accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(key: _kRefreshToken, value: refreshToken);
    }
    if (userName != null && userName.isNotEmpty) {
      await _storage.write(key: _kUserName, value: userName);
    }
    if (userEmail != null && userEmail.isNotEmpty) {
      await _storage.write(key: _kUserEmail, value: userEmail);
    }
    if (identificationType != null && identificationType.isNotEmpty) {
      await _storage.write(
        key: _kIdentificationType,
        value: identificationType,
      );
    }
    if (identificationNumber != null && identificationNumber.isNotEmpty) {
      await _storage.write(
        key: _kIdentificationNumber,
        value: identificationNumber,
      );
    }
  }

  Future<String?> readAccessToken() => _storage.read(key: _kAccessToken);
  Future<String?> readRefreshToken() => _storage.read(key: _kRefreshToken);
  Future<String?> readUserName() => _storage.read(key: _kUserName);
  Future<String?> readUserEmail() => _storage.read(key: _kUserEmail);
  Future<String?> readIdentificationType() =>
      _storage.read(key: _kIdentificationType);
  Future<String?> readIdentificationNumber() =>
      _storage.read(key: _kIdentificationNumber);

  Future<void> updateUserData({
    String? userName,
    String? userEmail,
    String? identificationType,
    String? identificationNumber,
  }) async {
    if (userName != null && userName.isNotEmpty) {
      await _storage.write(key: _kUserName, value: userName);
    }
    if (userEmail != null && userEmail.isNotEmpty) {
      await _storage.write(key: _kUserEmail, value: userEmail);
    }
    if (identificationType != null && identificationType.isNotEmpty) {
      await _storage.write(key: _kIdentificationType, value: identificationType);
    }
    if (identificationNumber != null && identificationNumber.isNotEmpty) {
      await _storage.write(key: _kIdentificationNumber, value: identificationNumber);
    }
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kRefreshToken);
    await _storage.delete(key: _kUserName);
    await _storage.delete(key: _kUserEmail);
    await _storage.delete(key: _kIdentificationType);
    await _storage.delete(key: _kIdentificationNumber);
  }
}
