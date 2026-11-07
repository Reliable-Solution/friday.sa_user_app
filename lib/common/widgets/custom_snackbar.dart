import 'package:friday_sa/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'coustom_toast.dart';

void showCustomSnackBar(
  String? message, {
  bool isError = true,
  bool getXSnackBar = false,
  int? showDuration,
}) {
  if (message != null && message.isNotEmpty) {
    if (getXSnackBar) {
      if (Get.context != null && Overlay.maybeOf(Get.context!) != null) {
        try {
          Get.showSnackbar(
            GetSnackBar(
              backgroundColor: Colors.transparent,
              messageText: CustomToast(text: message, isError: isError),
              maxWidth: 500,
              duration: Duration(seconds: showDuration ?? 3),
              snackStyle: SnackStyle.FLOATING,
              margin: const EdgeInsets.only(
                left: Dimensions.paddingSizeSmall,
                right: Dimensions.paddingSizeSmall,
                bottom: 100,
              ),
              borderRadius: 50,
              isDismissible: true,
              dismissDirection: DismissDirection.horizontal,
            ),
          );
          return;
        } catch (_) {}
      }
    }
    
    // Fallback to standard ScaffoldMessenger
    if (Get.context != null && ScaffoldMessenger.maybeOf(Get.context!) != null) {
      try {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            dismissDirection: DismissDirection.endToStart,
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.zero,
            content: CustomToast(text: message, isError: isError),
            duration: Duration(seconds: showDuration ?? 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (_) {}
    }
  }
}
