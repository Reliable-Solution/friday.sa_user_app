import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:friday_sa/util/styles.dart';
import 'package:friday_sa/helper/price_converter.dart';
import 'package:friday_sa/common/widgets/custom_image.dart';
import 'package:friday_sa/features/item/controllers/item_controller.dart';
import 'package:friday_sa/features/item/domain/models/item_model.dart';
import 'package:friday_sa/helper/route_helper.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/images.dart';
import 'package:friday_sa/common/widgets/title_widget.dart';
import 'package:friday_sa/common/widgets/cart_count_view.dart';
import 'package:friday_sa/common/widgets/add_favourite_view.dart';
import 'package:friday_sa/features/cart/controllers/cart_controller.dart';

class SpecialOfferView extends StatelessWidget {
  const SpecialOfferView({
    super.key,
    required this.isFood,
    required this.isShop,
    this.storeId,
    this.storeName,
  });
  final bool isFood;
  final bool isShop;
  final int? storeId;
  final String? storeName;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(
      builder: (itemController) {
        debugPrint('=== DEBUG SPECIAL OFFER VIEW ===');
        debugPrint('storeId passed: $storeId');
        debugPrint('storeName passed: $storeName');
        debugPrint('================================');
        List<Item>? discountedItemList = itemController.discountedItemList;

        if (discountedItemList != null) {
          List<Item> filteredList = [];
          if (storeId != null || storeName != null) {
            filteredList = discountedItemList.where((item) {
              bool matchId = storeId != null && item.storeId == storeId;
              bool matchName = storeName != null &&
                  item.storeName != null &&
                  item.storeName!.toLowerCase().trim() == storeName!.toLowerCase().trim();
              return matchId || matchName;
            }).toList();
          } else {
            filteredList = discountedItemList;
          }


          return filteredList.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                  color: Theme.of(context).cardColor,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                        child: TitleWidget(
                          title: 'special_offer'.tr,
                          image: Images.discountOfferIcon,
                          onTap: () => Get.toNamed(
                            RouteHelper.getPopularItemRoute(false, true, storeId: storeId),
                            arguments: storeId,
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      SizedBox(
                        height: storeId != null ? 170 : 265,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            return SpecialOfferCard(
                              item: filteredList[index],
                              isCompact: storeId != null,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox();
        } else {
          return ItemShimmerView(isPopularItem: false, isCompact: storeId != null);
        }
      },
    );
  }
}

class SpecialOfferCard extends StatelessWidget {
  final Item item;
  final bool isCompact;
  const SpecialOfferCard({super.key, required this.item, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    num? discount = item.storeDiscount == 0 ? item.discount : item.storeDiscount;
    String? discountType = item.storeDiscount == 0 ? item.discountType : 'percent';

    return InkWell(
      onTap: () => Get.find<ItemController>().navigateToItemPage(item, context),
      child: Container(
        width: isCompact ? 120 : 140,
        margin: EdgeInsets.only(right: isCompact ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  child: CustomImage(
                    image: '${item.imageFullUrl}',
                    height: isCompact ? 100 : 120,
                    width: isCompact ? 120 : 140,
                    fit: BoxFit.contain,
                  ),
                ),
                GetBuilder<CartController>(
                  builder: (cartController) {
                    int cartQty = cartController.cartQuantity(item.id!);
                    double btnWidth = cartQty > 0 ? 92 : 32;
                    return Positioned(
                      bottom: 5,
                      right: 5,
                      width: btnWidth,
                      child: Transform.scale(
                        scale: 0.9,
                        alignment: Alignment.bottomRight,
                        child: CartCountView(
                          item: item,
                          index: item.id,
                          isCompact: true,
                          child: Container(
                            height: 32,
                            width: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF108910),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 22),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (discount != null && discount > 0)
                  Positioned(
                    top: 5,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        discountType == 'percent' ? '-$discount%' : '-${PriceConverter.convertPrice(discount)}',
                        style: robotoBold.copyWith(color: Colors.white, fontSize: 8),
                      ),
                    ),
                  ),
                if (item.organic == 1 && !isCompact)
                  Positioned(
                    bottom: 5,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        'Organic',
                        style: robotoRegular.copyWith(fontSize: 10, color: Colors.black54),
                      ),
                    ),
                  ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: AddFavouriteView(
                    item: item,
                    top: null, right: null, bottom: null, left: null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              PriceConverter.convertPrice(item.price ?? 0, discount: discount, discountType: discountType),
              style: robotoBold.copyWith(fontSize: isCompact ? 14 : 16, color: const Color(0xFF108910)),
            ),
            if (discount != null && discount > 0)
              Text(
                PriceConverter.convertPrice(item.price ?? 0),
                style: robotoRegular.copyWith(fontSize: 10, color: Colors.grey, decoration: TextDecoration.lineThrough),
              ),
            const SizedBox(height: 2),
            Text(
              item.name ?? '',
              style: robotoMedium.copyWith(fontSize: isCompact ? 12 : 14, color: Colors.black87),
              maxLines: isCompact ? 1 : 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!isCompact) ...[
              const SizedBox(height: 4),
              if (item.avgRating! > 0)
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 12),
                    const SizedBox(width: 2),
                    Text(
                      item.avgRating!.toStringAsFixed(1),
                      style: robotoRegular.copyWith(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${item.ratingCount})',
                      style: robotoRegular.copyWith(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              if (item.unitType != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    item.unitType ?? '',
                    style: robotoRegular.copyWith(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Color(0xFF108910), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'In stock',
                    style: robotoMedium.copyWith(fontSize: 11, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ],

          ],
        ),
      ),
    );
  }
}

class ItemShimmerView extends StatelessWidget {
  const ItemShimmerView({super.key, required this.isPopularItem, this.isCompact = false});
  final bool isPopularItem;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeDefault,
      ),
      child: Container(
        color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: Dimensions.paddingSizeDefault,
                left: Dimensions.paddingSizeDefault,
                right: Dimensions.paddingSizeDefault,
              ),
              child: TitleWidget(
                title: isPopularItem
                    ? 'most_popular_items'.tr
                    : 'special_offer'.tr,
                image: isPopularItem
                    ? Images.mostPopularIcon
                    : Images.discountOfferIcon,
              ),
            ),
            SizedBox(
              height: isCompact ? 170 : (isPopularItem ? 285 : 265),
              width: Get.width,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: Dimensions.paddingSizeDefault,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: Dimensions.paddingSizeDefault,
                      right: Dimensions.paddingSizeDefault,
                      top: Dimensions.paddingSizeDefault,
                    ),
                    child: Shimmer(
                      duration: const Duration(seconds: 2),
                      enabled: true,
                      child: Container(
                        padding: const EdgeInsets.all(
                          Dimensions.paddingSizeExtraSmall,
                        ),
                        height: isCompact ? 170 : (isPopularItem ? 285 : 265),
                        width: isCompact ? 120 : 140,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusLarge,
                          ),
                        ),
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              Container(
                                height: isCompact ? 100 : 120,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).shadowColor,
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusLarge,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeExtraSmall,
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).shadowColor,
                                        borderRadius: BorderRadius.circular(
                                          Dimensions.radiusSmall,
                                        ),
                                      ),
                                      height: 12,
                                      width: 100,
                                    ),
                                    const SizedBox(
                                      height: Dimensions.paddingSizeExtraSmall,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).shadowColor,
                                        borderRadius: BorderRadius.circular(
                                          Dimensions.radiusSmall,
                                        ),
                                      ),
                                      height: 15,
                                      width: 200,
                                    ),
                                    const SizedBox(
                                      height: Dimensions.paddingSizeExtraSmall,
                                    ),
                                    Container(
                                      height: 12,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).shadowColor,
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
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
