import '../../../core/storage/secure_storage.dart';
import 'auth_api.dart';
import 'models/auth_tokens.dart';

class AuthRepository {
  final AuthApi _api;
  final SecureStorage _storage;

  AuthRepository({AuthApi? api, SecureStorage? storage})
    : _api = api ?? AuthApi(),
      _storage = storage ?? SecureStorage();

  Future<AuthTokens> login(String email, String password) =>
      _api.login(email: email, password: password);

  Future<void> register(Map<String, dynamic> payload) => _api.register(payload);

  Future<AuthTokens> refresh() => _api.refresh();

  Future<void> logout() async {
    await _api.logout();
  }

  Future<bool> isAuthenticated() async {
    final token = await _storage.readAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, dynamic>> getMe() => _api.getMe();

  Future<void> updateUserDataInStorage({
    String? name,
    String? email,
    String? identificationType,
    String? identificationNumber,
  }) async {
    await _storage.updateUserData(
      userName: name,
      userEmail: email,
      identificationType: identificationType,
      identificationNumber: identificationNumber,
    );
  }
}
