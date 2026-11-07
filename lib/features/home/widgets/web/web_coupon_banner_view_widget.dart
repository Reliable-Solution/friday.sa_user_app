import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:friday_sa/common/widgets/custom_image.dart';
import 'package:friday_sa/features/coupon/controllers/coupon_controller.dart';
import 'package:friday_sa/features/home/widgets/views/promo_code_banner_view.dart';
import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/helper/price_converter.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/images.dart';
import 'package:friday_sa/util/styles.dart';
import 'package:friday_sa/common/widgets/custom_snackbar.dart';

class WebCouponBannerViewWidget extends StatefulWidget {
  const WebCouponBannerViewWidget({super.key});

  @override
  State<WebCouponBannerViewWidget> createState() =>
      _WebCouponBannerViewWidgetState();
}

class _WebCouponBannerViewWidgetState extends State<WebCouponBannerViewWidget> {
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
                        vertical: Dimensions.paddingSizeExtraLarge,
                      ),
                      child: Column(
                        children: [
                          CarouselSlider.builder(
                            carouselController: carouselController,
                            itemCount: couponController.couponList!.length,
                            options: CarouselOptions(
                              height: 135,
                              enlargeCenterPage: true,
                              disableCenter: true,
                              viewportFraction: 1,
                              onPageChanged: (index, reason) {
                                couponController.setCurrentIndex(index, true);
                              },
                            ),
                            itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
                              final coupon = couponController.couponList![itemIndex];
                              final String? storeName = coupon.store?.name ??
                                  ((coupon.couponType == 'store_wise' && coupon.data != null) ? coupon.data : null);
                              final String? storeLogoUrl = coupon.store?.logoFullUrl;
                              final bool isAllStore = storeName == null || storeName.isEmpty;

                              return Container(
                                height: 135,
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeDefault,
                                  vertical: Dimensions.paddingSizeSmall,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault,
                                  ),
                                  image: const DecorationImage(
                                    image: AssetImage(Images.promoCodeBg),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: Dimensions.paddingSizeDefault,
                                    ),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          isAllStore
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
                                                              border: Border.all(color: Colors.white, width: 1.5),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
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
                                                      height: 92,
                                                      width: 115,
                                                    ),
                                          const SizedBox(width: 50),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
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
                                              ] else if (storeName != null) ...[
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
                                              Text(
                                                coupon.title ?? '',
                                                style: robotoBold.copyWith(
                                                  fontSize: Dimensions
                                                      .fontSizeOverLarge,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .color!
                                                      .withValues(alpha: 0.8),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeExtraSmall,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    'min_order_of'.tr,
                                                    style: robotoMedium
                                                        .copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeLarge,
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyLarge!
                                                                  .color!
                                                                  .withValues(
                                                                    alpha: 0.8,
                                                                  ),
                                                        ),
                                                  ),
                                                  const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeExtraSmall,
                                                  ),
                                                  Text(
                                                    PriceConverter.convertPrice(
                                                      coupon.minPurchase,
                                                    ),
                                                    style: robotoBold.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeOverLarge,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .color!
                                                          .withValues(
                                                            alpha: 0.8,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: Dimensions.paddingSizeDefault,
                                    ),
                                    const Spacer(),
                                    DottedBorder(
                                      color: Theme.of(context).primaryColor,
                                      strokeWidth: 1,
                                      strokeCap: StrokeCap.butt,
                                      dashPattern: const [5, 5],
                                      padding: const EdgeInsets.all(0),
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(50),
                                      child: InkWell(
                                        onTap: () {
                                          if (coupon.code != null) {
                                            Clipboard.setData(
                                              ClipboardData(
                                                text: coupon.code ?? '',
                                              ),
                                            );
                                            showCustomSnackBar(
                                              'coupon_code_copied'.tr,
                                              isError: false,
                                            );
                                          }
                                        },
                                        child: Container(
                                          height: 35,
                                          width: 130,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius: BorderRadius.circular(
                                              50,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                Dimensions.paddingSizeSmall,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.copy,
                                                color: Theme.of(context).primaryColor,
                                                size: 16,
                                              ),
                                              const SizedBox(
                                                width: Dimensions
                                                    .paddingSizeExtraSmall,
                                              ),
                                              Text(
                                                coupon.code ?? '',
                                                style: robotoMedium.copyWith(
                                                  color: Theme.of(context).primaryColor,
                                                  fontSize:
                                                      Dimensions.fontSizeSmall,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: Dimensions.paddingSizeDefault,
                                    ),
                                  ],
                                ),
                              );
                            },
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
