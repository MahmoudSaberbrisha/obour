import 'role_api.dart';

class RoleRepository {
  final RoleApi _api;
  RoleRepository({RoleApi? api}) : _api = api ?? RoleApi();

  Future<void> saveBuyer(Map<String, dynamic> payload) =>
      _api.saveBuyer(payload);
  Future<void> saveSupplier(Map<String, dynamic> payload) =>
      _api.saveSupplier(payload);
  Future<void> saveCarrier(Map<String, dynamic> payload) =>
      _api.saveCarrier(payload);
  Future<void> saveClient(Map<String, dynamic> payload) =>
      _api.saveClient(payload);
  Future<List<Region>> getRegions() => _api.getRegions();
}
