import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/supplier_api.dart';

final supplierApiProvider = Provider<SupplierApi>((ref) => SupplierApi());

final supplierMeProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(supplierApiProvider);
  return await api.getMe();
});

final supplierIdProvider = FutureProvider<int?>((ref) async {
  try {
    final me = await ref.watch(supplierMeProvider.future);
    final api = ref.read(supplierApiProvider);
    print('getMe response: $me'); // Debug log

    // Try different possible structures for supplier ID
    if (me['supplier'] != null) {
      if (me['supplier'] is Map) {
        final supplier = me['supplier'] as Map;
        if (supplier['id'] != null) {
          final id = int.tryParse(supplier['id'].toString());
          print('Found supplier ID from supplier.id: $id');
          return id;
        }
      }
      if (me['supplier'] is int) {
        print('Found supplier ID as int: ${me['supplier']}');
        return me['supplier'] as int?;
      }
    }
    if (me['supplier_id'] != null) {
      final id = int.tryParse(me['supplier_id'].toString());
      print('Found supplier ID from supplier_id: $id');
      return id;
    }
    // Get user ID from me response
    int? userId;
    Map<String, dynamic>? userData;

    if (me['user'] != null && me['user'] is Map) {
      final user = me['user'] as Map;
      userData = Map<String, dynamic>.from(user);
      if (userData['id'] != null) {
        userId = int.tryParse(userData['id'].toString());
      }
    } else if (me['data'] != null && me['data'] is Map) {
      final data = me['data'] as Map;
      userData = Map<String, dynamic>.from(data);
      if (userData['id'] != null) {
        userId = int.tryParse(userData['id'].toString());
      }
    } else if (me['id'] != null) {
      userId = int.tryParse(me['id'].toString());
      userData = Map<String, dynamic>.from(me);
    }

    // Try to find supplier record by user ID
    // Note: We try this even if person_type is not set, as sometimes it might not be in the response
    if (userId != null) {
      print('Attempting to find supplier record for user ID: $userId');
      final supplierId = await api.findSupplierIdByUserId(userId);
      if (supplierId != null) {
        print('Found supplier ID by user ID: $supplierId');
        return supplierId;
      }
    }
    // Last resort: try direct id (might be supplier id if user is supplier)
    if (me['id'] != null) {
      final id = int.tryParse(me['id'].toString());
      print('Using direct id as supplier ID: $id');
      return id;
    }
    print('Could not find supplier ID');
    return null;
  } catch (e) {
    print('Error getting supplier ID: $e');
    return null;
  }
});

final supplierOrdersProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final api = ref.watch(supplierApiProvider);
  final supplierId = await ref.watch(supplierIdProvider.future);
  if (supplierId == null) {
    print('Warning: supplierId is null, returning empty orders list');
    return [];
  }
  return await api.getOrders(supplierId: supplierId);
});

final supplierProductsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final api = ref.watch(supplierApiProvider);
  final supplierId = await ref.watch(supplierIdProvider.future);
  if (supplierId == null) {
    print('Warning: supplierId is null, returning empty products list');
    return [];
  }
  return await api.getProducts(supplierId: supplierId);
});

final supplierStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(supplierApiProvider);
  final supplierId = await ref.watch(supplierIdProvider.future);
  if (supplierId == null) {
    print('Warning: supplierId is null, returning empty stats');
    return {
      'todayRevenue': 0.0,
      'newOrdersCount': 0,
      'lowStockCount': 0,
      'totalOrders': 0,
      'totalProducts': 0,
    };
  }
  return await api.getStats(supplierId: supplierId);
});

final supplierCategoriesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final api = ref.watch(supplierApiProvider);
  return await api.getCategories();
});
