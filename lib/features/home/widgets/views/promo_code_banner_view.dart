import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:friday_sa/common/widgets/custom_image.dart';
import 'package:friday_sa/features/coupon/controllers/coupon_controller.dart';
import 'package:friday_sa/helper/price_converter.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/images.dart';
import 'package:friday_sa/util/styles.dart';
import 'package:friday_sa/common/widgets/custom_snackbar.dart';

import '../../../splash/controllers/splash_controller.dart';

class PromoCodeBannerView extends StatefulWidget {
  const PromoCodeBannerView({super.key});

  @override
  State<PromoCodeBannerView> createState() => _PromoCodeBannerViewState();
}

class _PromoCodeBannerViewState extends State<PromoCodeBannerView> {
  final CarouselSliderController carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CouponController>(
      builder: (couponController) {
        return couponController.couponList != null
            ? couponController.couponList!.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeDefault,
                        horizontal: Dimensions.paddingSizeSmall,
                      ),
                      child: Column(
                        children: [
                          CarouselSlider.builder(
                            carouselController: carouselController,
                            itemCount: couponController.couponList!.length,
                            options: CarouselOptions(
                              height: 135,
                              autoPlay: true,
                              enlargeCenterPage: true,
                              disableCenter: true,
                              viewportFraction: 0.95,
                              onPageChanged: (index, reason) {
                                couponController.setCurrentIndex(index, true);
                              },
                            ),
                            itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
                              final coupon = couponController.couponList![itemIndex];
                              final String? storeName = coupon.store?.name ??
                                  ((coupon.couponType == 'store_wise' && coupon.data != null) ? coupon.data : null);
                              final String? storeLogoUrl = coupon.store?.logoFullUrl;

                              // Check if it is an "All Stores" coupon
                              final bool isAllStore = storeName == null || storeName.isEmpty;

                              return Container(
                                height: 135,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  image: const DecorationImage(
                                    image: AssetImage(Images.promoCodeBg),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // ---- Left: Logo/Icon section ----
                                    Padding(
                                      padding: const EdgeInsets.only(left: 12),
                                      child: isAllStore
                                          // ALL STORES: Show FRIDAY.SA logo with primary color
                                          ? Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                Container(
                                                  width: 76,
                                                  height: 76,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(10),
                                                    child: Image.asset(
                                                      Images.logo,
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                                // Discount badge
                                                Positioned(
                                                  bottom: -6,
                                                  left: -6,
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context).primaryColor,
                                                      borderRadius: BorderRadius.circular(20),
                                                      border: Border.all(color: Colors.white, width: 1.5),
                                                    ),
                                                    child: Text(
                                                      '${coupon.discount}${coupon.discountType == 'percent' ? '%' : Get.find<SplashController>().configModel!.currencySymbol} ${'off'.tr}',
                                                      style: robotoBold.copyWith(
                                                        fontSize: 9,
                                                        color: Colors.white,
                                                      ),
                                                      maxLines: 1,
                                                      softWrap: false,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          // STORE SPECIFIC: show store logo or generic icon
                                          : storeLogoUrl != null && storeLogoUrl.isNotEmpty
                                              ? Stack(
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    Container(
                                                      width: 76,
                                                      height: 76,
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                                                        borderRadius: BorderRadius.circular(12),
                                                        border: Border.all(
                                                          color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(11),
                                                        child: CustomImage(
                                                          image: storeLogoUrl,
                                                          height: 76,
                                                          width: 76,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      bottom: -6,
                                                      left: -6,
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                        decoration: BoxDecoration(
                                                          color: Theme.of(context).primaryColor,
                                                          borderRadius: BorderRadius.circular(20),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                                                              blurRadius: 6,
                                                              offset: const Offset(0, 2),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Text(
                                                          '${coupon.discount}${coupon.discountType == 'percent' ? '%' : Get.find<SplashController>().configModel!.currencySymbol} ${'off'.tr}',
                                                          style: robotoBold.copyWith(
                                                            fontSize: 9,
                                                            color: Colors.white,
                                                          ),
                                                          maxLines: 1,
                                                          softWrap: false,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Image.asset(
                                                  Images.couponOfferIcon,
                                                  height: 90,
                                                  width: 90,
                                                ),
                                    ),
                                    const SizedBox(width: 12),
                                    // ---- Right: Badge + title + copy button ----
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // ALL STORES gold badge
                                            if (isAllStore) ...[
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).primaryColor,
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.stars_rounded,
                                                      size: 14,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      'all_stores'.tr,
                                                      style: robotoBold.copyWith(
                                                        fontSize: Dimensions.fontSizeSmall,
                                                        color: Colors.white,
                                                        letterSpacing: 0.3,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                            ]
                                            // STORE SPECIFIC badge
                                            else if (storeName != null) ...[
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).primaryColor,
                                                  borderRadius: BorderRadius.circular(20),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Theme.of(context).primaryColor.withValues(alpha: 0.35),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    if (storeLogoUrl != null && storeLogoUrl.isNotEmpty)
                                                      ClipRRect(
                                                        borderRadius: BorderRadius.circular(10),
                                                        child: CustomImage(
                                                          image: storeLogoUrl,
                                                          height: 20,
                                                          width: 20,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      )
                                                    else
                                                      const Icon(
                                                        Icons.storefront_rounded,
                                                        size: 16,
                                                        color: Colors.white,
                                                      ),
                                                    const SizedBox(width: 6),
                                                    ConstrainedBox(
                                                      constraints: const BoxConstraints(maxWidth: 130),
                                                      child: Text(
                                                        storeName,
                                                        style: robotoBold.copyWith(
                                                          fontSize: Dimensions.fontSizeSmall,
                                                          color: Colors.white,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                            ],
                                            // Title
                                            Text(
                                              '${coupon.title ?? ''} ${'min_order_of'.tr} ${PriceConverter.convertPrice(coupon.minPurchase).replaceAll(' ', '\u00A0')}',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: robotoBold.copyWith(
                                                fontSize: Dimensions.fontSizeDefault,
                                                color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.85),
                                                height: 1.2,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            // Copy code button
                                            DottedBorder(
                                              color: Theme.of(context).primaryColor,
                                              strokeWidth: 1.2,
                                              strokeCap: StrokeCap.round,
                                              dashPattern: const [5, 4],
                                              padding: const EdgeInsets.all(0),
                                              borderType: BorderType.RRect,
                                              radius: const Radius.circular(50),
                                              child: InkWell(
                                                borderRadius: BorderRadius.circular(50),
                                                onTap: () {
                                                  if (coupon.code != null) {
                                                    Clipboard.setData(ClipboardData(text: coupon.code ?? ''));
                                                    showCustomSnackBar('coupon_code_copied'.tr, isError: false);
                                                  }
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context).cardColor.withValues(alpha: 0.85),
                                                    borderRadius: BorderRadius.circular(50),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.copy_rounded,
                                                        color: Theme.of(context).primaryColor,
                                                        size: 14,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Flexible(
                                                        child: Text(
                                                          coupon.code ?? '',
                                                          style: robotoBold.copyWith(
                                                            color: Theme.of(context).primaryColor,
                                                            fontSize: Dimensions.fontSizeSmall,
                                                            letterSpacing: 0.8,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          SizedBox(height: Dimensions.fontSizeSmall),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: couponController.couponList!.map((bnr) {
                              int index = couponController.couponList!.indexOf(
                                bnr,
                              );

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                child: index == couponController.currentIndex
                                    ? Container(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      )
                                    : Container(
                                        height: 5,
                                        width: 6,
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).primaryColor.withValues(alpha: 0.5),
                                          borderRadius: BorderRadius.circular(
                                            Dimensions.radiusDefault,
                                          ),
                                        ),
                                      ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox()
            : const PromoCodeShimmerView();
      },
    );
  }
}

class PromoCodeShimmerView extends StatelessWidget {
  const PromoCodeShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeDefault,
        horizontal: Dimensions.paddingSizeSmall,
      ),
      child: Column(
        children: [
          CarouselSlider.builder(
            itemCount: 5,
            options: CarouselOptions(
              height: 135,
              enlargeCenterPage: true,
              disableCenter: true,
              viewportFraction: 0.95,
            ),
            itemBuilder:
                (BuildContext context, int itemIndex, int pageViewIndex) {
                  return Shimmer(
                    duration: const Duration(seconds: 2),
                    enabled: true,
                    child: Container(
                      height: 135,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                        vertical: Dimensions.paddingSizeSmall,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusDefault,
                        ),
                      ),
                    ),
                  );
                },
          ),
        ],
      ),
    );
  }
}
