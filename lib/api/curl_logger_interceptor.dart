import 'dart:convert';
import 'dart:developer' as dev;
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

      final curl = StringBuffer("curl --location --request $method '$uri' \\\n");

      headers.forEach((key, value) {
        if (key != 'cookie') {
          curl.write("  --header '$key: $value' \\\n");
        }
      });

      if (data != null) {
        if (data is FormData) {
          for (var field in data.fields) {
            curl.write("  --form '${field.key}=\"${field.value}\"' \\\n");
          }
          for (var file in data.files) {
            curl.write("  --form '${file.key}=\"@${file.value.filename}\"' \\\n");
          }
        } else {
          try {
            curl.write("  --data-raw '${jsonEncode(data)}' \\\n");
          } catch (_) {
            curl.write("  --data-raw '$data' \\\n");
          }
        }
      }

      // Remove the trailing backslash and newline
      String curlString = curl.toString().trimRight();
      if (curlString.endsWith('\\')) {
        curlString = curlString.substring(0, curlString.length - 1).trimRight();
      }

      dev.log(
        '\n============================================================\n'
        '🚀 CURL COMMAND GENERATED\n'
        '============================================================\n'
        '$curlString\n'
        '============================================================',
        name: 'friday.curl',
      );
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
