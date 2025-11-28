import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:friday_sa/api/api_checker.dart';
import 'package:friday_sa/features/address/domain/models/address_model.dart';
import 'package:friday_sa/common/models/error_response.dart';
import 'package:friday_sa/common/models/module_model.dart';
import 'package:friday_sa/helper/responsive_helper.dart';
import 'package:friday_sa/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ApiClient extends GetxService {
  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
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
      final url = Uri.parse(
        AppConstants.cardUrl + uri,
      ).replace(queryParameters: query).toString();

      // Construct the curl command
      final curlCommand = StringBuffer("curl -X GET");
      usedHeaders.forEach((key, value) {
        curlCommand.write(" -H '$key: $value'");
      });
      curlCommand.write(" '$url'");

      debugPrint('====> API Call: $url\nHeader: $usedHeaders');
      debugPrint('====> cURL:\n$curlCommand');

      final http.Response response = await http
          .get(Uri.parse(url), headers: usedHeaders)
          .timeout(Duration(seconds: timeoutInSeconds));

      return handleResponse(response, uri, handleError);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  final String appBaseUrl;
  final SharedPreferences sharedPreferences;
  static final String noInternetMessage = 'connection_to_api_server_failed'.tr;
  final int timeoutInSeconds = 40;

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
    }
    return header;
  }

  void printCurl(
    String method,
    Uri uri,
    Map<String, String> headers, [
    dynamic body,
  ]) {
    final headerStrings = headers.entries
        .map((e) => "-H '${e.key}: ${e.value}'")
        .join(' ');
    String curl = "curl -X $method '$uri' $headerStrings";
    if (body != null) {
      curl += " -d '${jsonEncode(body)}'";
    }
    log('CURL: $curl');
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
      final fullUri = Uri.parse(
        (baseUrl ?? AppConstants.baseUrl) + uri,
      ).replace(queryParameters: query);
      final requestHeaders = headers ?? _mainHeaders;

      printCurl("GET", fullUri, requestHeaders);

      http.Response response = await http
          .get(fullUri, headers: requestHeaders)
          .timeout(Duration(seconds: timeoutInSeconds));

      return handleResponse(response, uri, handleError);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('------------${e.toString()}');
      }
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
      debugPrint('====> API Call: $uri\nHeader: ${headers ?? _mainHeaders}');
      debugPrint('====> API Body: $body');

      Map<dynamic, dynamic> newBody = {};
      if (body != null) {
        body.forEach((key, value) {
          if (value != null && value.toString().isNotEmpty) {
            newBody.addAll({key: value});
          }
        });
      }
      final fullUri = Uri.parse(AppConstants.baseUrl + uri);
      final requestHeaders = headers ?? _mainHeaders;
      printCurl("POST", fullUri, requestHeaders, newBody);
      http.Response response = await http
          .post(
            Uri.parse(AppConstants.baseUrl + uri),
            body: jsonEncode(newBody),
            headers: headers ?? _mainHeaders,
          )
          .timeout(Duration(seconds: timeout ?? timeoutInSeconds));
      return handleResponse(response, uri, handleError);
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
      debugPrint('====> API Call: $uri\nHeader: ${headers ?? _mainHeaders}');
      debugPrint('====> API Body: $body with ${multipartBody.length} picture');
      Uri fullUri = Uri.parse(AppConstants.baseUrl + uri);
      Map<String, String> newBody1 = {};
      body.forEach((s, i) {
        if (i.isNotEmpty) {
          newBody1.addAll({s: i});
        }
      });

      printCurl("POST", fullUri, headers ?? _mainHeaders, newBody1);

      http.MultipartRequest request = http.MultipartRequest(
        'POST',
        Uri.parse(AppConstants.baseUrl + uri),
      );
      request.headers.addAll(headers ?? _mainHeaders);
      for (MultipartBody multipart in multipartBody) {
        if (multipart.file != null) {
          Uint8List list = await multipart.file!.readAsBytes();
          request.files.add(
            http.MultipartFile(
              multipart.key,
              multipart.file!.readAsBytes().asStream(),
              list.length,
              filename: '${DateTime.now().toString()}.png',
            ),
          );
        }
      }
      Map<String, String> newBody = {};
      body.forEach((s, i) {
        if (i.isNotEmpty) {
          newBody.addAll({s: i});
        }
      });
      request.fields.addAll(newBody);
      http.Response response = await http.Response.fromStream(
        await request.send(),
      );
      return handleResponse(response, uri, handleError);
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
      debugPrint('====> API Call: $uri\nHeader: ${headers ?? _mainHeaders}');
      debugPrint('====> API Body: $body');
      final fullUri = Uri.parse(AppConstants.baseUrl + uri);
      final requestHeaders = headers ?? _mainHeaders;

      printCurl("PUT", fullUri, requestHeaders, body);
      http.Response response = await http
          .put(
            Uri.parse(AppConstants.baseUrl + uri),
            body: jsonEncode(body),
            headers: headers ?? _mainHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri, handleError);
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
      debugPrint('====> API Call: $uri\nHeader: ${headers ?? _mainHeaders}');
      final fullUri = Uri.parse(AppConstants.baseUrl + uri);
      final requestHeaders = headers ?? _mainHeaders;

      printCurl("DELETE", fullUri, requestHeaders);
      http.Response response = await http
          .delete(
            Uri.parse(AppConstants.baseUrl + uri),
            headers: headers ?? _mainHeaders,
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Response handleResponse(
    http.Response response,
    String uri,
    bool handleError,
  ) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {}
    Response response0 = Response(
      body: body ?? response.body,
      bodyString: response.body.toString(),
      request: Request(
        headers: response.request!.headers,
        method: response.request!.method,
        url: response.request!.url,
      ),
      headers: response.headers,
      statusCode: response.statusCode,
      statusText: response.reasonPhrase,
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

    debugPrint('====> API Response: [${response0.statusCode}] $uri');
    if (!ResponsiveHelper.isWeb() || response.statusCode != 500) {
      // debugPrint('${response0.body}');
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
}

class MultipartBody {
  MultipartBody(this.key, this.file);

  String key;
  XFile? file;
}
