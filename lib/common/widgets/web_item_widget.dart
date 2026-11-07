import 'package:friday_sa/common/widgets/cart_count_view.dart';
import 'package:friday_sa/common/widgets/custom_favourite_widget.dart';
import 'package:friday_sa/helper/free_delivery_helper.dart';
import 'package:friday_sa/common/widgets/hover/on_hover.dart';
import 'package:friday_sa/common/widgets/hover/text_hover.dart';
import 'package:friday_sa/features/favourite/controllers/favourite_controller.dart';
import 'package:friday_sa/features/item/controllers/item_controller.dart';
import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/features/item/domain/models/item_model.dart';
import 'package:friday_sa/common/models/module_model.dart';
import 'package:friday_sa/features/store/domain/models/store_model.dart';
import 'package:friday_sa/helper/date_converter.dart';
import 'package:friday_sa/helper/price_converter.dart';
import 'package:friday_sa/helper/responsive_helper.dart';
import 'package:friday_sa/helper/route_helper.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/images.dart';
import 'package:friday_sa/util/styles.dart';
import 'package:friday_sa/common/widgets/custom_image.dart';
import 'package:friday_sa/common/widgets/discount_tag.dart';
import 'package:friday_sa/common/widgets/not_available_widget.dart';
import 'package:friday_sa/common/widgets/organic_tag.dart';
import 'package:friday_sa/common/widgets/rating_bar.dart';
import 'package:friday_sa/features/store/screens/store_screen.dart';
import 'package:friday_sa/common/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WebItemWidget extends StatelessWidget {
  const WebItemWidget({
    super.key,
    required this.item,
    required this.isStore,
    required this.store,
    required this.index,
    required this.length,
    this.inStore = false,
    this.isCampaign = false,
    this.isFeatured = false,
    this.fromCartSuggestion = false,
  });
  final Item? item;
  final Store? store;
  final bool isStore;
  final int index;
  final int? length;
  final bool inStore;
  final bool isCampaign;
  final bool isFeatured;
  final bool fromCartSuggestion;

  @override
  Widget build(BuildContext context) {
    bool desktop = ResponsiveHelper.isDesktop(context);
    num? discount;
    String? discountType;
    bool isAvailable;
    String genericName = '';

    if (!isStore &&
        item!.genericName != null &&
        item!.genericName!.isNotEmpty) {
      for (String name in item!.genericName!) {
        genericName += name;
      }
    }
    if (isStore) {
      discount = store!.discount != null ? store!.discount!.discount : 0;
      discountType = store!.discount != null
          ? store!.discount!.discountType
          : 'percent';
      isAvailable = store!.open == 1 && store!.active!;
    } else {
      discount = (item!.storeDiscount == 0 || isCampaign)
          ? item!.discount
          : item!.storeDiscount;
      discountType = (item!.storeDiscount == 0 || isCampaign)
          ? item!.discountType
          : 'percent';
      isAvailable = DateConverter.isAvailable(
        item!.availableTimeStarts,
        item!.availableTimeEnds,
      );
    }
    bool isOutOfStock = !isStore &&
        Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! &&
        (item!.stock ?? 0) <= 0;

    return TextHover(
      builder: (hovered) {
        return InkWell(
          onTap: () {
            if (isStore) {
              if (store != null) {
                if (store!.open == 0 || store!.active == false) {
                  showCustomSnackBar('this_store_is_closed_now'.tr);
                } else {
                  if (isFeatured &&
                      Get.find<SplashController>().moduleList != null) {
                    for (ModuleModel module
                        in Get.find<SplashController>().moduleList!) {
                      if (module.id == store!.moduleId) {
                        Get.find<SplashController>().setModule(module);
                        break;
                      }
                    }
                  }
                  Get.toNamed(
                    RouteHelper.getStoreRoute(
                      id: store!.id,
                      page: isFeatured ? 'module' : 'item',
                    ),
                    arguments:
                        StoreScreen(store: store, fromModule: isFeatured),
                  );
                }
              }
            } else {
              if (item!.storeOpen == 0 || item!.storeActive == false) {
                showCustomSnackBar('this_store_is_closed_now'.tr);
              } else {
                if (isFeatured &&
                    Get.find<SplashController>().moduleList != null) {
                  for (ModuleModel module
                      in Get.find<SplashController>().moduleList!) {
                    if (module.id == item!.moduleId) {
                      Get.find<SplashController>().setModule(module);
                      break;
                    }
                  }
                }
                Get.find<ItemController>().navigateToItemPage(
                  item,
                  context,
                  inStore: inStore,
                  isCampaign: isCampaign,
                );
              }
            }
          },
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          child: OnHover(
            isItem: true,
            child: Stack(
              children: [
                Container(
                  margin: ResponsiveHelper.isDesktop(context)
                      ? const EdgeInsets.all(Dimensions.paddingSizeExtraSmall)
                      : const EdgeInsets.only(
                          bottom: Dimensions.paddingSizeSmall,
                        ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(Dimensions.radiusDefault),
                                  ),
                                  child: CustomImage(
                                    isHovered: hovered,
                                    image:
                                        '${isStore
                                            ? store != null
                                                  ? store!.logoFullUrl
                                                  : ''
                                            : item!.imageFullUrl}',
                                    height: desktop ? 160 : (length == null ? 100 : 65),
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                DiscountTag(
                                  discount: discount,
                                  discountType: discountType,
                                  freeDelivery: isStore
                                      ? FreeDeliveryHelper.isFreeDelivery(store)
                                      : false,
                                ),
                                !isStore
                                    ? OrganicTag(
                                        item: item!,
                                        placeInImage: false,
                                        placeTop: false,
                                      )
                                    : const SizedBox(),
                                isStore
                                    ? const SizedBox()
                                    : Positioned(
                                        bottom: 10,
                                        right: 10,
                                        child: CartCountView(
                                          item: item!,
                                          index: index,
                                          isCompact: true,
                                        ),
                                      ),
                                (isAvailable && !isOutOfStock)
                                    ? const SizedBox()
                                    : NotAvailableWidget(
                                        isStore: isStore,
                                        isOutOfStock: isOutOfStock,
                                      ),
                              ],
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          isStore ? store!.name! : item!.name!,
                                          style: robotoMedium.copyWith(
                                            fontSize: Dimensions.fontSizeDefault,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                        (Get.find<SplashController>().configModel!.moduleConfig!.module!.vegNonVeg! &&
                                                Get.find<SplashController>().configModel!.toggleVegNonVeg!)
                                            ? Image.asset(
                                                item != null && item!.veg == 0 ? Images.nonVegImage : Images.vegImage,
                                                height: 12,
                                                width: 12,
                                                fit: BoxFit.contain,
                                              )
                                            : const SizedBox(),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    if (genericName.isNotEmpty)
                                      Text(
                                        genericName,
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeExtraSmall,
                                          color: Theme.of(context).disabledColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    Text(
                                      isStore ? store!.address ?? '' : item!.storeName ?? '',
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeExtraSmall,
                                        color: isStore ? Theme.of(context).disabledColor : Theme.of(context).primaryColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    isStore
                                        ? RatingBar(
                                            rating: (isStore ? store!.avgRating : item!.avgRating)?.toDouble(),
                                            size: 15,
                                            ratingCount: isStore ? store!.ratingCount : item!.ratingCount,
                                          )
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    PriceConverter.convertPrice(
                                                      item!.price,
                                                      discount: discount,
                                                      discountType: discountType,
                                                    ),
                                                    style: robotoBold.copyWith(
                                                      fontSize: Dimensions.fontSizeDefault,
                                                      color: Theme.of(context).primaryColor,
                                                    ),
                                                    textDirection: TextDirection.ltr,
                                                  ),
                                                  if (discount! > 0) ...[
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      PriceConverter.convertPrice(item!.price),
                                                      style: robotoRegular.copyWith(
                                                        fontSize: Dimensions.fontSizeExtraSmall,
                                                        color: Theme.of(context).disabledColor,
                                                        decoration: TextDecoration.lineThrough,
                                                      ),
                                                      textDirection: TextDirection.ltr,
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
                                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.star_rounded, color: Theme.of(context).primaryColor, size: 14),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      item!.avgRating!.toStringAsFixed(1),
                                                      style: robotoMedium.copyWith(
                                                        fontSize: Dimensions.fontSizeExtraSmall,
                                                        color: Theme.of(context).primaryColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GetBuilder<FavouriteController>(
                    builder: (favouriteController) {
                      bool isWished = isStore
                          ? favouriteController.wishStoreIdList.contains(
                              store!.id,
                            )
                          : favouriteController.wishItemIdList.contains(
                              item!.id,
                            );
                      return CustomFavouriteWidget(
                        isWished: isWished,
                        isStore: isStore,
                        store: store,
                        item: item,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
