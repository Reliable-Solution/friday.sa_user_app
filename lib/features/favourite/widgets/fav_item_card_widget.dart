import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/common/widgets/cart_count_view.dart';
import 'package:friday_sa/common/widgets/custom_asset_image_widget.dart';
import 'package:friday_sa/common/widgets/custom_favourite_widget.dart';
import 'package:friday_sa/features/item/controllers/item_controller.dart';
import 'package:friday_sa/features/language/controllers/language_controller.dart';
import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/features/favourite/controllers/favourite_controller.dart';
import 'package:friday_sa/features/item/domain/models/item_model.dart';
import 'package:friday_sa/common/models/module_model.dart';
import 'package:friday_sa/helper/date_converter.dart';
import 'package:friday_sa/helper/price_converter.dart';
import 'package:friday_sa/util/images.dart';
import 'package:friday_sa/util/styles.dart';
import 'package:friday_sa/common/widgets/custom_image.dart';
import 'package:friday_sa/common/widgets/not_available_widget.dart';
import 'package:friday_sa/common/widgets/organic_tag.dart';
import 'package:friday_sa/common/widgets/custom_snackbar.dart';

class FavItemCardWidget extends StatelessWidget {
  final Item item;
  final int index;
  final int? length;
  final bool isCampaign;
  final bool isFeatured;
  final bool inStore;

  const FavItemCardWidget({
    super.key,
    required this.item,
    required this.index,
    this.length,
    this.isCampaign = false,
    this.isFeatured = false,
    this.inStore = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool ltr = Get.find<LocalizationController>().isLtr;
    
    num discount = (item.storeDiscount == 0 || isCampaign)
        ? item.discount ?? 0
        : item.storeDiscount ?? 0;
    String discountType = (item.storeDiscount == 0 || isCampaign)
        ? item.discountType ?? 'percent'
        : 'percent';
        
    bool isAvailable = DateConverter.isAvailable(
      item.availableTimeStarts,
      item.availableTimeEnds,
    );

    bool isFoodModule = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType == 'food';
    if (isFoodModule) {
      isAvailable = true;
    }

    String genericName = '';
    if (item.genericName != null && item.genericName!.isNotEmpty) {
      for (String name in item.genericName!) {
        genericName += name;
      }
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Get.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border.all(
          color: Get.isDarkMode ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.03),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: Get.isDarkMode ? 0.35 : 0.04),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              if (item.storeOpen == 0 || item.storeActive == false) {
                showCustomSnackBar('this_store_is_closed_now'.tr);
              } else {
                if (isFeatured && Get.find<SplashController>().moduleList != null) {
                  for (ModuleModel module in Get.find<SplashController>().moduleList!) {
                    if (module.id == item.moduleId) {
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
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Section - Full Width Image Cover
                Expanded(
                  flex: 12,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                          child: CustomImage(
                            image: item.imageFullUrl ?? '',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      
                      // Bottom gradient sheet overlay over image
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.15),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.05),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Floating Organic / Generic Tag
                      OrganicTag(
                        item: item,
                        placeInImage: true,
                      ),
                      
                      // Unavailability overlay
                      if (!isAvailable)
                        const Positioned.fill(
                          child: NotAvailableWidget(isStore: false, radius: 18),
                        ),
                        
                      // Elegant Floating Favorite heart button
                      Positioned(
                        top: 8,
                        right: ltr ? 8 : null,
                        left: ltr ? null : 8,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.9),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 4,
                                spreadRadius: 0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: GetBuilder<FavouriteController>(
                            builder: (favouriteController) {
                              bool isWished = favouriteController.wishItemIdList.contains(item.id);
                              return Center(
                                child: CustomFavouriteWidget(
                                  isWished: isWished,
                                  isStore: false,
                                  store: null,
                                  item: item,
                                  size: 18,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Discount tag floating bottom-left
                      if (discount > 0)
                        Positioned(
                          bottom: 8,
                          left: ltr ? 8 : null,
                          right: ltr ? null : 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              discountType == 'percent' ? '-$discount%' : '-$discount ${Get.find<SplashController>().configModel!.currencySymbol}',
                              style: robotoBold.copyWith(
                                  fontSize: 10,
                                  color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                      // Floating Add/Minus counter buttons
                      Positioned(
                        bottom: 8,
                        right: ltr ? 8 : null,
                        left: ltr ? null : 8,
                        child: CartCountView(
                          item: item,
                          index: index,
                          isCompact: true,
                          child: Container(
                            height: 28,
                            width: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).cardColor,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.add,
                              size: 20,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Bottom Section - Details Container
                Expanded(
                  flex: 11,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category / Generic subtitle with Store/Location Icon
                        Row(
                          children: [
                            Icon(
                              Icons.store_mall_directory_rounded,
                              size: 11,
                              color: Theme.of(context).disabledColor,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                genericName.isNotEmpty ? genericName : (item.storeName ?? ''),
                                style: robotoMedium.copyWith(
                                  fontSize: 10,
                                  color: Theme.of(context).disabledColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 3),
                        
                        // Bold title
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                item.name ?? '',
                                style: robotoBold.copyWith(
                                  fontSize: 13.5,
                                  color: Theme.of(context).textTheme.bodyLarge!.color,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (Get.find<SplashController>().configModel!.moduleConfig!.module!.vegNonVeg! &&
                                Get.find<SplashController>().configModel!.toggleVegNonVeg!) ...[
                              const SizedBox(width: 4),
                              Image.asset(
                                item.veg == 0 ? Images.nonVegImage : Images.vegImage,
                                height: 10,
                                width: 10,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ],
                        ),
                        
                        const SizedBox(height: 6),
                        
                        // Rating, Delivery Time & Halal Tags Row
                        Row(
                          children: [
                            if (item.avgRating! > 0) ...[
                              Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: Colors.amber.shade700,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                item.avgRating!.toStringAsFixed(1),
                                style: robotoBold.copyWith(fontSize: 10),
                              ),
                              const SizedBox(width: 6),
                            ],
                            
                            // Delivery Time
                            Icon(
                              Icons.access_time_filled_rounded,
                              size: 12,
                              color: Theme.of(context).disabledColor,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '30-40 min',
                              style: robotoMedium.copyWith(
                                fontSize: 10,
                                color: Theme.of(context).disabledColor,
                              ),
                            ),
                            const SizedBox(width: 6),
                            
                            if (item.isStoreHalalActive! && item.isHalalItem!)
                              const CustomAssetImageWidget(
                                Images.halalTag,
                                height: 11,
                                width: 11,
                              ),
                          ],
                        ),
                        
                        const Spacer(),
                        
                        // Price Column
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              PriceConverter.convertPrice(
                                item.price,
                                discount: discount,
                                discountType: discountType,
                              ),
                              style: robotoBold.copyWith(
                                fontSize: 14,
                                color: Theme.of(context).primaryColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (discount > 0)
                              Text(
                                PriceConverter.convertPrice(item.price),
                                style: robotoRegular.copyWith(
                                  fontSize: 10,
                                  color: Theme.of(context).disabledColor,
                                  decoration: TextDecoration.lineThrough,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}
