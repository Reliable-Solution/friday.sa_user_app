import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/helper/free_delivery_helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:friday_sa/common/widgets/card_design/store_card.dart';
import 'package:friday_sa/common/widgets/card_design/store_card_with_distance.dart';
import 'package:friday_sa/common/widgets/custom_ink_well.dart';
import 'package:friday_sa/features/language/controllers/language_controller.dart';
import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/features/store/controllers/store_controller.dart';
import 'package:friday_sa/features/favourite/controllers/favourite_controller.dart';
import 'package:friday_sa/common/models/module_model.dart';
import 'package:friday_sa/features/store/domain/models/store_model.dart';
import 'package:friday_sa/helper/auth_helper.dart';
import 'package:friday_sa/helper/price_converter.dart';
import 'package:friday_sa/helper/route_helper.dart';
import 'package:friday_sa/util/app_constants.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/images.dart';
import 'package:friday_sa/util/styles.dart';
import 'package:friday_sa/common/widgets/custom_image.dart';
import 'package:friday_sa/common/widgets/custom_snackbar.dart';
import 'package:friday_sa/common/widgets/discount_tag.dart';
import 'package:friday_sa/common/widgets/rating_bar.dart';
import 'package:friday_sa/common/widgets/title_widget.dart';
import 'package:friday_sa/features/store/screens/store_screen.dart';

import '../../../../common/widgets/not_available_widget.dart';



class BestStoreNearbyView extends StatelessWidget {
  const BestStoreNearbyView({super.key});


  @override
  Widget build(BuildContext context) {
    bool isPharmacy =
        Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString() ==
            AppConstants.pharmacy;
    bool isFood =
        Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString() ==
            AppConstants.food;
    final bool ltr = Get.find<LocalizationController>().isLtr;

    return GetBuilder<StoreController>(
      builder: (storeController) {
        List<Store>? dummmy = isPharmacy
            ? storeController.featuredStoreList
            : storeController.popularStoreList;

        final storeList = dummmy
            ?.where(
              (e) => e.moduleId == Get.find<SplashController>().module?.id,
            )
            .toList();

        return storeList != null
            ? storeList.isNotEmpty
                  ? Padding(
                        padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeDefault,
                      ),
                      child: Container(
                        color: isPharmacy
                            ? null
                            : Theme.of(
                                context,
                              ).disabledColor.withValues(alpha: 0.1),
                        child: Column(
                          children: [
                            (isPharmacy || isFood)
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                      top: Dimensions.paddingSizeDefault,
                                      left: Dimensions.paddingSizeDefault,
                                      right: Dimensions.paddingSizeDefault,
                                    ),
                                    child: TitleWidget(
                                      title: isPharmacy
                                          ? 'featured_store'.tr
                                          : 'best_store_nearby'.tr,
                                      onTap: () => Get.toNamed(
                                        RouteHelper.getAllStoreRoute(
                                          isPharmacy ? 'featured' : 'popular',
                                          isNearbyStore: true,
                                        ),
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: EdgeInsets.only(
                                      top: Dimensions.paddingSizeDefault,
                                      left: ltr
                                          ? Dimensions.paddingSizeLarge
                                          : Dimensions.paddingSizeDefault,
                                      right: ltr
                                          ? Dimensions.paddingSizeDefault
                                          : Dimensions.paddingSizeLarge,
                                    ),
                                    child: FittedBox(
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 2,
                                            width: context.width * 0.75,
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withValues(alpha: 0.4),
                                          ),
                                          Container(
                                            // transform:
                                            //     Matrix4.translationValues(
                                            //       -2,
                                            //       0,
                                            //       0,
                                            //     ),
                                            child: Icon(
                                              Icons.arrow_forward,
                                              size: 18,
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withValues(alpha: 0.5),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () => Get.toNamed(
                                              RouteHelper.getAllStoreRoute(
                                                'popular',
                                                isNearbyStore: true,
                                              ),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                ltr ? 10 : 0,
                                                5,
                                                ltr ? 0 : 10,
                                                5,
                                              ),
                                              child: Text(
                                                'see_all'.tr,
                                                style: robotoMedium.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeSmall,
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColor,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            isPharmacy
                                ? SizedBox(
                                    height: 130,
                                    width: Get.width,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      padding: const EdgeInsets.only(
                                        left: Dimensions.paddingSizeDefault,
                                      ),
                                      itemCount: storeList.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right:
                                                Dimensions.paddingSizeDefault,
                                            top: Dimensions.paddingSizeDefault,
                                            bottom: Dimensions
                                                .paddingSizeExtraSmall,
                                          ),
                                          child: StoreCard(
                                            store: storeList[index],
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : isFood
                                ? SizedBox(
                                    height: 215,
                                    child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.only(
                                        top: Dimensions.paddingSizeDefault,
                                        bottom: Dimensions.paddingSizeDefault,
                                      ),
                                      itemCount: storeList.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                Dimensions.paddingSizeSmall,
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              if (storeList[index].open == 0 ||
                                                  storeList[index].active ==
                                                      false) {
                                                showCustomSnackBar(
                                                  'this_store_is_closed_now'.tr,
                                                );
                                              } else {
                                                if (Get.find<SplashController>()
                                                        .moduleList !=
                                                    null) {
                                                  for (ModuleModel module
                                                      in Get.find<
                                                            SplashController
                                                          >()
                                                          .moduleList!) {
                                                    if (module.id ==
                                                        storeList[index]
                                                            .moduleId) {
                                                      Get.find<
                                                              SplashController>()
                                                          .setModule(module);
                                                      break;
                                                    }
                                                  }
                                                }
                                                Get.toNamed(
                                                  RouteHelper.getStoreRoute(
                                                    id: storeList[index].id,
                                                    page: 'store',
                                                  ),
                                                  arguments: StoreScreen(
                                                    store: storeList[index],
                                                    fromModule: true,
                                                  ),
                                                );
                                              }
                                            },
                                            child: StoreCardWithDistance(
                                              store: storeList[index],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : SizedBox(
                                    height: 195,
                                    width: Get.width,
                                    child: Row(
                                      children: [
                                        const SizedBox(width: Dimensions.paddingSizeDefault),
                                        RotatedBox(
                                          quarterTurns: 3,
                                          child: Text(
                                            (storeList != null && storeList.isNotEmpty && storeList.every((e) => e.open == 0)) ? 'closed'.tr : 'best_store_nearby'.tr,
                                            style: robotoBold.copyWith(
                                              fontSize: Dimensions.fontSizeLarge,
                                              color: (storeList != null && storeList.isNotEmpty && storeList.every((e) => e.open == 0)) ? Theme.of(context).colorScheme.error : Theme.of(context).primaryColor,
                                            ),
                                          ),
                                        ),
                                         Expanded(
                                           child: ListView.builder(
                                             scrollDirection: Axis.horizontal,
                                             physics: const BouncingScrollPhysics(),
                                             clipBehavior: Clip.none,
                                             padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                                             itemCount: storeList.length,
                                             itemBuilder: (context, index) {
                                              num distance = Get.find<StoreController>().getRestaurantDistance(
                                                LatLng(double.parse(storeList[index].latitude!), double.parse(storeList[index].longitude!)),
                                              );
                                               return Padding(
                                                 padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault, top: 25, bottom: 5),
                                                 child: Stack(
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        if (storeList[index].open == 0 || storeList[index].active == false) {
                                                          showCustomSnackBar('this_store_is_closed_now'.tr);
                                                        } else {
                                                          Get.toNamed(
                                                            RouteHelper.getStoreRoute(id: storeList[index].id, page: 'store'),
                                                            arguments: StoreScreen(store: storeList[index], fromModule: true),
                                                          );
                                                        }
                                                      },
                                                      child: Container(
                                                        width: 180,
                                                        padding: const EdgeInsets.fromLTRB(10, 35, 10, 10),
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context).cardColor,
                                                        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black.withValues(alpha: 0.05),
                                                            blurRadius: 10,
                                                            offset: const Offset(0, 5),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            storeList[index].name ?? '',
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                          const SizedBox(height: 5),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Icon(Icons.star, size: 14, color: Theme.of(context).primaryColor),
                                                              const SizedBox(width: 2),
                                                              Text(
                                                                storeList[index].avgRating!.toStringAsFixed(1),
                                                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                                              ),
                                                            ],
                                                          ),
                                                            const SizedBox(height: 4),
                                                            Text(
                                                              '${distance > 10 ? '10+' : distance.toStringAsFixed(1)} ${'km'.tr} ${'from_you'.tr}',
                                                              style: robotoRegular.copyWith(color: Theme.of(context).primaryColor, fontSize: 10),
                                                            ),
                                                            if (FreeDeliveryHelper.isFreeDelivery(storeList[index]))
                                                              Padding(
                                                                padding: const EdgeInsets.only(top: 2),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    Icon(Icons.check_circle, size: 12, color: Theme.of(context).primaryColor),
                                                                    const SizedBox(width: 2),
                                                                    Text('free_delivery'.tr, style: robotoMedium.copyWith(fontSize: 9, color: Theme.of(context).primaryColor)),
                                                                  ],
                                                                ),
                                                              ),
                                                            const SizedBox(height: 8),
                                                            Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                              decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(50)),
                                                              child: Text('visit_now'.tr, style: robotoMedium.copyWith(fontSize: 10, color: Theme.of(context).primaryColor)),
                                                            ),
                                                        ],
                                                      ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: -25,
                                                      left: 0,
                                                      right: 0,
                                                      child: Center(
                                                        child: Stack(
                                                          children: [
                                                            Container(
                                                              height: 70,
                                                              width: 70,
                                                              decoration: BoxDecoration(
                                                                color: Theme.of(context).cardColor,
                                                                shape: BoxShape.circle,
                                                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
                                                              ),
                                                              child: ClipOval(child: CustomImage(image: '${storeList[index].logoFullUrl}', fit: BoxFit.cover)),
                                                            ),
                                                            (storeList[index].open == 0 || !storeList[index].active!)
                                                                ? Positioned.fill(
                                                                    child: Container(
                                                                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                                                                      child: Center(child: Text('closed'.tr, style: robotoMedium.copyWith(color: Colors.white, fontSize: 10))),
                                                                    ),
                                                                  )
                                                                : const SizedBox(),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 5,
                                                      right: 5,
                                                      child: GetBuilder<FavouriteController>(builder: (favouriteController) {
                                                        bool isWished = favouriteController.wishStoreIdList.contains(storeList[index].id);
                                                        return InkWell(
                                                          onTap: () {
                                                            if (AuthHelper.isLoggedIn()) {
                                                              isWished ? favouriteController.removeFromFavouriteList(storeList[index].id, true) : favouriteController.addToFavouriteList(null, storeList[index].id, true);
                                                            } else {
                                                              showCustomSnackBar('you_are_not_logged_in'.tr);
                                                            }
                                                          },
                                                          child: Icon(isWished ? Icons.favorite : Icons.favorite_border, color: isWished ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, size: 20),
                                                        );
                                                      }),
                                                    ),
                                                    DiscountTag(
                                                      discount: storeController.getDiscount(storeList[index]),
                                                      discountType: storeController.getDiscountType(storeList[index]),
                                                      fontSize: 10,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox()
            : BestStoreNearbyShimmer(isPharmacy: isPharmacy, isFood: isFood);
      },
    );
  }
}

class BestStoreNearbyShimmer extends StatelessWidget {
  const BestStoreNearbyShimmer({
    super.key,
    required this.isPharmacy,
    required this.isFood,
  });
  final bool isPharmacy;
  final bool isFood;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        (isPharmacy || isFood)
            ? Padding(
                padding: const EdgeInsets.only(
                  top: Dimensions.paddingSizeDefault,
                  left: Dimensions.paddingSizeDefault,
                  right: Dimensions.paddingSizeDefault,
                ),
                child: TitleWidget(
                  title: isPharmacy
                      ? 'featured_store'.tr
                      : 'best_store_nearby'.tr,
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(
                  top: Dimensions.paddingSizeDefault,
                  left: Dimensions.paddingSizeLarge,
                  right: Dimensions.paddingSizeDefault,
                ),
                child: FittedBox(
                  child: Row(
                    children: [
                      Container(
                        height: 2,
                        width: context.width * 0.75,
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.2),
                      ),
                      Container(
                        transform: Matrix4.translationValues(-5, 0, 0),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 18,
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.5),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
                        child: Text(
                          'see_all'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        isPharmacy
            ? SizedBox(
                height: 130,
                width: Get.width,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(
                    bottom: Dimensions.paddingSizeExtraSmall,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeDefault,
                        top: Dimensions.paddingSizeSmall,
                      ),
                      child: Shimmer(
                        duration: const Duration(seconds: 2),
                        enabled: true,
                        child: Container(
                          width: 300,
                          padding: const EdgeInsets.all(
                            Dimensions.paddingSizeSmall,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusDefault,
                            ),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        Dimensions.radiusSmall,
                                      ),
                                      child: Container(
                                        height: 50,
                                        width: 50,
                                        color: Theme.of(context).cardColor,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: Dimensions.paddingSizeSmall,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 10,
                                            width: 100,
                                            color: Theme.of(context).cardColor,
                                          ),
                                          const SizedBox(
                                            height: Dimensions
                                                .paddingSizeExtraSmall,
                                          ),
                                          !isPharmacy
                                              ? const RatingBar(
                                                  rating: 0,
                                                  ratingCount: 0,
                                                  size: 12,
                                                )
                                              : Row(
                                                  children: [
                                                    Icon(
                                                      Icons.storefront,
                                                      size: 15,
                                                      color: Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                    ),
                                                    const SizedBox(
                                                      width: Dimensions
                                                          .paddingSizeExtraSmall,
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        height: 10,
                                                        width: 100,
                                                        color: Theme.of(
                                                          context,
                                                        ).cardColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          const SizedBox(
                                            height: Dimensions
                                                .paddingSizeExtraSmall,
                                          ),
                                          !isPharmacy
                                              ? Row(
                                                  children: [
                                                    Icon(
                                                      Icons.storefront,
                                                      size: 15,
                                                      color: Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                    ),
                                                    const SizedBox(
                                                      width: Dimensions
                                                          .paddingSizeExtraSmall,
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        height: 10,
                                                        width: 100,
                                                        color: Theme.of(
                                                          context,
                                                        ).cardColor,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Container(
                                                  height: 10,
                                                  width: 100,
                                                  color: Theme.of(
                                                    context,
                                                  ).cardColor,
                                                ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions.paddingSizeSmall,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).primaryColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(
                                          Dimensions.radiusExtraLarge,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            Images.distanceLine,
                                            height: 15,
                                            width: 15,
                                          ),
                                          const SizedBox(
                                            width: Dimensions
                                                .paddingSizeExtraSmall,
                                          ),
                                          Container(
                                            height: 10,
                                            width: 50,
                                            color: Theme.of(context).cardColor,
                                          ),
                                          const SizedBox(
                                            width: Dimensions
                                                .paddingSizeExtraSmall,
                                          ),
                                          Container(
                                            height: 10,
                                            width: 50,
                                            color: Theme.of(context).cardColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions.paddingSizeSmall,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(
                                          Dimensions.radiusExtraLarge,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            Images.clockIcon,
                                            height: 15,
                                            width: 15,
                                          ),
                                          const SizedBox(
                                            width: Dimensions
                                                .paddingSizeExtraSmall,
                                          ),
                                          Container(
                                            height: 10,
                                            width: 50,
                                            color: Theme.of(context).cardColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            : isFood
            ? SizedBox(
                height: 215,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(
                    top: Dimensions.paddingSizeDefault,
                    bottom: Dimensions.paddingSizeDefault,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall,
                      ),
                      child: Stack(
                        children: [
                          Shimmer(
                            duration: const Duration(seconds: 2),
                            enabled: true,
                            child: Container(
                              width: 260,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusDefault,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(
                                          Dimensions.radiusDefault,
                                        ),
                                        topRight: Radius.circular(
                                          Dimensions.radiusDefault,
                                        ),
                                      ),
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            height: double.infinity,
                                            width: double.infinity,
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withValues(alpha: 0.1),
                                          ),
                                          Positioned(
                                            top: 15,
                                            right: 15,
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Theme.of(context)
                                                    .cardColor
                                                    .withValues(alpha: 0.8),
                                              ),
                                              child: Icon(
                                                Icons.favorite_border,
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 95,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    height: 5,
                                                    width: 100,
                                                    color: Theme.of(
                                                      context,
                                                    ).cardColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .location_on_outlined,
                                                      color: Colors.blue,
                                                      size: 15,
                                                    ),
                                                    const SizedBox(
                                                      width: Dimensions
                                                          .paddingSizeExtraSmall,
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        height: 10,
                                                        width: 100,
                                                        color: Theme.of(
                                                          context,
                                                        ).cardColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  Dimensions.paddingSizeDefault,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  height: 10,
                                                  width: 70,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 3,
                                                        horizontal: Dimensions
                                                            .paddingSizeSmall,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .primaryColor
                                                        .withValues(alpha: 0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          Dimensions
                                                              .radiusLarge,
                                                        ),
                                                  ),
                                                ),
                                                Container(
                                                  height: 20,
                                                  width: 65,
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(
                                                      context,
                                                    ).cardColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          Dimensions
                                                              .radiusSmall,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 60,
                            left: 15,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  height: 65,
                                  width: 65,
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            : SizedBox(
                height: 160,
                width: Get.width,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  clipBehavior: Clip.none,
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault, top: 25, bottom: 10),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Shimmer(
                            duration: const Duration(seconds: 2),
                            enabled: true,
                            child: Container(
                              width: 180,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -25,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Shimmer(
                                duration: const Duration(seconds: 2),
                                enabled: true,
                                child: Container(
                                  height: 70,
                                  width: 70,
                                  decoration: const BoxDecoration(
                                    color: Colors.white24,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }
}
