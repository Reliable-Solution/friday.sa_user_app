import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/features/store/domain/models/store_model.dart';
import 'package:friday_sa/common/models/config_model.dart';
import 'package:get/get.dart';

class FreeDeliveryHelper {
  static bool isFreeDelivery(Store? store, {num? distance}) {
    if (store == null) return false;
    ConfigModel? configModel = Get.find<SplashController>().configModel;

    bool isFree = false;

    if (store.freeDelivery!) {
      isFree = true;
    } else if (configModel?.adminFreeDelivery?.status == true) {
      if (configModel?.adminFreeDelivery?.type == 'free_delivery_to_all_store') {
        isFree = true;
      } else if (configModel?.adminFreeDelivery?.type == 'free_delivery_by_store' &&
          configModel!.adminFreeDelivery!.storeIds != null &&
          configModel.adminFreeDelivery!.storeIds!.contains(store.id)) {
        isFree = true;
      } else if (configModel?.adminFreeDelivery?.type == 'free_delivery_by_min_km' &&
          configModel!.adminFreeDelivery!.freeDeliveryKm != null &&
          (distance ?? store.distance ?? 0) <= configModel.adminFreeDelivery!.freeDeliveryKm!) {
        isFree = true;
      }
    }

    return isFree;
  }

  static String? getFreeDeliveryOverAmount() {
    ConfigModel? configModel = Get.find<SplashController>().configModel;
    if (configModel?.adminFreeDelivery?.status == true &&
        configModel?.adminFreeDelivery?.type == 'free_delivery_by_order_amount') {
      return configModel?.adminFreeDelivery?.freeDeliveryOver?.toString();
    }
    return null;
  }
}
