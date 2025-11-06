import 'buyer_api.dart';

class BuyerRepository {
  final BuyerApi _api;
  BuyerRepository({BuyerApi? api}) : _api = api ?? BuyerApi();

  Future<List<Map<String, dynamic>>> fetchOrders({int limit = 20}) =>
      _api.fetchOrders(limit: limit);

  Future<Map<String, dynamic>?> createOrder(Map<String, dynamic> payload) =>
      _api.createOrder(payload);

  Future<void> cancelOrder(String id) =>
      _api.updateOrderStatus(id, 'cancelled');

  Future<List<Map<String, dynamic>>> fetchSuppliers() => _api.fetchSuppliers();
  Future<List<Map<String, dynamic>>> fetchCarriers() => _api.fetchCarriers();
  Future<List<Map<String, dynamic>>> fetchProducts() => _api.fetchProducts();
  Future<List<Map<String, dynamic>>> fetchClients() => _api.fetchClients();
}
