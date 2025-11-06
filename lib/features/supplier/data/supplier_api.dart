import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class SupplierApi {
  final Dio _dio;

  SupplierApi({Dio? dio}) : _dio = dio ?? ApiClient.build();

  Future<Map<String, dynamic>> getMe() async {
    final res = await _dio.get('/auth/me');
    final data = res.data is Map<String, dynamic>
        ? res.data
        : Map<String, dynamic>.from(res.data);
    return data;
  }

  Future<void> createProduct(Map<String, dynamic> payload) async {
    try {
      await _dio.post('/products', data: payload);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct(int productId, Map<String, dynamic> payload) async {
    try {
      // Remove supplier_id from payload to prevent overwriting it
      final safePayload = Map<String, dynamic>.from(payload)..remove('supplier_id');
      await _dio.patch('/products/$productId', data: safePayload);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProductStock(int productId, int stockQuantity, {String operation = 'set'}) async {
    try {
      await _dio.patch(
        '/products/$productId/stock',
        data: {'stock_quantity': stockQuantity, 'operation': operation},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final res = await _dio.get(
        '/categories',
        queryParameters: {'limit': 1000},
      );
      List<Map<String, dynamic>> categories = [];

      if (res.data is Map) {
        if (res.data['data']?['categories'] is List) {
          categories = (res.data['data']['categories'] as List)
              .cast<Map<String, dynamic>>();
        } else if (res.data['categories'] is List) {
          categories = (res.data['categories'] as List)
              .cast<Map<String, dynamic>>();
        } else if (res.data['data'] is List) {
          categories = (res.data['data'] as List).cast<Map<String, dynamic>>();
        }
      } else if (res.data is List) {
        categories = res.data.cast<Map<String, dynamic>>();
      }

      return categories;
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  Future<int?> findSupplierIdByUserId(int userId) async {
    try {
      // First get user data to match by name/email/phone
      final userRes = await _dio.get('/auth/me');
      final userDataRaw = userRes.data is Map<String, dynamic>
          ? userRes.data
          : (userRes.data is Map
                ? Map<String, dynamic>.from(userRes.data)
                : {});

      final userData =
          userDataRaw['data'] ?? userDataRaw['user'] ?? userDataRaw;
      final userName = userData is Map
          ? (userData['name']?.toString().trim() ?? '')
          : '';
      final userPhone = userData is Map
          ? (userData['phone']?.toString().trim() ??
                userData['jwal']?.toString().trim() ??
                '')
          : '';

      print(
        'Searching for supplier with user data: userId=$userId, name=$userName, phone=$userPhone',
      );

      final res = await _dio.get('/suppliers');
      List<Map<String, dynamic>> suppliers = [];

      if (res.data is List) {
        suppliers = res.data.cast<Map<String, dynamic>>();
      } else if (res.data is Map) {
        if (res.data['suppliers'] is List) {
          suppliers = (res.data['suppliers'] as List)
              .cast<Map<String, dynamic>>();
        } else if (res.data['data'] is List) {
          suppliers = (res.data['data'] as List).cast<Map<String, dynamic>>();
        } else if (res.data['data']?['suppliers'] is List) {
          suppliers = (res.data['data']['suppliers'] as List)
              .cast<Map<String, dynamic>>();
        }
      }

      print('Found ${suppliers.length} suppliers to search through');

      for (var supplier in suppliers) {
        // Check by user_id
        if (supplier['user_id'] != null) {
          final supplierUserId = int.tryParse(supplier['user_id'].toString());
          if (supplierUserId == userId && supplier['id'] != null) {
            print('Found supplier by user_id: ${supplier['id']}');
            return int.tryParse(supplier['id'].toString());
          }
        }

        // Check User relation
        if (supplier['User'] != null && supplier['User'] is Map) {
          final supplierUser = supplier['User'] as Map;
          if (supplierUser['id'] != null) {
            final supplierUserId = int.tryParse(supplierUser['id'].toString());
            if (supplierUserId == userId && supplier['id'] != null) {
              print('Found supplier by User.id: ${supplier['id']}');
              return int.tryParse(supplier['id'].toString());
            }
          }
        }

        // Match by name
        if (userName.isNotEmpty) {
          final supplierName = supplier['name']?.toString().trim() ?? '';
          if (supplierName == userName && supplier['id'] != null) {
            print('Found supplier by name match: ${supplier['id']}');
            return int.tryParse(supplier['id'].toString());
          }
        }

        // Match by phone/jwal
        if (userPhone.isNotEmpty) {
          final supplierPhone =
              supplier['jwal']?.toString().trim() ??
              supplier['phone']?.toString().trim() ??
              '';
          if (supplierPhone == userPhone && supplier['id'] != null) {
            print('Found supplier by phone match: ${supplier['id']}');
            return int.tryParse(supplier['id'].toString());
          }
        }
      }

      print('No supplier found matching user');
      return null;
    } catch (e) {
      print('Error finding supplier by user ID: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getOrders({int? supplierId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (supplierId != null) {
        queryParams['supplier_id'] = supplierId;
      }
      queryParams['limit'] = 100;

      final res = await _dio.get('/orders', queryParameters: queryParams);
      List<Map<String, dynamic>> orders = [];

      if (res.data is List) {
        orders = res.data.cast<Map<String, dynamic>>();
      } else if (res.data is Map) {
        // Backend returns { status: "success", orders: [...], ... }
        if (res.data['orders'] is List) {
          orders = (res.data['orders'] as List).cast<Map<String, dynamic>>();
        } else if (res.data['data']?['orders'] is List) {
          orders = (res.data['data']['orders'] as List)
              .cast<Map<String, dynamic>>();
        } else if (res.data['data'] is List) {
          orders = (res.data['data'] as List).cast<Map<String, dynamic>>();
        }
      }

      print('Raw orders fetched: ${orders.length}');

      // Filter orders by supplier_id if provided (double check on client side)
      if (supplierId != null) {
        final beforeFilter = orders.length;
        orders = orders.where((order) {
          // Check Supplier relation
          if (order['Supplier'] != null && order['Supplier'] is Map) {
            final supplier = order['Supplier'] as Map;
            final orderSupplierId = supplier['id'];
            if (orderSupplierId != null) {
              final id = int.tryParse(orderSupplierId.toString());
              if (id == supplierId) {
                print('Order ${order['id']} matched by Supplier.id');
                return true;
              }
            }
          }
          // Check supplier_id field directly
          if (order['supplier_id'] != null) {
            final id = int.tryParse(order['supplier_id'].toString());
            if (id == supplierId) {
              print('Order ${order['id']} matched by supplier_id');
              return true;
            }
          }
          // Check supplierId field
          if (order['supplierId'] != null) {
            final id = int.tryParse(order['supplierId'].toString());
            if (id == supplierId) {
              print('Order ${order['id']} matched by supplierId');
              return true;
            }
          }
          return false;
        }).toList();
        print('Orders after filter: ${orders.length} (was $beforeFilter)');
      }

      print('Supplier $supplierId: Final orders count ${orders.length}');
      return orders;
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getProducts({int? supplierId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (supplierId != null) {
        queryParams['supplier_id'] = supplierId;
      }
      queryParams['limit'] = 100;

      final res = await _dio.get('/products', queryParameters: queryParams);
      List<Map<String, dynamic>> products = [];

      if (res.data is List) {
        products = res.data.cast<Map<String, dynamic>>();
      } else if (res.data is Map) {
        if (res.data['data']?['products'] is List) {
          products = (res.data['data']['products'] as List)
              .cast<Map<String, dynamic>>();
        } else if (res.data['products'] is List) {
          products = (res.data['products'] as List)
              .cast<Map<String, dynamic>>();
        } else if (res.data['data'] is List) {
          products = (res.data['data'] as List).cast<Map<String, dynamic>>();
        }
      }

      print('Raw products fetched: ${products.length}');

      // Filter products by supplier_id if provided (double check on client side)
      if (supplierId != null) {
        final beforeFilter = products.length;
        products = products.where((product) {
          // Check Supplier relation
          if (product['Supplier'] != null && product['Supplier'] is Map) {
            final supplier = product['Supplier'] as Map;
            final productSupplierId = supplier['id'];
            if (productSupplierId != null) {
              final id = int.tryParse(productSupplierId.toString());
              if (id == supplierId) {
                print('Product ${product['id']} matched by Supplier.id');
                return true;
              }
            }
          }
          // Check supplier_id field directly
          if (product['supplier_id'] != null) {
            final id = int.tryParse(product['supplier_id'].toString());
            if (id == supplierId) {
              print('Product ${product['id']} matched by supplier_id');
              return true;
            }
          }
          // Check supplierId field
          if (product['supplierId'] != null) {
            final id = int.tryParse(product['supplierId'].toString());
            if (id == supplierId) {
              print('Product ${product['id']} matched by supplierId');
              return true;
            }
          }
          return false;
        }).toList();
        print('Products after filter: ${products.length} (was $beforeFilter)');
      }

      print('Supplier $supplierId: Final products count ${products.length}');
      return products;
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getStats({int? supplierId}) async {
    try {
      final orders = await getOrders(supplierId: supplierId);
      final products = await getProducts(supplierId: supplierId);

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      final todayOrders = orders.where((order) {
        if (order['createdAt'] == null) return false;
        final orderDate = DateTime.parse(order['createdAt']);
        return orderDate.isAfter(todayStart);
      }).toList();

      final todayRevenue = todayOrders.fold<double>(0.0, (sum, order) {
        final price = order['total_price'];
        if (price == null) return sum;
        if (price is num) return sum + price.toDouble();
        if (price is String) return sum + (double.tryParse(price) ?? 0);
        return sum;
      });

      final newOrdersCount = orders.where((order) {
        final status = order['status']?.toString().toLowerCase();
        return status == 'pending' || status == 'initial' || status == 'new';
      }).length;

      final lowStockProducts = products.where((product) {
        final stock =
            product['stock_quantity'] ??
            product['stock'] ??
            product['quantity'] ??
            product['available_quantity'];
        final stockNum = stock is num
            ? stock.toInt()
            : (int.tryParse(stock?.toString() ?? '0') ?? 0);
        final minStock = product['min_stock_level'] != null
            ? (product['min_stock_level'] is num
                  ? product['min_stock_level'].toInt()
                  : (int.tryParse(product['min_stock_level'].toString()) ?? 0))
            : 0;
        // Product is low stock if it's below min_stock_level or below 10 if no min_stock_level
        return stockNum <= (minStock > 0 ? minStock : 10);
      }).length;

      return {
        'todayRevenue': todayRevenue,
        'newOrdersCount': newOrdersCount,
        'lowStockCount': lowStockProducts,
        'totalOrders': orders.length,
        'totalProducts': products.length,
      };
    } catch (e) {
      print('Error calculating stats: $e');
      return {
        'todayRevenue': 0.0,
        'newOrdersCount': 0,
        'lowStockCount': 0,
        'totalOrders': 0,
        'totalProducts': 0,
      };
    }
  }
}
