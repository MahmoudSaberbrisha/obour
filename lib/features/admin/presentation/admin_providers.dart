import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepository(),
);

final adminCountsProvider =
    FutureProvider<({int users, int suppliers, int carriers, int clients})>((
      ref,
    ) async {
      final repo = ref.watch(adminRepositoryProvider);
      return await repo.fetchCounts();
    });

final adminUsersListProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final repo = ref.watch(adminRepositoryProvider);
  return await repo.fetchUsers();
});

final adminClientsListProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final repo = ref.watch(adminRepositoryProvider);
  return await repo.fetchClients();
});

final adminCarriersListProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final repo = ref.watch(adminRepositoryProvider);
  return await repo.fetchCarriers();
});

final adminSuppliersListProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final repo = ref.watch(adminRepositoryProvider);
  return await repo.fetchSuppliers();
});

final adminOrdersListProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final repo = ref.watch(adminRepositoryProvider);
  return await repo.fetchOrders();
});
