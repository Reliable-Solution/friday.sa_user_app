import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/features/home/widgets/filter_view.dart';
import 'package:friday_sa/features/home/widgets/store_filter_button_widget.dart';
import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/features/store/controllers/store_controller.dart';
import 'package:friday_sa/helper/responsive_helper.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/styles.dart';

class AllStoreFilterWidget extends StatelessWidget {
  const AllStoreFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(
      builder: (storeController) {
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: Dimensions.webMaxWidth,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
            padding: const EdgeInsets.only(top: 0, bottom: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText! ? 'restaurants'.tr : 'stores'.tr,
                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                        ),
                        Text(
                          '${storeController.storeModel?.totalSize ?? 0} ${Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText! ? 'restaurants_near_you'.tr : 'stores_near_you'.tr}',
                          style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeExtraSmall),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              filter(context, storeController),
            ],
          ),
        ),
        );
      },
    );
  }

  Widget filter(BuildContext context, StoreController storeController) {
    return SizedBox(
      height: ResponsiveHelper.isDesktop(context) ? 45 : 40,
      child: Align(
        alignment: Alignment.centerLeft,
        child: ListView(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          children: [
            ResponsiveHelper.isDesktop(context) ? const SizedBox() : FilterView(storeController: storeController),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            StoreFilterButtonWidget(
              buttonText: 'all'.tr,
              onTap: () => storeController.setStoreType('all'),
              isSelected: storeController.storeType == 'all',
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            StoreFilterButtonWidget(
              buttonText: 'newly_joined'.tr,
              onTap: () => storeController.setStoreType('newly_joined'),
              isSelected: storeController.storeType == 'newly_joined',
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            StoreFilterButtonWidget(
              buttonText: 'popular'.tr,
              onTap: () => storeController.setStoreType('popular'),
              isSelected: storeController.storeType == 'popular',
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            StoreFilterButtonWidget(
              buttonText: 'top_rated'.tr,
              onTap: () => storeController.setStoreType('top_rated'),
              isSelected: storeController.storeType == 'top_rated',
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            ResponsiveHelper.isDesktop(context) ? FilterView(storeController: storeController) : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
