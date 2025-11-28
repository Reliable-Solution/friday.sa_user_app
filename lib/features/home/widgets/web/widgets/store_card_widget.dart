import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:friday_sa/common/widgets/custom_ink_well.dart';
import 'package:friday_sa/common/widgets/hover/text_hover.dart';
import 'package:friday_sa/features/language/controllers/language_controller.dart';
import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/features/favourite/controllers/favourite_controller.dart';
import 'package:friday_sa/common/models/module_model.dart';
import 'package:friday_sa/features/store/domain/models/store_model.dart';
import 'package:friday_sa/helper/auth_helper.dart';
import 'package:friday_sa/helper/responsive_helper.dart';
import 'package:friday_sa/helper/route_helper.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/images.dart';
import 'package:friday_sa/util/styles.dart';
import 'package:friday_sa/common/widgets/custom_image.dart';
import 'package:friday_sa/common/widgets/custom_snackbar.dart';
import 'package:friday_sa/common/widgets/discount_tag.dart';
import 'package:friday_sa/common/widgets/hover/on_hover.dart';
import 'package:friday_sa/common/widgets/not_available_widget.dart';
import 'package:friday_sa/features/store/screens/store_screen.dart';

class StoreCardWidget extends StatelessWidget {
  const StoreCardWidget({super.key, required this.store});
  final Store? store;

  @override
  Widget build(BuildContext context) {
    num? discount = store!.discount != null ? store!.discount!.discount : 0;
    String? discountType = store!.discount != null
        ? store!.discount!.discountType
        : 'percent';
    bool isAvailable = store!.open == 1 && store!.active!;
    return OnHover(
      isItem: true,
      child: TextHover(
        builder: (hovered) {
          return Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).disabledColor.withValues(alpha: 0.1),
                  ),
                  boxShadow: ResponsiveHelper.isDesktop(context)
                      ? []
                      : const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                ),
                child: CustomInkWell(
                  onTap: () {
                    if (store != null) {
                      if (Get.find<SplashController>().moduleList != null) {
                        for (ModuleModel module
                            in Get.find<SplashController>().moduleList!) {
                          if (module.id == store!.moduleId) {
                            Get.find<SplashController>().setModule(module);
                            break;
                          }
                        }
                      }
                      Get.toNamed(
                        RouteHelper.getStoreRoute(id: store!.id, page: 'item'),
                        arguments: StoreScreen(store: store, fromModule: false),
                      );
                    }
                  },
                  radius: Dimensions.radiusDefault,
                  padding: const EdgeInsets.all(1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(Dimensions.radiusDefault),
                            ),
                            child: CustomImage(
                              isHovered: hovered,
                              image: '${store!.coverPhotoFullUrl}',
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          DiscountTag(
                            discount: discount,
                            discountType: discountType,
                          ),
                          isAvailable
                              ? const SizedBox()
                              : NotAvailableWidget(
                                  isStore: true,
                                  store: store,
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                  isAllSideRound: false,
                                ),
                          Positioned(
                            top: Dimensions.paddingSizeSmall,
                            right: Dimensions.paddingSizeSmall,
                            child: GetBuilder<FavouriteController>(
                              builder: (favouriteController) {
                                bool isWished = favouriteController
                                    .wishStoreIdList
                                    .contains(store!.id);
                                return InkWell(
                                  onTap: () {
                                    if (AuthHelper.isLoggedIn()) {
                                      isWished
                                          ? favouriteController
                                                .removeFromFavouriteList(
                                                  store!.id,
                                                  true,
                                                )
                                          : favouriteController
                                                .addToFavouriteList(
                                                  null,
                                                  store?.id,
                                                  true,
                                                );
                                    } else {
                                      showCustomSnackBar(
                                        'you_are_not_logged_in'.tr,
                                      );
                                    }
                                  },
                                  child: Icon(
                                    isWished
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 24,
                                    color: isWished
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context).disabledColor,
                                  ),
                                );
                              },
                            ),
                          ),
                          store!.ratingCount! > 0
                              ? Positioned(
                                  bottom: -15,
                                  left: Get.find<LocalizationController>().isLtr
                                      ? null
                                      : 10,
                                  right:
                                      Get.find<LocalizationController>().isLtr
                                      ? 10
                                      : null,
                                  child: Container(
                                    padding: const EdgeInsets.all(
                                      Dimensions.paddingSizeExtraSmall,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(100),
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 5,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 15,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        const SizedBox(
                                          width:
                                              Dimensions.paddingSizeExtraSmall,
                                        ),
                                        Text(
                                          store!.avgRating!.toStringAsFixed(1),
                                          style: robotoMedium.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeExtraSmall,
                                          ),
                                        ),
                                        const SizedBox(
                                          width:
                                              Dimensions.paddingSizeExtraSmall,
                                        ),
                                        Text(
                                          '(${store!.ratingCount})',
                                          style: robotoMedium.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeExtraSmall,
                                            color: Theme.of(
                                              context,
                                            ).disabledColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: context.width * 0.7,
                                child: Text(
                                  store!.name ?? '',
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 15,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(
                                    width: Dimensions.paddingSizeExtraSmall,
                                  ),
                                  Flexible(
                                    child: Text(
                                      store!.address ?? '',
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).disabledColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall,
                              ),
                              Row(
                                children: [
                                  store!.freeDelivery!
                                      ? Row(
                                          children: [
                                            Image.asset(
                                              Images.deliveryIcon,
                                              height: 15,
                                              width: 15,
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                            ),
                                            const SizedBox(
                                              width: Dimensions
                                                  .paddingSizeExtraSmall,
                                            ),
                                            Text(
                                              'free_delivery'.tr,
                                              style: robotoMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                                color: Theme.of(
                                                  context,
                                                ).disabledColor,
                                              ),
                                            ),
                                          ],
                                        )
                                      : const SizedBox(),
                                  SizedBox(
                                    width: store!.freeDelivery!
                                        ? Dimensions.paddingSizeSmall
                                        : 0,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.timer,
                                        size: 15,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      const SizedBox(
                                        width: Dimensions.paddingSizeExtraSmall,
                                      ),
                                      Text(
                                        '${store!.deliveryTime}',
                                        style: robotoMedium.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: Theme.of(
                                            context,
                                          ).disabledColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class StoreCardShimmer extends StatelessWidget {
  const StoreCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      width: 500,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(Dimensions.radiusSmall),
                ),
                color: Theme.of(context).shadowColor,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 15,
                      width: 200,
                      color: Theme.of(context).shadowColor,
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 10,
                      width: 130,
                      color: Theme.of(context).shadowColor,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          Icons.star,
                          color: Theme.of(context).shadowColor,
                          size: 15,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
