import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/carrier_api.dart';

final carrierApiProvider = Provider<CarrierApi>((ref) => CarrierApi());

final carrierMeProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(carrierApiProvider);
  return await api.getMe();
});

final carrierIdProvider = FutureProvider<int?>((ref) async {
  try {
    final me = await ref.watch(carrierMeProvider.future);
    final api = ref.read(carrierApiProvider);
    print('getMe response: $me');

    // Try different possible structures for carrier ID
    if (me['carrier'] != null) {
      if (me['carrier'] is Map) {
        final carrier = me['carrier'] as Map;
        if (carrier['id'] != null) {
          final id = int.tryParse(carrier['id'].toString());
          print('Found carrier ID from carrier.id: $id');
          return id;
        }
      }
      if (me['carrier'] is int) {
        print('Found carrier ID as int: ${me['carrier']}');
        return me['carrier'] as int?;
      }
    }
    if (me['carrier_id'] != null) {
      final id = int.tryParse(me['carrier_id'].toString());
      print('Found carrier ID from carrier_id: $id');
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

    // Try to find carrier record by user ID
    if (userId != null) {
      print('Attempting to find carrier record for user ID: $userId');
      final carrierId = await api.findCarrierIdByUserId(userId);
      if (carrierId != null) {
        print('Found carrier ID by user ID: $carrierId');
        return carrierId;
      }
    }

    // Last resort: try direct id
    if (me['id'] != null) {
      final id = int.tryParse(me['id'].toString());
      print('Using direct id as carrier ID: $id');
      return id;
    }
    print('Could not find carrier ID');
    return null;
  } catch (e) {
    print('Error getting carrier ID: $e');
    return null;
  }
});

final carrierOrdersProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final api = ref.watch(carrierApiProvider);
  final carrierId = await ref.watch(carrierIdProvider.future);
  if (carrierId == null) {
    print('Warning: carrierId is null, returning empty orders list');
    return [];
  }
  return await api.getOrders(carrierId: carrierId);
});

final carrierStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(carrierApiProvider);
  final carrierId = await ref.watch(carrierIdProvider.future);
  if (carrierId == null) {
    print('Warning: carrierId is null, returning empty stats');
    return {
      'activeOrders': 0,
      'completedOrders': 0,
      'todayOrders': 0,
      'totalOrders': 0,
    };
  }
  return await api.getStats(carrierId: carrierId);
});
