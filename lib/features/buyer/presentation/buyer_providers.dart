import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/buyer_repository.dart';

final buyerRepositoryProvider = Provider<BuyerRepository>((ref) {
  return BuyerRepository();
});

final buyerOrdersProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, int>((ref, limit) async {
      final repo = ref.watch(buyerRepositoryProvider);
      return await repo.fetchOrders(limit: limit);
    });

final createOrderProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, Map<String, dynamic>>((ref, payload) async {
      final repo = ref.watch(buyerRepositoryProvider);
      return await repo.createOrder(payload);
    });

final cancelOrderProvider = FutureProvider.autoDispose.family<void, String>((
  ref,
  orderId,
) async {
  final repo = ref.watch(buyerRepositoryProvider);
  await repo.cancelOrder(orderId);
});

final buyerSuppliersProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final repo = ref.watch(buyerRepositoryProvider);
  return await repo.fetchSuppliers();
});

final buyerCarriersProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final repo = ref.watch(buyerRepositoryProvider);
  return await repo.fetchCarriers();
});

final buyerProductsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(buyerRepositoryProvider);
  return await repo.fetchProducts();
});

final buyerClientsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(buyerRepositoryProvider);
  return await repo.fetchClients();
});
