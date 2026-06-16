import 'dart:math';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:friday_sa/common/widgets/custom_snackbar.dart';
import 'package:friday_sa/common/widgets/custom_image.dart';
import 'package:friday_sa/features/language/controllers/language_controller.dart';
import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/common/controllers/theme_controller.dart';
import 'package:friday_sa/features/coupon/domain/models/coupon_model.dart';
import 'package:friday_sa/helper/date_converter.dart';
import 'package:friday_sa/helper/price_converter.dart';
import 'package:friday_sa/helper/responsive_helper.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/images.dart';
import 'package:friday_sa/util/styles.dart';

class CouponCardWidget extends StatelessWidget {
  const CouponCardWidget({
    super.key,
    required this.coupon,
    required this.index,
  });
  final CouponModel coupon;
  final int index;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final String? storeName = coupon.store?.name ??
        ((coupon.couponType == 'store_wise' && coupon.data != null) ? coupon.data : null);
    final bool isAllStore = storeName == null || storeName.isEmpty;

    return ExcludeSemantics(
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            child: Transform.rotate(
              angle: Get.find<LocalizationController>().isLtr ? 0 : pi,
              child: Image.asset(
                Get.find<ThemeController>().darkTheme
                    ? Images.couponBgDark
                    : Images.couponBgLight,
                height: ResponsiveHelper.isMobilePhone() ? 120 : 140,
                width: size.width,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            height: ResponsiveHelper.isMobilePhone() ? 120 : 140,
            alignment: Alignment.center,
            child: Row(
              children: [
                SizedBox(
                  width: ResponsiveHelper.isDesktop(context)
                      ? 150
                      : size.width * 0.3,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Main square — Stylized text/icon placeholder
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              border: Border.all(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                                width: 1.5,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.5),
                              child: isAllStore
                                  ? Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: Image.asset(
                                        Images.logo,
                                        fit: BoxFit.contain,
                                      ),
                                    )
                                  : (coupon.store != null &&
                                          coupon.store!.logoFullUrl != null &&
                                          coupon.store!.logoFullUrl!.isNotEmpty)
                                      ? CustomImage(
                                          image: coupon.store!.logoFullUrl!,
                                          height: 76,
                                          width: 76,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor,
                                          ),
                                          child: Center(
                                            child: (storeName != null && storeName.isNotEmpty)
                                                ? Text(
                                                    storeName[0].toUpperCase(),
                                                    style: robotoBold.copyWith(
                                                      fontSize: 32,
                                                      color: Colors.white,
                                                      shadows: [
                                                        BoxShadow(
                                                          color: Colors.black.withValues(alpha: 0.15),
                                                          blurRadius: 4,
                                                          offset: const Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : Icon(
                                                    coupon.couponType == 'free_delivery'
                                                        ? Icons.delivery_dining_rounded
                                                        : Icons.local_offer_rounded,
                                                    size: 32,
                                                    color: Colors.white,
                                                  ),
                                          ),
                                        ),
                            ),
                          ),
                          // Discount badge — bottom-left corner
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
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      top: 2,
                      bottom: 2,
                      start: 12,
                      end: 12,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          // Store badge
                          if (isAllStore) ...[
                            IntrinsicWidth(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.stars_rounded,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text( 
                                      'all_stores'.tr,
                                      style: robotoBold.copyWith(
                                        fontSize: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                          ] else if (storeName != null) ...[
                            IntrinsicWidth(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 160),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.storefront_rounded,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          storeName,
                                          style: robotoBold.copyWith(
                                            fontSize: 10,
                                            color: Colors.white,
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
                            const SizedBox(height: 3),
                          ],
                          Text(
                            '${coupon.title}',
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.9),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${DateConverter.stringToReadableString(coupon.startDate!)} ${'to'.tr} ${DateConverter.stringToReadableString(coupon.expireDate!)}',
                            style: robotoMedium.copyWith(
                              color: Theme.of(context).disabledColor,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                '*${'min_purchase'.tr} ',
                                style: robotoRegular.copyWith(
                                  color: Theme.of(context).disabledColor,
                                  fontSize: 9,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                PriceConverter.convertPrice(coupon.minPurchase).replaceAll(' ', '\u00A0'),
                                style: robotoMedium.copyWith(
                                  color: Theme.of(context).disabledColor,
                                  fontSize: 9,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textDirection: TextDirection.ltr,
                              ),
                            ],
                          ),
                          if (!ResponsiveHelper.isDesktop(context)) ...[
                            const SizedBox(height: 3),
                            Flexible(
                              child: DottedBorder(
                                color: Theme.of(context).primaryColor,
                                strokeWidth: 1.0,
                                strokeCap: StrokeCap.round,
                                dashPattern: const [4, 3],
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
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                                          size: 11,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            coupon.code ?? '',
                                            style: robotoBold.copyWith(
                                              color: Theme.of(context).primaryColor,
                                              fontSize: 9,
                                              letterSpacing: 0.6,
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
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ResponsiveHelper.isDesktop(context)
              ? Positioned(
                  top: Dimensions.paddingSizeSmall,
                  right: Dimensions.paddingSizeSmall,
                  child: JustTheTooltip(
                    backgroundColor: Theme.of(context).cardColor,
                    controller: coupon.toolTip,
                    preferredDirection: AxisDirection.up,
                    tailLength: 14,
                    tailBaseWidth: 20,
                    triggerMode: TooltipTriggerMode.manual,
                    content: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'code_copied'.tr,
                        style: robotoRegular.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    child: InkWell(
                      onTap: () async {
                        coupon.toolTip?.showTooltip();
                        Clipboard.setData(ClipboardData(text: coupon.code!));
  
                        Future.delayed(const Duration(milliseconds: 750), () {
                          coupon.toolTip?.hideTooltip();
                        });
                      },
                      child: Image.asset(
                        Images.copyCoupon,
                        height: 20,
                        width: 20,
                      ),
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
