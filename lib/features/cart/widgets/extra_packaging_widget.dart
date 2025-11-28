import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/features/cart/controllers/cart_controller.dart';
import 'package:friday_sa/features/store/controllers/store_controller.dart';
import 'package:friday_sa/helper/price_converter.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/styles.dart';

class ExtraPackagingWidget extends StatelessWidget {
  const ExtraPackagingWidget({super.key, required this.cartController});
  final CartController cartController;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(
      builder: (storeController) {
        return storeController.store?.extraPackagingStatus ?? false
            ? Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      activeColor: Theme.of(context).primaryColor,
                      visualDensity: const VisualDensity(
                        horizontal: -4,
                        vertical: -4,
                      ),
                      value: cartController.needExtraPackage,
                      onChanged: (bool? isChecked) {
                        cartController.toggleExtraPackage();
                      },
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text('need_extra_packaging'.tr, style: robotoMedium),
                    const Spacer(),
                    Text(
                      PriceConverter.convertPrice(
                        storeController.store?.extraPackagingAmount,
                      ),
                      style: robotoMedium,
                    ),
                  ],
                ),
              )
            : const SizedBox();
      },
    );
  }
}
