import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/helper/free_delivery_helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:friday_sa/common/widgets/custom_ink_well.dart';
import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/features/store/controllers/store_controller.dart';
import 'package:friday_sa/features/favourite/controllers/favourite_controller.dart';
import 'package:friday_sa/common/models/module_model.dart';
import 'package:friday_sa/features/store/domain/models/store_model.dart';
import 'package:friday_sa/helper/auth_helper.dart';
import 'package:friday_sa/helper/route_helper.dart';
import 'package:friday_sa/util/styles.dart';
import 'package:friday_sa/common/widgets/custom_image.dart';
import 'package:friday_sa/common/widgets/custom_snackbar.dart';
import 'package:friday_sa/common/widgets/discount_tag.dart';
import 'package:friday_sa/common/widgets/not_available_widget.dart';
import 'package:friday_sa/features/store/screens/store_screen.dart';
import 'package:friday_sa/helper/string_extension.dart';

class StoreCard extends StatelessWidget {
  const StoreCard({super.key, required this.store, this.isTopOffers = false});
  final Store store;
  final bool? isTopOffers;

  @override
  Widget build(BuildContext context) {
    num distance = store.distance != null
        ? (store.distance! / 1000)
        : Get.find<StoreController>().getRestaurantDistance(
            LatLng(
              double.parse(store.latitude!),
              double.parse(store.longitude!),
            ),
          );
    String currencySymbol =
        Get.find<SplashController>().configModel!.currencySymbol!;

    return Container(
      width: 300,
      height: 110,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomInkWell(
        onTap: () {
          if (store.open == 0 || store.active == false) {
            showCustomSnackBar('this_store_is_closed_now'.tr);
          } else {
            if (Get.find<SplashController>().moduleList != null) {
              for (ModuleModel module
                  in Get.find<SplashController>().moduleList!) {
                if (module.id == store.moduleId) {
                  Get.find<SplashController>().setModule(module);
                  break;
                }
              }
            }
            Get.toNamed(
              RouteHelper.getStoreRoute(id: store.id, page: 'store'),
              arguments: StoreScreen(store: store, fromModule: false),
            );
          }
        },
        radius: 16,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Minimal stacked image container (Cover Image + Floating circular Logo/Icon + Discount Tag)
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background Cover Image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: CustomImage(
                        image: '${store.coverPhotoFullUrl}',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (isTopOffers == null || !isTopOffers!)
                    DiscountTag(
                      discount: Get.find<StoreController>().getDiscount(store),
                      discountType: Get.find<StoreController>().getDiscountType(
                        store,
                      ),
                      freeDelivery: false,
                      fontSize: 8,
                    ),
                  if (!Get.find<StoreController>().isOpenNow(store))
                    const NotAvailableWidget(
                      isStore: true,
                      fontSize: 8,
                      radius: 11,
                    ),

                  // Floating circular Store Logo/Icon overlapping bottom-right
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            spreadRadius: 0,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(1.5),
                      child: ClipOval(
                        child: CustomImage(
                          image: '${store.logoFullUrl}',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Store Name and PLUS badge row
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  store.name ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: robotoBold.copyWith(
                                    fontSize: 15,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                              if (store.featured == 1) ...[
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.stars,
                                  color: Theme.of(context).primaryColor,
                                  size: 18,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),

                    // Ratings & Chips Wrap (Highly responsive, zero overflow, minimalistic bullet dots)
                    Wrap(
                      spacing: 3,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 13,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${store.avgRating?.toStringAsFixed(1) ?? '0.0'} (${store.ratingCount ?? '0'})',
                              style: robotoBold.copyWith(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '•',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                        if (store.delivery ?? false) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.delivery_dining_outlined,
                                  color: Theme.of(context).primaryColor,
                                  size: 12,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'home_delivery'.tr,
                                  style: robotoBold.copyWith(
                                    fontSize: 11,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '•',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (store.takeAway ?? false) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.yellow.shade200,
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
                          Text(
                            '•',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (FreeDeliveryHelper.isFreeDelivery(store)) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.local_shipping,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'free_delivery'.tr,
                                  style: robotoBold.copyWith(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '•',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                            ),
                          ),
                        ],
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
                        if ((Get.find<StoreController>().getDiscount(store) ?? 0) > 0) ...[
                          Text(
                            '•',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.card_giftcard_outlined,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'COUPON',
                                  style: robotoBold.copyWith(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),

                    // Bottom Delivery Specs Wrap (Sleek and extremely elegant layout)
                    Wrap(
                      spacing: 3,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_outlined,
                              color: Colors.grey.shade600,
                              size: 13,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              (store.deliveryTime ?? '30-45 mins').deliveryTimeTr,
                              style: robotoMedium.copyWith(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '•',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: Colors.grey.shade600,
                              size: 13,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${distance.toStringAsFixed(1)} ${'km'.tr}',
                              style: robotoMedium.copyWith(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '•',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                        // Row(
                        //   mainAxisSize: MainAxisSize.min,
                        //   children: [
                        //     Icon(
                        //       Icons.directions_car_outlined,
                        //       color: FreeDeliveryHelper.isFreeDelivery(store)
                        //           ? Colors.green.shade600
                        //           : Colors.grey.shade600,
                        //       size: 13,
                        //     ),
                        //     const SizedBox(width: 2),
                        //     Text(
                        //       FreeDeliveryHelper.isFreeDelivery(store)
                        //           ? 'free'.tr
                        //           : '$currencySymbol ${store.minimumShippingCharge?.toStringAsFixed(0) ?? '0'}',
                        //       style: FreeDeliveryHelper.isFreeDelivery(store)
                        //           ? robotoBold.copyWith(
                        //               fontSize: 11,
                        //               color: Colors.green.shade600,
                        //             )
                        //           : robotoMedium.copyWith(
                        //               fontSize: 11,
                        //               color: Colors.grey.shade700,
                        //             ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Wishlist Heart Icon placed beautifully at the trailing end of the card
              GetBuilder<FavouriteController>(
                builder: (favouriteController) {
                  bool isWished = favouriteController.wishStoreIdList.contains(
                    store.id,
                  );
                  return InkWell(
                    onTap: () {
                      if (AuthHelper.isLoggedIn()) {
                        isWished
                            ? favouriteController.removeFromFavouriteList(
                                store.id,
                                true,
                              )
                            : favouriteController.addToFavouriteList(
                                null,
                                store.id,
                                true,
                              );
                      } else {
                        showCustomSnackBar('you_are_not_logged_in'.tr);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        isWished ? Icons.favorite : Icons.favorite_border,
                        size: 22,
                        color: isWished ? Theme.of(context).primaryColor : Colors.grey.shade400,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
