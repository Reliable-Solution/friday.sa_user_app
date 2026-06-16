import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/helper/free_delivery_helper.dart';
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

class FavStoreCardWidget extends StatelessWidget {
  final Store store;

  const FavStoreCardWidget({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final num distance = (store.distance ?? 0) / 1000;
    final String currencySymbol =
        Get.find<SplashController>().configModel!.currencySymbol!;
    final bool isFree = FreeDeliveryHelper.isFreeDelivery(store);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
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
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Image Section ──────────────────────────────────────────
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CustomImage(
                        image: '${store.coverPhotoFullUrl}',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  DiscountTag(
                    discount: Get.find<StoreController>().getDiscount(store),
                    discountType:
                        Get.find<StoreController>().getDiscountType(store),
                    freeDelivery: isFree,
                    fontSize: 8,
                  ),
                  if (!Get.find<StoreController>().isOpenNow(store))
                    const NotAvailableWidget(
                        isStore: true, fontSize: 8, radius: 11),
                  // Floating logo badge
                  Positioned(
                    bottom: -3,
                    right: -3,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 4,
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

              // ── Text Section ───────────────────────────────────────────
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            store.name ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoBold.copyWith(
                              fontSize: 16,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              height: 1.1,
                            ),
                          ),
                        ),
                        if (store.featured == 1) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.stars,
                              color: Theme.of(context).primaryColor, size: 17),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),

                    // ── Row 2: Rating + Chips (Wrap — no scroll) ──────────
                    Wrap(
                      spacing: 3,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Rating
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 15),
                            const SizedBox(width: 3),
                            Text(
                              '${store.avgRating?.toStringAsFixed(1) ?? '0.0'} (${store.ratingCount ?? '0'})',
                               style: robotoBold.copyWith(
                                    fontSize: 11, color: Colors.grey.shade700, height: 1.0),
                            ),
                          ],
                        ),

                        // Home delivery chip
                        if (store.delivery ?? false)
                          _Chip(
                            icon: Icons.delivery_dining_outlined,
                            label: 'home_delivery'.tr,
                            bg: Colors.green.shade100,
                            fg: Colors.green.shade900,
                          ),

                        // Pickup chip
                        if (store.takeAway ?? false)
                          _Chip(
                            icon: Icons.shopping_bag_outlined,
                            label: 'pickup'.tr,
                            bg: Colors.yellow.shade100,
                            fg: Colors.green.shade900,
                          ),

                        // Free delivery chip
                        if (isFree)
                          _Chip(
                            icon: Icons.local_shipping_outlined,
                            label: 'free_delivery'.tr,
                            bg: Colors.green.shade600,
                            fg: Colors.white,
                          ),

                        // In-store price chip
                        _Chip(
                          icon: Icons.local_offer_outlined,
                          label: 'in_store'.tr,
                          bg: Colors.blue.shade200,
                          fg: Colors.green.shade900,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // ── Row 3: Delivery time · Distance · Charge ─────────
                    Wrap(
                      spacing: 3,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Delivery time
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time_outlined,
                                color: Colors.grey.shade500, size: 13),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                (store.deliveryTime ?? '30-45 min').deliveryTimeTr,
                                overflow: TextOverflow.ellipsis,
                                style: robotoMedium.copyWith(
                                    fontSize: 9, color: Colors.grey.shade700, height: 1.0),
                              ),
                            ),
                          ],
                        ),

                        // Distance
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on_outlined,
                                color: Colors.grey.shade500, size: 13),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                '${distance.toStringAsFixed(1)} ${'km'.tr}',
                                overflow: TextOverflow.ellipsis,
                                style: robotoMedium.copyWith(
                                    fontSize: 9, color: Colors.grey.shade700, height: 1.0),
                              ),
                            ),
                          ],
                        ),

                        // Delivery charge
                        // Row(
                        //   mainAxisSize: MainAxisSize.min,
                        //   children: [
                        //     Icon(
                        //       Icons.directions_car_outlined,
                        //       color: isFree
                        //           ? Colors.green.shade600
                        //           : Colors.grey.shade500,
                        //       size: 13,
                        //     ),
                        //     const SizedBox(width: 3),
                        //     Flexible(
                        //       child: Text(
                        //         isFree
                        //             ? 'free'.tr
                        //             : '$currencySymbol ${store.minimumShippingCharge?.toStringAsFixed(0) ?? '0'}',
                        //         overflow: TextOverflow.ellipsis,
                        //         style: isFree
                        //             ? robotoBold.copyWith(
                        //                 fontSize: 11, color: Colors.green.shade600, height: 1.0)
                        //             : robotoMedium.copyWith(
                        //                 fontSize: 11, color: Colors.grey.shade700, height: 1.0),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),

              // ── Wishlist Heart ─────────────────────────────────────────
              GetBuilder<FavouriteController>(
                builder: (favouriteController) {
                  final bool isWished =
                      favouriteController.wishStoreIdList.contains(store.id);
                  return InkWell(
                    onTap: () {
                      if (AuthHelper.isLoggedIn()) {
                        isWished
                            ? favouriteController.removeFromFavouriteList(
                                store.id, true)
                            : favouriteController.addToFavouriteList(
                                null, store.id, true);
                      } else {
                        showCustomSnackBar('you_are_not_logged_in'.tr);
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
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

  /// Bullet separator between chips
  static Widget _dot() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text('•',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
      );
}

/// Compact badge chip used inside the card
class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;

  const _Chip({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 14),
          const SizedBox(width: 4),
           Text(label, style: robotoBold.copyWith(fontSize: 11, color: fg, height: 1.0)),
        ],
      ),
    );
  }
}
