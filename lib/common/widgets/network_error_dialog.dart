import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/images.dart';
import 'package:friday_sa/util/styles.dart';
import 'package:friday_sa/common/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class NetworkErrorDialog extends StatelessWidget {
  const NetworkErrorDialog({
    super.key,
    required this.isSlowInternet,
    this.onRetry,
  });
  final bool isSlowInternet;
  final Function? onRetry;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: PointerInterceptor(
        child: SizedBox(
          width: 500,
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Image.asset(
                    isSlowInternet ? Images.warning : Images.noInternet,
                    width: 70,
                    height: 70,
                    color: isSlowInternet ? Colors.orange : Theme.of(context).primaryColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge,
                  ),
                  child: Text(
                    isSlowInternet ? 'slow_connection'.tr : 'no_connection'.tr,
                    textAlign: TextAlign.center,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge,
                      color: isSlowInternet ? Colors.orange : Colors.red,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Text(
                    isSlowInternet ? 'it_seems_your_internet_is_slow'.tr : 'no_internet_connection_description'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        buttonText: 'retry'.tr,
                        onPressed: () {
                          Get.back();
                          if (onRetry != null) {
                            onRetry!();
                          }
                        },
                        radius: Dimensions.radiusSmall,
                        height: 50,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
