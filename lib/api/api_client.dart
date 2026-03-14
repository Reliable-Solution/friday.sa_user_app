import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:friday_sa/api/api_checker.dart';
import 'package:friday_sa/features/address/domain/models/address_model.dart';
import 'package:friday_sa/common/models/error_response.dart';
import 'package:friday_sa/common/models/module_model.dart';

import 'package:friday_sa/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dio/dio.dart' as dio;

class ApiClient extends GetxService {
  static final Map<String, int> _apiPerformance = {};

  static void printPerformanceSummary() {
    debugPrint('\n\n\u001b[35m' + '=' * 60);
    debugPrint('          🚀 API PERFORMANCE SUMMARY (Slowest 10)');
    debugPrint('=' * 60 + '\u001b[0m');
    var sortedEntries = _apiPerformance.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedEntries.isEmpty) {
      debugPrint('No API records yet.');
    } else {
      for (var entry in sortedEntries.take(10)) {
        String color = entry.value > 1000
            ? '\u001b[31m'
            : (entry.value > 500 ? '\u001b[33m' : '\u001b[32m');
        debugPrint(
          '$color${entry.value.toString().padLeft(6)} ms : ${entry.key}\u001b[0m',
        );
      }
    }
    debugPrint('\u001b[35m' + '=' * 60 + '\u001b[0m\n\n');
  }

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
    _dio = dio.Dio();
    _dio.options.baseUrl = appBaseUrl;
    _dio.options.connectTimeout = Duration(seconds: timeoutInSeconds);
    _dio.options.receiveTimeout = Duration(seconds: timeoutInSeconds);
    _dio.options.validateStatus = (status) => status! < 600;

    token = sharedPreferences.getString(AppConstants.token);
    if (kDebugMode) {
      debugPrint('Token: $token');
    }
    AddressModel? addressModel;
    try {
      addressModel = AddressModel.fromJson(
        jsonDecode(sharedPreferences.getString(AppConstants.userAddress)!),
      );
    } catch (_) {}
    int? moduleID;
    if (GetPlatform.isWeb &&
        sharedPreferences.containsKey(AppConstants.moduleId)) {
      try {
        moduleID = ModuleModel.fromJson(
          jsonDecode(sharedPreferences.getString(AppConstants.moduleId)!),
        ).id;
      } catch (_) {}
    }
    updateHeader(
      token,
      addressModel?.zoneIds,
      addressModel?.areaIds,
      sharedPreferences.getString(AppConstants.languageCode),
      moduleID,
      addressModel?.latitude,
      addressModel?.longitude,
    );
  }

  Future<Response> getCardData(
    String uri, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool handleError = true,
  }) async {
    try {
      final usedHeaders = headers ?? _mainHeaders;
      final fullUrl = AppConstants.cardUrl + uri;

      printCurl(
        "GET",
        Uri.parse(fullUrl).replace(queryParameters: query),
        usedHeaders,
      );

      final stopwatch = Stopwatch()..start();
      dio.Response response = await _dio.get(
        fullUrl,
        queryParameters: query,
        options: dio.Options(headers: usedHeaders),
      );
      stopwatch.stop();

      return handleDioResponse(
        response,
        uri,
        handleError,
        duration: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  late dio.Dio _dio;
  final String appBaseUrl;
  final SharedPreferences sharedPreferences;
  static final String noInternetMessage = 'connection_to_api_server_failed'.tr;
  final int timeoutInSeconds = 10;

  String? token;
  late Map<String, String> _mainHeaders;

  Map<String, String> updateHeader(
    String? token,
    List<int>? zoneIDs,
    List<int>? operationIds,
    String? languageCode,
    int? moduleID,
    String? latitude,
    String? longitude, {
    bool setHeader = true,
  }) {
    Map<String, String> header = {};

    if (moduleID != null ||
        sharedPreferences.getString(AppConstants.cacheModuleId) != null) {
      header.addAll({
        AppConstants.moduleId:
            '${moduleID ?? ModuleModel.fromJson(jsonDecode(sharedPreferences.getString(AppConstants.cacheModuleId)!)).id}',
      });
    }
    header.addAll({
      'Content-Type': 'application/json; charset=UTF-8',
      AppConstants.zoneId: zoneIDs != null ? jsonEncode(zoneIDs) : '',

      ///this will add in ride module
      // AppConstants.operationAreaId: operationIds != null ? jsonEncode(operationIds) : '',
      AppConstants.localizationKey:
          languageCode ?? AppConstants.languages[0].languageCode!,
      AppConstants.latitude: latitude != null ? jsonEncode(latitude) : '',
      AppConstants.longitude: longitude != null ? jsonEncode(longitude) : '',
      'Authorization': 'Bearer $token',
    });
    if (setHeader) {
      _mainHeaders = header;
      _dio.options.headers = header;
    }
    return header;
  }

  void printCurl(
    String method,
    Uri uri,
    Map<String, String> headers, [
    dynamic body,
  ]) {
    final curl = StringBuffer("curl --location --request $method '$uri'");

    headers.forEach((key, value) {
      curl.write(" --header '$key: $value'");
    });

    if (body != null) {
      if (body is Map && body.isNotEmpty) {
        curl.write(" --data-raw '${jsonEncode(body)}'");
      } else if (body is String && body.isNotEmpty) {
        curl.write(" --data-raw '$body'");
      }
    }

    debugPrint(
      '\n\u001b[36m==================== POSTMAN cURL START ====================\u001b[0m',
    );
    debugPrint('\u001b[36m${curl.toString()}\u001b[0m');
    debugPrint(
      '\u001b[36m===================== POSTMAN cURL END =====================\u001b[0m\n',
    );
  }

  Map<String, String> getHeader() => _mainHeaders;

  Future<Response> getData(
    String uri, {
    String? baseUrl,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool handleError = true,
  }) async {
    try {
      final requestHeaders = headers ?? _mainHeaders;
      final fullUrl = (baseUrl ?? appBaseUrl) + uri;

      printCurl(
        "GET",
        Uri.parse(fullUrl).replace(queryParameters: query),
        requestHeaders,
      );

      // When custom headers are passed, temporarily clear Dio's default
      // headers to prevent merging (e.g., old moduleId leaking through).
      Map<String, dynamic>? savedHeaders;
      if (headers != null) {
        savedHeaders = Map<String, dynamic>.from(_dio.options.headers);
        _dio.options.headers = {};
      }

      final stopwatch = Stopwatch()..start();
      dio.Response response = await _dio.get(
        fullUrl,
        queryParameters: query,
        options: dio.Options(headers: requestHeaders),
      );
      stopwatch.stop();

      // Restore default headers
      if (savedHeaders != null) {
        _dio.options.headers = savedHeaders;
      }

      return handleDioResponse(
        response,
        uri,
        handleError,
        duration: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postData(
    String uri,
    dynamic body, {
    Map<String, String>? headers,
    int? timeout,
    bool handleError = true,
  }) async {
    try {
      final requestHeaders = headers ?? _mainHeaders;
      final fullUrl = appBaseUrl + uri;

      printCurl("POST", Uri.parse(fullUrl), requestHeaders, body);

      final stopwatch = Stopwatch()..start();
      dio.Response response = await _dio.post(
        fullUrl,
        data: body,
        options: dio.Options(headers: requestHeaders),
      );
      stopwatch.stop();

      return handleDioResponse(
        response,
        uri,
        handleError,
        duration: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postMultipartData(
    String uri,
    Map<String, String> body,
    List<MultipartBody> multipartBody, {
    Map<String, String>? headers,
    bool handleError = true,
  }) async {
    try {
      final requestHeaders = headers ?? _mainHeaders;
      final fullUrl = appBaseUrl + uri;

      dio.FormData formData = dio.FormData.fromMap(body);
      for (MultipartBody multipart in multipartBody) {
        if (multipart.file != null) {
          if (kIsWeb) {
            Uint8List list = await multipart.file!.readAsBytes();
            formData.files.add(
              MapEntry(
                multipart.key,
                dio.MultipartFile.fromBytes(
                  list,
                  filename: multipart.file!.name,
                ),
              ),
            );
          } else {
            formData.files.add(
              MapEntry(
                multipart.key,
                await dio.MultipartFile.fromFile(
                  multipart.file!.path,
                  filename: multipart.file!.name,
                ),
              ),
            );
          }
        }
      }

      printCurl("POST (Multipart)", Uri.parse(fullUrl), requestHeaders, body);

      final stopwatch = Stopwatch()..start();
      dio.Response response = await _dio.post(
        fullUrl,
        data: formData,
        options: dio.Options(headers: requestHeaders),
      );
      stopwatch.stop();

      return handleDioResponse(
        response,
        uri,
        handleError,
        duration: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> putData(
    String uri,
    dynamic body, {
    Map<String, String>? headers,
    bool handleError = true,
  }) async {
    try {
      final requestHeaders = headers ?? _mainHeaders;
      final fullUrl = appBaseUrl + uri;

      printCurl("PUT", Uri.parse(fullUrl), requestHeaders, body);

      final stopwatch = Stopwatch()..start();
      dio.Response response = await _dio.put(
        fullUrl,
        data: body,
        options: dio.Options(headers: requestHeaders),
      );
      stopwatch.stop();

      return handleDioResponse(
        response,
        uri,
        handleError,
        duration: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> deleteData(
    String uri, {
    Map<String, String>? headers,
    dynamic body,
    bool handleError = true,
  }) async {
    try {
      final requestHeaders = headers ?? _mainHeaders;
      final fullUrl = appBaseUrl + uri;

      printCurl("DELETE", Uri.parse(fullUrl), requestHeaders, body);

      final stopwatch = Stopwatch()..start();
      dio.Response response = await _dio.delete(
        fullUrl,
        data: body,
        options: dio.Options(headers: requestHeaders),
      );
      stopwatch.stop();

      return handleDioResponse(
        response,
        uri,
        handleError,
        duration: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Response handleDioResponse(
    dio.Response response,
    String uri,
    bool handleError, {
    int? duration,
  }) {
    if (duration != null) {
      _apiPerformance[uri] = duration;
    }

    Response response0 = Response(
      body: response.data,
      bodyString: response.data.toString(),
      headers: response.headers.map.map(
        (key, value) => MapEntry(key, value.join(',')),
      ),
      statusCode: response.statusCode,
      statusText: response.statusMessage,
    );

    // Color coding logic
    String color = '\u001b[32m'; // Green (Fast)
    String tag = ' [FAST] ';
    if (duration != null) {
      if (duration > 1000) {
        color = '\u001b[31m'; // Red (High Load)
        tag = ' 🚨 [HIGH LOAD] ';
      } else if (duration > 500) {
        color = '\u001b[33m'; // Yellow (Medium Load)
        tag = ' ⚠️ [MEDIUM LOAD] ';
      }
    }
    debugPrint(
      '$color$tag====> API Response: [${response0.statusCode}] $uri ${duration != null ? '($duration ms)' : ''}\u001b[0m',
    );

    if (response0.statusCode != 200 &&
        response0.body != null &&
        response0.body is! String) {
      if (response0.body.toString().startsWith('{errors: [{code:')) {
        ErrorResponse errorResponse = ErrorResponse.fromJson(response0.body);
        response0 = Response(
          statusCode: response0.statusCode,
          body: response0.body,
          statusText: errorResponse.errors![0].message,
        );
      } else if (response0.body.toString().startsWith('{message')) {
        response0 = Response(
          statusCode: response0.statusCode,
          body: response0.body,
          statusText: response0.body['message'],
        );
      }
    } else if (response0.statusCode != 200 && response0.body == null) {
      response0 = Response(statusCode: 0, statusText: noInternetMessage);
    }

    if (handleError) {
      if (response0.statusCode == 200) {
        return response0;
      } else {
        ApiChecker.checkApi(response0);
        return const Response();
      }
    } else {
      return response0;
    }
  }

  @override
  void onClose() {
    _dio.close();
    super.onClose();
  }
}

class MultipartBody {
  MultipartBody(this.key, this.file);

  String key;
  XFile? file;
}
