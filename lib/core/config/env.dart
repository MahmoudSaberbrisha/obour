import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get apiBaseUrl {
    try {
      final url = dotenv.get('API_BASE_URL', fallback: '').trim();
      if (url.isNotEmpty) {
        return url;
      }
      return 'http://localhost:5070/api/v1';
    } catch (_) {
      return 'http://localhost:5070/api/v1';
    }
  }

  static Duration get connectTimeout => const Duration(seconds: 15);
  static Duration get receiveTimeout => const Duration(seconds: 20);
}
