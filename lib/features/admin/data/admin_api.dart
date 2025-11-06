import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class AdminApi {
  final Dio _dio;

  AdminApi({Dio? dio}) : _dio = dio ?? ApiClient.build();

  Future<int> fetchClientsCount() async {
    final res = await _dio.get('/clients');
    if (res.data is Map && res.data['results'] is int) {
      return res.data['results'] as int;
    }
    if (res.data is Map && res.data['clients'] is List) {
      return (res.data['clients'] as List).length;
    }
    if (res.data is Map && res.data['pagination']?['totalItems'] is int) {
      return res.data['pagination']['totalItems'] as int;
    }
    return 0;
  }

  Future<int> fetchCarriersCount() async {
    final res = await _dio.get('/naqlens');
    if (res.data is Map && res.data['naqleen'] is List) {
      return (res.data['naqleen'] as List).length;
    }
    if (res.data is Map && res.data['pagination']?['totalItems'] is int) {
      return res.data['pagination']['totalItems'] as int;
    }
    return 0;
  }

  Future<int> fetchSuppliersCount() async {
    final res = await _dio.get('/suppliers');
    if (res.data is Map && res.data['data']?['suppliers'] is List) {
      return (res.data['data']['suppliers'] as List).length;
    }
    if (res.data is Map &&
        res.data['data']?['pagination']?['totalItems'] is int) {
      return res.data['data']['pagination']['totalItems'] as int;
    }
    return 0;
  }

  Future<int> fetchUsersCount() async {
    final res = await _dio.get('/users');
    if (res.data is Map && res.data['totalCount'] is int) {
      return res.data['totalCount'] as int;
    }
    if (res.data is Map && res.data['data'] is List) {
      return (res.data['data'] as List).length;
    }
    return 0;
  }

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    try {
      final res = await _dio.get('/users');
      final data = res.data as Map<String, dynamic>?;
      if (data != null && data['data'] is List) {
        return (data['data'] as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchClients() async {
    try {
      final res = await _dio.get('/clients');
      final data = res.data as Map<String, dynamic>?;
      if (data != null && data['clients'] is List) {
        return (data['clients'] as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      print('Error fetching clients: $e');
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchCarriers() async {
    try {
      final res = await _dio.get('/naqlens');
      final data = res.data as Map<String, dynamic>?;
      if (data != null && data['naqleen'] is List) {
        return (data['naqleen'] as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      print('Error fetching carriers: $e');
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchSuppliers() async {
    try {
      final res = await _dio.get('/suppliers');
      final data = res.data as Map<String, dynamic>?;
      if (data != null && data['data'] != null && data['data'] is Map) {
        final innerData = data['data'] as Map<String, dynamic>;
        if (innerData['suppliers'] is List) {
          return (innerData['suppliers'] as List)
              .map((item) => item as Map<String, dynamic>)
              .toList();
        }
      }
    } catch (e) {
      print('Error fetching suppliers: $e');
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    try {
      final res = await _dio.get('/orders');
      final data = res.data as Map<String, dynamic>?;
      if (data != null && data['orders'] is List) {
        return (data['orders'] as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();
      }
      if (data != null && data['data'] is List) {
        return (data['data'] as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      print('Error fetching orders: $e');
    }
    return [];
  }
}
