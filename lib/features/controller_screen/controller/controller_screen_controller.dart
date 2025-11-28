// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/common/widgets/custom_snackbar.dart';
import 'package:friday_sa/features/controller_screen/models/controller_model.dart';
import 'package:friday_sa/features/controller_screen/models/homeModel.dart';
import 'package:friday_sa/features/controller_screen/repositories/services.dart';
import 'package:friday_sa/features/controller_screen/services/controller_service_interface.dart';
import 'package:friday_sa/features/profile/controllers/profile_controller.dart';

class ControllerController extends GetxController implements GetxService {
  ControllerController({required this.controllerServiceInterface});
  final ControllerServiceInterface controllerServiceInterface;
  String readApi = "https://hihilltech.com/webapi.asmx/feeds";
  String writeApi = "https://hihilltech.com/webapi.asmx/Update";
  List<ControllerData>? controllerList;

  Future<HomeModel?> api1Call({
    required String read,
    required channel,
    required BuildContext context,
  }) async {
    try {
      debugPrint("=============== read $read  $channel");
      HomeModel? data = await Services.helper.postforlist(
        api: "$readApi?api_key=$read&ChannelID=$channel&results=1",
      );
      return data;
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text("Something went wrong: $e"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
    return null;
  }

  Future api2Call({
    required HomeModel? data,
    required BuildContext context,
    required String write,
    required channel,
    required String field3,
    required String field2,
  }) async {
    try {
      await Services.helper.postforlist1(
        api:
            "$writeApi?api_key=$write&ChannelID=$channel&field1=${data?.field1}&field2=$field2&field3=$field3&field4=${data?.field4}&field7=${data?.field7}&field8=${data?.field8}",
      );

      debugPrint("=========================== Api call 2");
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text("Something went wrong: $e"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  Future<void> getController() async {
    controllerList = null;
    update();
    log("${Get.find<ProfileController>().userInfoModel?.toJson()}");
    try {
      List<ControllerData>? data = await controllerServiceInterface
          .getController(
            Get.find<ProfileController>().userInfoModel?.id?.toString() ?? '',
          );
      controllerList = data;
      update();
    } catch (e) {
      controllerList = [];
      update();
      debugPrint(e.toString());
    }
  }

  bool isLoading = false;
  Future<void> addController({
    required String channelId,
    required String readKey,
    required String writeKey,
  }) async {
    isLoading = true;
    update();
    try {
      ControllerData? data = await controllerServiceInterface.addController(
        Get.find<ProfileController>().userInfoModel?.id?.toString() ?? '',
        channelId,
        readKey,
        writeKey,
      );
      debugPrint("${data?.toJson()}");
      if (data != null) {
        controllerList?.add(data);
      }
      isLoading = false;
      update();
    } catch (e) {
      isLoading = false;
      update();
      debugPrint(e.toString());
    }
  }

  bool isDeleteLoading = false;
  int? deleteId;
  Future<void> deleteController(int id) async {
    isDeleteLoading = true;
    deleteId = id;
    update();
    try {
      bool data = await controllerServiceInterface.deleteController(
        id,
        Get.find<ProfileController>().userInfoModel?.id?.toString() ?? '',
      );
      if (data) {
        final list = [...controllerList!];
        list.removeWhere((element) => element.id == id);
        controllerList = list;
        isDeleteLoading = false;
        deleteId = null;
        update();
      }
    } catch (e) {
      isDeleteLoading = false;
      deleteId = null;
      showCustomSnackBar('unableToDeleteThisControllerData'.tr);
      update();
      debugPrint(e.toString());
    }
  }
}
