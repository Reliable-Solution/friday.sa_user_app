import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/api/api_client.dart';
import 'package:friday_sa/features/address/domain/models/address_model.dart';
import 'package:friday_sa/util/app_constants.dart';


class AddressHelper {
  static Future<bool> saveUserAddressInSharedPref(AddressModel address) async {
    SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
    String userAddress = jsonEncode(address.toJson());
    Get.find<ApiClient>().updateHeader(
      sharedPreferences.getString(AppConstants.token),
      address.zoneIds,
      [],
      sharedPreferences.getString(AppConstants.languageCode),
      Get.find<SplashController>().module?.id,
      address.latitude,
      address.longitude,
    );
    return sharedPreferences.setString(AppConstants.userAddress, userAddress);
  }

  static AddressModel? getUserAddressFromSharedPref() {
    try {
      SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
      AddressModel? addressModel;
      String? addressString = sharedPreferences.getString(
        AppConstants.userAddress,
      );
      if (addressString != null && addressString.isNotEmpty) {
        addressModel = AddressModel.fromJson(jsonDecode(addressString));
      }
      return addressModel;
    } catch (e) {
      if (!GetPlatform.isWeb) {
        debugPrint('Address Catch exception: $e');
      }
      return null;
    }
  }

  static bool clearAddressFromSharedPref() {
    SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
    sharedPreferences.remove(AppConstants.userAddress);
    return true;
  }
}
