import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Print minimal logs in debug mode only
    assert(() {
      // ignore: avoid_print
      print('[HTTP] → ${options.method} ${options.uri}');
      return true;
    }());
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    assert(() {
      // ignore: avoid_print
      print('[HTTP] ← ${response.statusCode} ${response.requestOptions.uri}');
      return true;
    }());
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    assert(() {
      // ignore: avoid_print
      print('[HTTP] ✖ ${err.response?.statusCode} ${err.requestOptions.uri}: ${err.message}');
      return true;
    }());
    super.onError(err, handler);
  }
}
