import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:friday_sa/features/controller_screen/models/homeModel.dart';

Dio dio = Dio();

class Services {
  Services._();
  static Services helper = Services._();
  Future<HomeModel> postforlist({api}) async {
    log("$api url : ");

    Response response;
    try {
      response = await dio.get(api);
      print("============== responses ${response.data}");
      print("============== responses ${response.statusCode}");

      log("api stratus code : ${response.statusCode}");
      if (response.statusCode == 200) {
        log("$api Response: ${response.data}");
        var responseData = response.data;
        HomeModel m1 = HomeModel.fromJson(responseData);
        return m1;
      } else {
        log("error ->${response.data}");
        throw Exception(response.data.toString());
      }
    } catch (e) {
      log("error -> ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  Future<void> postforlist1({api}) async {
    log("$api url : ");

    Response response;
    try {
      response = await dio.get(api);
      print("============== responses ${response.data}");
      print("============== responses ${response.statusCode}");

      log("Maja ma");
      log("api stratus code : ${response.statusCode}");
      if (response.statusCode == 200) {
        log("$api Response: ${response.data}");
        var responseData = response.data;
        print(
          "============================= API 2 responces ${responseData["entry_id"]}",
        );
      } else {
        log("error ->${response.data}");
        throw Exception(response.data.toString());
      }
    } catch (e) {
      log("error -> ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  Future<HomeModel> postforlist2({api}) async {
    log("$api url : ");

    Response response;
    try {
      response = await dio.get(api);
      print("============== responses ${response.data}");
      print("============== responses ${response.statusCode}");

      log("Maja ma");
      log("api stratus code : ${response.statusCode}");
      if (response.statusCode == 200) {
        log("$api Response: ${response.data}");
        var responseData = response.data;
        HomeModel m1 = HomeModel.fromJson(responseData);
        return m1;
      } else {
        log("error ->${response.data}");
        throw Exception(response.data.toString());
      }
    } catch (e) {
      log("error -> ${e.toString()}");
      throw Exception(e.toString());
    }
  }
}
