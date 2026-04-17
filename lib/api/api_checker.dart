import 'package:friday_sa/common/widgets/network_error_dialog.dart';
import 'package:friday_sa/features/favourite/controllers/favourite_controller.dart';
import 'package:friday_sa/features/auth/controllers/auth_controller.dart';
import 'package:friday_sa/helper/route_helper.dart';
import 'package:friday_sa/common/widgets/custom_snackbar.dart';
import 'package:get/get.dart';

class ApiChecker {
  static void checkApi(Response response, {bool getXSnackBar = false, int? duration}) {
    if (response.statusCode == 401) {
      Get.find<AuthController>().clearSharedData(removeToken: false).then((
        value,
      ) {
        Get.find<FavouriteController>().removeFavourite();
        Get.offAllNamed(RouteHelper.getInitialRoute());
      });
    } else if (response.statusCode == 1 || response.statusCode == 0) {
      // No Internet
      if (!Get.isDialogOpen!) {
        Get.dialog(const NetworkErrorDialog(isSlowInternet: false), barrierDismissible: false);
      }
    } else if (duration != null && duration > 10000) {
      // Slow Internet (Greater than 10 seconds)
      if (!Get.isDialogOpen!) {
        Get.dialog(const NetworkErrorDialog(isSlowInternet: true), barrierDismissible: true);
      }
    } else {
      if (response.statusText != 'The guest id field is required.') {
        showCustomSnackBar(response.statusText, getXSnackBar: getXSnackBar);
      }
    }
  }
}
