import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class CurlLoggerInterceptor extends Interceptor {
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _stopwatch.start();
    try {
      final method = options.method;
      final uri = options.uri;
      final headers = options.headers;
      final data = options.data;

      final curl = StringBuffer("curl --location --request $method '$uri'");

      headers.forEach((key, value) {
        if (key != 'cookie') {
          curl.write(" --header '$key: $value'");
        }
      });

      if (data != null) {
        if (data is Map && data.isNotEmpty) {
          curl.write(" --data-raw '${jsonEncode(data)}'");
        } else if (data is String && data.isNotEmpty) {
          curl.write(" --data-raw '$data'");
        } else if (data is FormData) {
          for (var field in data.fields) {
            curl.write(" --form '${field.key}=\"${field.value}\"'");
          }
          for (var file in data.files) {
            curl.write(" --form '${file.key}=\"@${file.value.filename}\"'");
          }
        }
      }

      debugPrint('\n\u001b[36m' + '=' * 60);
      debugPrint('🚀 CURL COMMAND GENERATED');
      debugPrint('=' * 60 + '\u001b[0m');
      debugPrint('\u001b[36m${curl.toString()}\u001b[0m');
      debugPrint('\u001b[36m' + '=' * 60 + '\u001b[0m\n');
    } catch (e) {
      debugPrint('Error generating cURL: $e');
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _stopwatch.stop();
    int duration = _stopwatch.elapsedMilliseconds;
    _stopwatch.reset();

    // Performance Color Coding
    String color = '\u001b[32m'; // Green (Fast)
    String tag = ' [FAST] ';
    if (duration > 1000) {
      color = '\u001b[31m'; // Red (High Load)
      tag = ' 🚨 [HIGH LOAD] ';
    } else if (duration > 500) {
      color = '\u001b[33m'; // Yellow (Medium Load)
      tag = ' ⚠️ [MEDIUM LOAD] ';
    }

    debugPrint(
      '$color$tag====> API Response: [${response.statusCode}] ${response.requestOptions.path} ($duration ms)\u001b[0m',
    );

    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _stopwatch.stop();
    _stopwatch.reset();

    debugPrint(
      '\u001b[31m[ERROR] ====> API Error: [${err.response?.statusCode}] ${err.requestOptions.path}\u001b[0m',
    );
    debugPrint('\u001b[31mError Message: ${err.message}\u001b[0m');

    return handler.next(err);
  }
}
