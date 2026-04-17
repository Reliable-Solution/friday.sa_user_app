import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:friday_sa/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:friday_sa/api/curl_logger_interceptor.dart';

class DioClient {
  final String baseUrl;
  final SharedPreferences sharedPreferences;
  late Dio dio;

  DioClient({required this.baseUrl, required this.sharedPreferences}) {
    dio = Dio();
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    dio.options.validateStatus = (status) =>
        status! < 600; // Capture all 4xx/5xx errors

    // Initial Header setup
    updateHeader(
      sharedPreferences.getString(AppConstants.token),
      null,
      null,
      sharedPreferences.getString(AppConstants.languageCode),
      null,
      null,
      null,
    );
    dio.interceptors.add(CurlLoggerInterceptor());
  }

  void updateHeader(
    String? token,
    List<int>? zoneIDs,
    List<int>? operationIds,
    String? languageCode,
    int? moduleID,
    String? latitude,
    String? longitude,
  ) {
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
      AppConstants.localizationKey:
          languageCode ?? AppConstants.languages[0].languageCode!,
      'Authorization': 'Bearer $token',
    };

    if (moduleID != null) {
      header.addAll({AppConstants.moduleId: moduleID.toString()});
    }
    if (zoneIDs != null) {
      header.addAll({AppConstants.zoneId: jsonEncode(zoneIDs)});
    }
    if (latitude != null) {
      header.addAll({AppConstants.latitude: latitude});
    }
    if (longitude != null) {
      header.addAll({AppConstants.longitude: longitude});
    }

    dio.options.headers.addAll(header);
  }

  Future<Response> getData(String uri, {Map<String, dynamic>? query}) async {
    try {
      return await dio.get(baseUrl + uri, queryParameters: query);
    } catch (e) {
      return Response(
        requestOptions: RequestOptions(path: uri),
        statusCode: 1,
        statusMessage: 'Connection failed',
      );
    }
  }

  Future<Response> postData(String uri, dynamic data) async {
    try {
      return await dio.post(baseUrl + uri, data: data);
    } catch (e) {
      return Response(
        requestOptions: RequestOptions(path: uri),
        statusCode: 1,
        statusMessage: 'Connection failed',
      );
    }
  }

  Future<Response> putData(String uri, dynamic data) async {
    try {
      return await dio.put(baseUrl + uri, data: data);
    } catch (e) {
      return Response(
        requestOptions: RequestOptions(path: uri),
        statusCode: 1,
        statusMessage: 'Connection failed',
      );
    }
  }

  Future<Response> deleteData(String uri) async {
    try {
      return await dio.delete(baseUrl + uri);
    } catch (e) {
      return Response(
        requestOptions: RequestOptions(path: uri),
        statusCode: 1,
        statusMessage: 'Connection failed',
      );
    }
  }
}

