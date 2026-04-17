import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:friday_sa/common/models/module_model.dart';
import 'package:friday_sa/features/address/domain/models/address_model.dart';
import 'package:friday_sa/util/app_constants.dart';

class HeaderHelper {
  static Map<String, String> featuredHeader() {
    SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
    AddressModel? addressModel;
    try {
      String? addressString = sharedPreferences.getString(
        AppConstants.userAddress,
      );
      if (addressString != null && addressString.isNotEmpty) {
        addressModel = AddressModel.fromJson(jsonDecode(addressString));
      }
    } catch (_) {}
    int? moduleID;
    if (GetPlatform.isWeb &&
        sharedPreferences.containsKey(AppConstants.moduleId)) {
      try {
        String? moduleString = sharedPreferences.getString(
          AppConstants.moduleId,
        );
        if (moduleString != null && moduleString.isNotEmpty) {
          moduleID = ModuleModel.fromJson(jsonDecode(moduleString)).id;
        }
      } catch (_) {}
    }
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
      AppConstants.zoneId: addressModel?.zoneIds != null
          ? jsonEncode(addressModel?.zoneIds)
          : '',
      AppConstants.localizationKey:
          sharedPreferences.getString(AppConstants.languageCode) ??
          AppConstants.languages[0].languageCode!,
      AppConstants.latitude: addressModel?.latitude != null
          ? jsonEncode(addressModel?.latitude)
          : '',
      AppConstants.longitude: addressModel?.longitude != null
          ? jsonEncode(addressModel?.longitude)
          : '',
      // 'Authorization': 'Bearer $token'
    };
    if (moduleID != null) {
      header[AppConstants.moduleId] = moduleID.toString();
    } else {
      header['null'] = '';
    }
    return header;
  }
}
