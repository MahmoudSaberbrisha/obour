import 'package:dio/dio.dart';
import '../../../core/config/env.dart';
import '../../../core/storage/secure_storage.dart';

class CarrierApi {
  final Dio _dio;
  final SecureStorage _storage;

  CarrierApi()
    : _dio = Dio(
        BaseOptions(
          baseUrl: Env.apiBaseUrl,
          headers: {'Content-Type': 'application/json'},
        ),
      ),
      _storage = SecureStorage() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.readAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> getMe() async {
    final res = await _dio.get('/auth/me');
    final data = res.data is Map
        ? res.data
        : Map<String, dynamic>.from(res.data);
    return data;
  }

  Future<List<Map<String, dynamic>>> getOrders({int? carrierId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (carrierId != null) {
        queryParams['carrier_id'] = carrierId;
      }
      queryParams['limit'] = 100;

      final res = await _dio.get('/orders', queryParameters: queryParams);
      List<Map<String, dynamic>> orders = [];

      if (res.data is List) {
        orders = res.data.cast<Map<String, dynamic>>();
      } else if (res.data is Map) {
        if (res.data['data']?['orders'] is List) {
          orders = (res.data['data']['orders'] as List)
              .cast<Map<String, dynamic>>();
        } else if (res.data['orders'] is List) {
          orders = (res.data['orders'] as List).cast<Map<String, dynamic>>();
        } else if (res.data['data'] is List) {
          orders = (res.data['data'] as List).cast<Map<String, dynamic>>();
        }
      }

      print('Raw orders fetched before filtering: ${orders.length}');

      // Filter orders by carrier_id if provided
      if (carrierId != null) {
        print('Filtering orders for carrier_id: $carrierId');
        orders = orders.where((order) {
          print(
            'Order: ${order['id']}, carrier_id: ${order['carrier_id']}, Carrier: ${order['Carrier']}',
          );

          if (order['carrier_id'] != null) {
            final id = int.tryParse(order['carrier_id'].toString());
            if (id == carrierId) {
              print('Order ${order['id']} matched by carrier_id');
              return true;
            }
          }
          if (order['Carrier'] != null && order['Carrier'] is Map) {
            final carrier = order['Carrier'] as Map;
            if (carrier['id'] != null) {
              final id = int.tryParse(carrier['id'].toString());
              if (id == carrierId) {
                print('Order ${order['id']} matched by Carrier.id');
                return true;
              }
            }
          }
          return false;
        }).toList();
        print('Filtered orders count: ${orders.length}');
      }

      return orders;
    } catch (e) {
      print('Error fetching carrier orders: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getStats({required int carrierId}) async {
    try {
      final orders = await getOrders(carrierId: carrierId);

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      final todayOrders = orders.where((order) {
        if (order['createdAt'] == null) return false;
        final orderDate = DateTime.parse(order['createdAt']);
        return orderDate.isAfter(todayStart);
      }).toList();

      final activeOrders = orders.where((order) {
        final status = order['status']?.toString().toLowerCase();
        return status == 'shipped' ||
            status == 'in_transit' ||
            status == 'pickup';
      }).length;

      final completedOrders = orders.where((order) {
        final status = order['status']?.toString().toLowerCase();
        return status == 'delivered' || status == 'completed';
      }).length;

      return {
        'activeOrders': activeOrders,
        'completedOrders': completedOrders,
        'todayOrders': todayOrders.length,
        'totalOrders': orders.length,
      };
    } catch (e) {
      print('Error calculating carrier stats: $e');
      return {
        'activeOrders': 0,
        'completedOrders': 0,
        'todayOrders': 0,
        'totalOrders': 0,
      };
    }
  }

  Future<int?> findCarrierIdByUserId(int userId) async {
    try {
      final res = await _dio.get('/naqlens');
      List<dynamic> carriers = [];

      if (res.data is List) {
        carriers = res.data;
      } else if (res.data is Map) {
        if (res.data['naqleen'] is List) {
          carriers = res.data['naqleen'] as List;
        } else if (res.data['data']?['carriers'] is List) {
          carriers = res.data['data']['carriers'] as List;
        } else if (res.data['carriers'] is List) {
          carriers = res.data['carriers'] as List;
        } else if (res.data['data'] is List) {
          carriers = res.data['data'] as List;
        }
      }

      print('Found ${carriers.length} carriers from /naqlens endpoint');

      // Get user data to match by identification_number and phone
      final me = await getMe();
      final userData = me['data'] ?? me;
      final userIdentificationNumber = userData['identification_number']
          ?.toString();
      final userPhone = userData['phone']?.toString();

      print('User identification_number: $userIdentificationNumber');
      print('User phone: $userPhone');

      for (var carrier in carriers) {
        final carrierMap = carrier is Map
            ? carrier
            : Map<String, dynamic>.from(carrier);
        print('Checking carrier: ${carrierMap['id']}, ${carrierMap['name']}');

        if (carrierMap['user_id'] == userId || carrierMap['userId'] == userId) {
          print('Found matching carrier by user_id: ${carrierMap['id']}');
          return int.tryParse(carrierMap['id'].toString());
        }
        if (carrierMap['User'] != null && carrierMap['User'] is Map) {
          final user = carrierMap['User'] as Map;
          if (user['id'] == userId) {
            print('Found matching carrier by User.id: ${carrierMap['id']}');
            return int.tryParse(carrierMap['id'].toString());
          }
        }

        // Match by identification_number and phone
        final carrierIdNumber = carrierMap['identification_number']?.toString();
        final carrierPhone = carrierMap['jwal']?.toString();

        if (userIdentificationNumber != null && carrierIdNumber != null) {
          if (userIdentificationNumber == carrierIdNumber) {
            print(
              'Found matching carrier by identification_number: ${carrierMap['id']}',
            );
            return int.tryParse(carrierMap['id'].toString());
          }
        }

        if (userPhone != null && carrierPhone != null) {
          // Remove any leading zeros or country codes for comparison
          final cleanUserPhone = userPhone.replaceAll(RegExp(r'^\+?0*'), '');
          final cleanCarrierPhone = carrierPhone.replaceAll(
            RegExp(r'^\+?0*'),
            '',
          );

          if (cleanUserPhone == cleanCarrierPhone) {
            print('Found matching carrier by phone: ${carrierMap['id']}');
            return int.tryParse(carrierMap['id'].toString());
          }
        }
      }
      print('No carrier found for userId: $userId');
      return null;
    } catch (e) {
      print('Error finding carrier by user ID: $e');
      return null;
    }
  }
}
