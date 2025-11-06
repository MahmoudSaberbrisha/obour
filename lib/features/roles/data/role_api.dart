import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class Region {
  final int id;
  final String name;
  final int cityId;

  Region({required this.id, required this.name, required this.cityId});

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(id: json['id'], name: json['name'], cityId: json['city_id']);
  }
}

class RoleApi {
  final Dio _dio;
  RoleApi({Dio? dio}) : _dio = dio ?? ApiClient.build();

  Future<void> saveBuyer(Map<String, dynamic> payload) async {
    await _dio.post('/clients', data: payload);
  }

  Future<void> saveSupplier(Map<String, dynamic> payload) async {
    await _dio.post('/suppliers', data: payload);
  }

  Future<void> saveCarrier(Map<String, dynamic> payload) async {
    await _dio.post('/naqlens', data: payload);
  }

  Future<void> saveClient(Map<String, dynamic> payload) async {
    await _dio.post('/clients', data: payload);
  }

  Future<List<Region>> getRegions() async {
    final response = await _dio.get('/Regions');
    final regionsData = response.data['regions'] as List;
    return regionsData.map((region) => Region.fromJson(region)).toList();
  }
}
