import 'admin_api.dart';

class AdminRepository {
  final AdminApi _api;
  AdminRepository({AdminApi? api}) : _api = api ?? AdminApi();

  Future<({int users, int suppliers, int carriers, int clients})>
  fetchCounts() async {
    final users = await _api.fetchUsersCount();
    final suppliers = await _api.fetchSuppliersCount();
    final carriers = await _api.fetchCarriersCount();
    final clients = await _api.fetchClientsCount();
    return (
      users: users,
      suppliers: suppliers,
      carriers: carriers,
      clients: clients,
    );
  }

  Future<List<Map<String, dynamic>>> fetchUsers() => _api.fetchUsers();
  Future<List<Map<String, dynamic>>> fetchClients() => _api.fetchClients();
  Future<List<Map<String, dynamic>>> fetchCarriers() => _api.fetchCarriers();
  Future<List<Map<String, dynamic>>> fetchSuppliers() => _api.fetchSuppliers();
  Future<List<Map<String, dynamic>>> fetchOrders() => _api.fetchOrders();
}
