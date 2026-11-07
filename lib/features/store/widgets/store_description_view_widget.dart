import 'package:friday_sa/features/store/controllers/store_controller.dart';
import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/features/favourite/controllers/favourite_controller.dart';
import 'package:friday_sa/features/address/domain/models/address_model.dart';
import 'package:friday_sa/features/store/domain/models/store_model.dart';
import 'package:friday_sa/helper/auth_helper.dart';
import 'package:friday_sa/helper/price_converter.dart';
import 'package:friday_sa/helper/responsive_helper.dart';
import 'package:friday_sa/helper/route_helper.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/styles.dart';
import 'package:friday_sa/common/widgets/custom_image.dart';
import 'package:friday_sa/common/widgets/custom_snackbar.dart';
import 'package:friday_sa/helper/free_delivery_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/helper/string_extension.dart';

class StoreDescriptionViewWidget extends StatelessWidget {
  const StoreDescriptionViewWidget({super.key, required this.store});
  final Store? store;

  @override
  Widget build(BuildContext context) {
    bool isAvailable = Get.find<StoreController>().isStoreOpenNow(
      store!.active!,
      store!.schedules,
    );
    Color? textColor = ResponsiveHelper.isDesktop(context)
        ? Colors.white
        : null;


    if (ResponsiveHelper.isDesktop(context)) {
      return Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: Stack(
              children: [
                CustomImage(
                  image: '${store!.logoFullUrl}',
                  height: 140,
                  width: 140,
                  fit: BoxFit.cover,
                ),
                if (!isAvailable)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(Dimensions.radiusSmall),
                        ),
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                      child: Text(
                        'closed_now'.tr,
                        textAlign: TextAlign.center,
                        style: robotoRegular.copyWith(
                          color: Colors.white,
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              store!.name!,
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeExtraLarge,
                                color: textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (store!.featured == 1) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.stars,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    GetBuilder<FavouriteController>(
                      builder: (favouriteController) {
                        bool isWished = favouriteController.wishStoreIdList
                            .contains(store!.id);
                        return InkWell(
                          onTap: () {
                            if (AuthHelper.isLoggedIn()) {
                              isWished
                                  ? favouriteController.removeFromFavouriteList(
                                      store!.id,
                                      true,
                                    )
                                  : favouriteController.addToFavouriteList(
                                      null,
                                      store?.id,
                                      true,
                                    );
                            } else {
                              showCustomSnackBar('you_are_not_logged_in'.tr);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(
                              Dimensions.paddingSizeExtraSmall,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusSmall,
                              ),
                              border: Border.all(color: Colors.white),
                            ),
                            child: Center(
                              child: Row(
                                children: [
                                  Icon(
                                    isWished
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(
                                    width: Dimensions.paddingSizeExtraSmall,
                                  ),
                                  Text(
                                    'wish_list'.tr,
                                    style: robotoRegular.copyWith(
                                      fontWeight: FontWeight.w200,
                                      color: Colors.white,
                                      fontSize: Dimensions.fontSizeSmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Text(
                  store!.address ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).disabledColor,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (store!.delivery ?? false)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.delivery_dining_outlined,
                              color: Colors.green.shade900,
                              size: 12,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'home_delivery'.tr,
                              style: robotoBold.copyWith(
                                fontSize: 11,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (store!.takeAway ?? false)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.green.shade900,
                              size: 12,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'pickup'.tr,
                              style: robotoBold.copyWith(
                                fontSize: 11,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_offer_outlined,
                            color: Colors.green.shade900,
                            size: 12,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'in_store_price'.tr,
                            style: robotoBold.copyWith(
                              fontSize: 11,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Row(
                  children: [
                    Text(
                      'minimum_order_amount'.tr,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text(
                      PriceConverter.convertPrice(store!.minimumOrder),
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Mobile View - Proper Floating Design
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Content Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 55, 16, 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      store!.name!,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeExtraLarge,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (store!.featured == 1) ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.stars,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                  ],
                  const SizedBox(width: 8),
                  GetBuilder<FavouriteController>(
                    builder: (favouriteController) {
                      bool isWished = favouriteController.wishStoreIdList
                          .contains(store!.id);
                      return InkWell(
                        onTap: () {
                          if (AuthHelper.isLoggedIn()) {
                            isWished
                                ? favouriteController.removeFromFavouriteList(
                                    store!.id,
                                    true,
                                  )
                                : favouriteController.addToFavouriteList(
                                    null,
                                    store?.id,
                                    true,
                                  );
                          } else {
                            showCustomSnackBar('you_are_not_logged_in'.tr);
                          }
                        },
                        child: Icon(
                          isWished ? Icons.favorite : Icons.favorite_border,
                          size: 24,
                          color: isWished
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).disabledColor,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),

              if (store!.address != null)
                Text(
                  store!.address!,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).disabledColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (store!.delivery ?? false)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delivery_dining_outlined,
                            color: Colors.green.shade900,
                            size: 12,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'home_delivery'.tr,
                            style: robotoBold.copyWith(
                              fontSize: 11,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (store!.takeAway ?? false)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.green.shade900,
                            size: 12,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'pickup'.tr,
                            style: robotoBold.copyWith(
                              fontSize: 11,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_offer_outlined,
                          color: Colors.green.shade900,
                          size: 12,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'in_store_price'.tr,
                          style: robotoBold.copyWith(
                            fontSize: 11,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoItem(
                    context,
                    Icons.star_rounded,
                    store!.avgRating!.toStringAsFixed(1),
                    '${store!.ratingCount}+ ${'ratings'.tr}',
                  ),
                  _buildVerticalDivider(context),
                  _buildInfoItem(
                    context,
                    Icons.location_on_rounded,
                    'location'.tr,
                    'view'.tr,
                    onTap: () {
                      Get.toNamed(
                        RouteHelper.getMapRoute(
                          AddressModel(
                            id: store!.id,
                            address: store!.address,
                            latitude: store!.latitude,
                            longitude: store!.longitude,
                            contactPersonNumber: '',
                            contactPersonName: '',
                            addressType: '',
                          ),
                          'store',
                          Get.find<SplashController>()
                              .getModuleConfig(
                                Get.find<SplashController>().module!.moduleType,
                              )
                              .newVariation!,
                          storeName: store!.name,
                        ),
                      );
                    },
                  ),
                  _buildVerticalDivider(context),
                  _buildInfoItem(
                    context,
                    Icons.access_time_rounded,
                    store!.deliveryTime!.deliveryTimeTr,
                    'delivery'.tr,
                  ),
                ],
              ),

              if (FreeDeliveryHelper.isFreeDelivery(store))
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.delivery_dining_rounded,
                          color: Theme.of(context).primaryColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'free_delivery'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Floating Logo
        Positioned(
          top: -65,
          child: Container(
            height: 90,
            width: 90,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: CustomImage(
                image: '${store!.logoFullUrl}',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(BuildContext context) {
    return Container(
      height: 30,
      width: 1,
      color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String title,
    String subTitle, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 20),
            const SizedBox(height: 4),
            Text(
              title,
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
            ),
            Text(
              subTitle,
              style: robotoRegular.copyWith(
                fontSize: 10,
                color: Theme.of(context).disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
