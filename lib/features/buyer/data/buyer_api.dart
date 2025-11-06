import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class BuyerApi {
  final Dio _dio;
  BuyerApi({Dio? dio}) : _dio = dio ?? ApiClient.build();

  Future<List<Map<String, dynamic>>> fetchOrders({int limit = 20}) async {
    try {
      final res = await _dio.get('/orders', queryParameters: {'limit': limit});
      final data = res.data as Map<String, dynamic>?;
      if (data != null) {
        if (data['orders'] is List) {
          return (data['orders'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        }
        if (data['data'] is List) {
          return (data['data'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        }
        if (data['data'] is Map && data['data']['orders'] is List) {
          return (data['data']['orders'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        }
      }
    } catch (e) {
      print('Error fetching buyer orders: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>?> createOrder(
    Map<String, dynamic> payload,
  ) async {
    final res = await _dio.post('/orders', data: payload);
    final data = res.data as Map<String, dynamic>?;
    if (data != null) {
      if (data['order'] is Map) return data['order'] as Map<String, dynamic>;
      if (data['data'] is Map && data['data']['order'] is Map) {
        return data['data']['order'] as Map<String, dynamic>;
      }
    }
    return null;
  }

  Future<void> updateOrderStatus(String id, String status) async {
    await _dio.patch('/orders/$id/status', data: {'status': status});
  }

  Future<List<Map<String, dynamic>>> fetchSuppliers() async {
    try {
      final res = await _dio.get('/suppliers');
      final data = res.data as Map<String, dynamic>?;
      if (data != null) {
        if (data['data'] is Map && data['data']['suppliers'] is List) {
          return (data['data']['suppliers'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        }
        if (data['suppliers'] is List) {
          return (data['suppliers'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        }
      }
    } catch (e) {
      print('Error fetching suppliers for buyer: $e');
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchCarriers() async {
    try {
      final res = await _dio.get('/naqlens');
      final data = res.data as Map<String, dynamic>?;
      if (data != null) {
        if (data['naqleen'] is List) {
          return (data['naqleen'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        }
      }
    } catch (e) {
      print('Error fetching carriers for buyer: $e');
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    try {
      final res = await _dio.get('/products');
      final data = res.data as Map<String, dynamic>?;
      if (data != null) {
        if (data['products'] is List) {
          return (data['products'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        }
        if (data['data'] is List) {
          return (data['data'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        }
        if (data['data'] is Map && data['data']['products'] is List) {
          return (data['data']['products'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        }
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchClients() async {
    try {
      final res = await _dio.get('/clients');
      final data = res.data as Map<String, dynamic>?;
      if (data != null) {
        if (data['clients'] is List) {
          return (data['clients'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        }
        if (data['data'] is Map && data['data']?['clients'] is List) {
          return (data['data']?['clients'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        }
      }
    } catch (e) {
      print('Error fetching clients for buyer: $e');
    }
    return [];
  }
}
