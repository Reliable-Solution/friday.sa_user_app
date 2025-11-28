import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/common/widgets/custom_ink_well.dart';
import 'package:friday_sa/common/widgets/custom_snackbar.dart';
import 'package:friday_sa/common/widgets/hover/text_hover.dart';
import 'package:friday_sa/common/widgets/not_available_widget.dart';
import 'package:friday_sa/features/favourite/controllers/favourite_controller.dart';
import 'package:friday_sa/features/language/controllers/language_controller.dart';
import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/features/store/domain/models/store_model.dart';
import 'package:friday_sa/helper/auth_helper.dart';
import 'package:friday_sa/helper/route_helper.dart';
import 'package:friday_sa/util/app_constants.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/styles.dart';
import 'package:friday_sa/common/widgets/custom_image.dart';
import 'package:friday_sa/features/store/screens/store_screen.dart';

class VisitAgainCard extends StatelessWidget {
  const VisitAgainCard({
    super.key,
    required this.store,
    required this.fromFood,
  });
  final Store store;
  final bool fromFood;

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
    bool isAvailable = store.open == 1 && store.active!;

    return TextHover(
      builder: (hovered) {
        return Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(
                top: Dimensions.paddingSizeLarge,
                bottom: Dimensions.paddingSizeSmall,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color: Theme.of(context).cardColor,
                border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: CustomInkWell(
                onTap: () {
                  Get.toNamed(
                    RouteHelper.getStoreRoute(id: store.id, page: 'store'),
                    arguments: StoreScreen(store: store, fromModule: false),
                  );
                },
                radius: Dimensions.radiusDefault,
                padding: const EdgeInsets.only(
                  top: 40,
                  bottom: Dimensions.paddingSizeSmall,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        store.name ?? '',
                        style: robotoBold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (store.ratingCount! > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star,
                            size: 15,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(
                            width: Dimensions.paddingSizeExtraSmall,
                          ),
                          Text(
                            store.avgRating!.toStringAsFixed(1),
                            style: robotoRegular,
                          ),
                          const SizedBox(
                            width: Dimensions.paddingSizeExtraSmall,
                          ),
                          Text(
                            "(${store.ratingCount})",
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        ],
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.storefront_outlined,
                            size: 20,
                            color: Theme.of(context).disabledColor,
                          ),
                          const SizedBox(
                            width: Dimensions.paddingSizeExtraSmall,
                          ),
                          Flexible(
                            child: Text(
                              store.address ?? '',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: robotoRegular.copyWith(
                                color: Theme.of(context).disabledColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    store.items != null
                        ? Container(
                            alignment: Alignment.center,
                            height: 25,
                            width: 200,
                            child: ListView.builder(
                              itemCount: store.items!.length,
                              scrollDirection: Axis.horizontal,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    right: Dimensions.paddingSizeExtraSmall,
                                  ),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          (isPharmacy || isFood)
                                              ? 100
                                              : Dimensions.radiusSmall,
                                        ),
                                        child: CustomImage(
                                          image:
                                              '${store.items![index].imageFullUrl}',
                                          fit: BoxFit.cover,
                                          height: 25,
                                          width: 25,
                                        ),
                                      ),
                                      index == store.items!.length - 1
                                          ? Positioned(
                                              top: 0,
                                              left: 0,
                                              right: 0,
                                              bottom: 0,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        (isPharmacy || isFood)
                                                            ? 100
                                                            : Dimensions
                                                                  .radiusSmall,
                                                      ),
                                                  color: Colors.black
                                                      .withValues(alpha: 0.5),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    (store.itemCount! > 20)
                                                        ? '20+'
                                                        : '${store.itemCount}',
                                                    style: robotoMedium.copyWith(
                                                      color: Colors.white,
                                                      fontSize: Dimensions
                                                          .fontSizeExtraSmall,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : const SizedBox(),
                                    ],
                                  ),
                                );
                              },
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    fromFood ? 100 : Dimensions.radiusDefault,
                  ),
                  color: Theme.of(context).cardColor,
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    fromFood ? 100 : Dimensions.radiusDefault,
                  ),
                  child: Stack(
                    children: [
                      CustomImage(
                        isHovered: hovered,
                        image: '${store.logoFullUrl}',
                        fit: BoxFit.cover,
                        height: 54,
                        width: 54,
                      ),
                      isAvailable
                          ? const SizedBox()
                          : NotAvailableWidget(
                              isStore: true,
                              store: store,
                              fontSize: 8,
                              isAllSideRound: true,
                            ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 30,
              left: Get.find<LocalizationController>().isLtr ? null : 10,
              right: Get.find<LocalizationController>().isLtr ? 10 : null,
              child: GetBuilder<FavouriteController>(
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
                    child: Icon(
                      isWished ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
