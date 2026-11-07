import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/common/widgets/custom_asset_image_widget.dart';
import 'package:friday_sa/features/order/widgets/support_reason_bottom_sheet.dart';
import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/features/order/controllers/order_controller.dart';
import 'package:friday_sa/features/order/domain/models/order_model.dart';
import 'package:friday_sa/helper/auth_helper.dart';
import 'package:friday_sa/helper/price_converter.dart';
import 'package:friday_sa/helper/responsive_helper.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/images.dart';
import 'package:friday_sa/util/styles.dart';
import 'package:friday_sa/features/order/widgets/order_item_widget.dart';
import 'package:friday_sa/features/parcel/widgets/details_widget.dart';

class OrderCalculationWidget extends StatelessWidget {
  const OrderCalculationWidget({
    super.key,
    required this.orderController,
    required this.order,
    required this.ongoing,
    required this.parcel,
    required this.prescriptionOrder,
    required this.deliveryCharge,
    required this.itemsPrice,
    required this.discount,
    required this.couponDiscount,
    required this.tax,
    required this.addOns,
    required this.dmTips,
    required this.taxIncluded,
    required this.subTotal,
    required this.total,
    required this.bottomView,
    required this.extraPackagingAmount,
    required this.referrerBonusAmount,
    required this.timerCancel,
    required this.startApiCall,
  });
  final OrderController orderController;
  final OrderModel order;
  final bool ongoing;
  final bool parcel;
  final bool prescriptionOrder;
  final num deliveryCharge;
  final num itemsPrice;
  final num discount;
  final num couponDiscount;
  final num tax;
  final num addOns;
  final num dmTips;
  final bool taxIncluded;
  final num subTotal;
  final num total;
  final Widget bottomView;
  final num extraPackagingAmount;
  final num referrerBonusAmount;
  final Function timerCancel;
  final Function startApiCall;

  // Helper to display price with +/- sign
  Widget _buildPriceRow(String label, num amount, {bool isCharge = true, bool isAnimated = true}) {
    final sign = isCharge ? '(+)' : '(-)';
    final priceText = isAnimated
        ? PriceConverter.convertAnimationPrice(
            amount,
            textStyle: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
            ),
          )
        : Text(
            PriceConverter.convertPrice(amount),
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
            ),
          );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
          ),
        ),
        Row(
          children: [
            Text(
              sign,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 4),
            priceText,
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: ResponsiveHelper.isDesktop(context)
            ? Dimensions.paddingSizeExtraLarge
            : Dimensions.paddingSizeSmall,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall,
          vertical: 4,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeSmall,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.03),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            (ResponsiveHelper.isDesktop(context) &&
                    orderController.orderDetails!.isNotEmpty)
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(Dimensions.radiusDefault),
                      ),
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeLarge,
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                    child: parcel
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              DetailsWidget(
                                title: 'sender_details'.tr,
                                address: order.deliveryAddress,
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeLarge,
                              ),
                              DetailsWidget(
                                title: 'receiver_details'.tr,
                                address: order.receiverDetails,
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: orderController.orderDetails!.length,
                                padding: const EdgeInsets.symmetric(
                                  vertical: Dimensions.paddingSizeSmall,
                                ),
                                itemBuilder: (context, index) {
                                  return OrderItemWidget(
                                    order: order,
                                    orderDetails:
                                        orderController.orderDetails![index],
                                  );
                                },
                              ),
                            ],
                          ),
                  )
                : const SizedBox(),
            SizedBox(
              height: parcel && orderController.orderDetails!.isNotEmpty
                  ? Dimensions.paddingSizeLarge
                  : 0,
            ),

            SizedBox(
              height:
                  (order.orderAttachmentFullUrl != null &&
                      order.orderAttachmentFullUrl!.isNotEmpty)
                  ? Dimensions.paddingSizeLarge
                  : 0,
            ),

            
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall,
                ),
                child: Text(
                  'order_summary'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            // Total
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge,
              ),
              child: Column(
                children: [
                  parcel
                      ? Column(
                          children: [
                            _buildPriceRow('delivery_fee'.tr, order.deliveryCharge!, isCharge: true),
                            const SizedBox(height: 10),
                            _buildPriceRow('delivery_man_tips'.tr, order.dmTips!, isCharge: true),
                            (order.additionalCharge != null &&
                                    order.additionalCharge! > 0)
                                ? const SizedBox(height: 10)
                                : const SizedBox(),
                            (order.additionalCharge != null &&
                                    order.additionalCharge! > 0)
                                ? _buildPriceRow(
                                    Get.find<SplashController>()
                                        .configModel!
                                        .additionalChargeName!,
                                    order.additionalCharge!,
                                    isCharge: true,
                                  )
                                : const SizedBox(),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'item_price'.tr,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                                ),
                                Text(
                                  PriceConverter.convertPrice(itemsPrice),
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Get.find<SplashController>()
                                    .getModuleConfig(order.moduleType)
                                    .addOn!
                                ? _buildPriceRow('addons'.tr, addOns, isCharge: true)
                                : const SizedBox(),
                            Get.find<SplashController>()
                                    .getModuleConfig(order.moduleType)
                                    .addOn!
                                ? Divider(
                                    thickness: 1,
                                    color: Theme.of(
                                      context,
                                    ).hintColor.withValues(alpha: 0.5),
                                  )
                                : const SizedBox(),
                            Get.find<SplashController>()
                                    .getModuleConfig(order.moduleType)
                                    .addOn!
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${'subtotal'.tr} ${taxIncluded ? 'tax_included'.tr : ''}',
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                        ),
                                      ),
                                      Text(
                                        PriceConverter.convertPrice(subTotal),
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox(),
                            SizedBox(
                              height:
                                  Get.find<SplashController>()
                                      .getModuleConfig(order.moduleType)
                                      .addOn!
                                  ? 10
                                  : 0,
                            ),
                            _buildPriceRow('discount'.tr, discount, isCharge: false),
                            const SizedBox(height: 10),
                            couponDiscount > 0
                                ? Column(
                                    children: [
                                      _buildPriceRow('coupon_discount'.tr, couponDiscount, isCharge: false),
                                      const SizedBox(height: 10),
                                    ],
                                  )
                                : const SizedBox(),
                            (referrerBonusAmount > 0)
                                ? Column(
                                    children: [
                                      _buildPriceRow('referral_discount'.tr, referrerBonusAmount, isCharge: false),
                                      const SizedBox(height: 10),
                                    ],
                                  )
                                : const SizedBox(),
                            (order.additionalCharge != null &&
                                    order.additionalCharge! > 0)
                                ? Column(
                                    children: [
                                      _buildPriceRow(
                                        Get.find<SplashController>()
                                            .configModel!
                                            .additionalChargeName!,
                                        order.additionalCharge!,
                                        isCharge: true,
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  )
                                : const SizedBox(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${'vat_tax'.tr} ${taxIncluded ? 'tax_included'.tr : ''} (${order.taxPercentage ?? 0}%)',
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '(+)',
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    PriceConverter.convertAnimationPrice(
                                      tax,
                                      textStyle: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            (dmTips > 0)
                                ? Column(
                                    children: [
                                      _buildPriceRow('delivery_man_tips'.tr, dmTips, isCharge: true),
                                      const SizedBox(height: 10),
                                    ],
                                  )
                                : const SizedBox(),
                            (extraPackagingAmount > 0)
                                ? Column(
                                    children: [
                                      _buildPriceRow('extra_packaging'.tr, extraPackagingAmount, isCharge: true),
                                      const SizedBox(height: 10),
                                    ],
                                  )
                                : const SizedBox(),
                            order.orderType != 'take_away'
                                ? _buildPriceRow(
                                    'delivery_fee'.tr,
                                    deliveryCharge,
                                    isCharge: deliveryCharge > 0,
                                  )
                                : const SizedBox(),
                          ],
                        ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: Dimensions.paddingSizeSmall,
              ),
              child: Divider(
                thickness: 1,
                color: Theme.of(context).hintColor.withValues(alpha: 0.5),
              ),
            ),

            order.paymentMethod == 'partial_payment'
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeLarge,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusDefault,
                        ),
                      ),
                      child: DottedBorder(
                        color: Theme.of(context).primaryColor,
                        strokeWidth: 1,
                        strokeCap: StrokeCap.butt,
                        dashPattern: const [8, 5],
                        padding: const EdgeInsets.all(8),
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(Dimensions.radiusDefault),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'total_amount'.tr,
                                  style: robotoMedium.copyWith(
                                    fontSize:
                                        ResponsiveHelper.isDesktop(context)
                                        ? Dimensions.fontSizeSmall
                                        : Dimensions.fontSizeDefault,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                Text(
                                  PriceConverter.convertPrice(total),
                                  style: robotoMedium.copyWith(
                                    fontSize:
                                        ResponsiveHelper.isDesktop(context)
                                        ? Dimensions.fontSizeSmall
                                        : Dimensions.fontSizeDefault,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'paid_by_wallet'.tr,
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '(-)',
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      PriceConverter.convertPrice(
                                        order.payments?[0].amount ?? 0,
                                      ),
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${order.payments?[1].paymentStatus == 'paid' ? 'paid_by'.tr : 'due_amount'.tr} (${order.payments?[1].paymentMethod?.tr})',
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '(+)',
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      PriceConverter.convertPrice(
                                        order.payments?[1].amount ?? 0,
                                      ),
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
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
                  )
                : Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeLarge,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeLarge,
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      border: Border(
                        left: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 4,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'total_amount'.tr,
                          style: robotoBold.copyWith(
                            fontSize: ResponsiveHelper.isDesktop(context)
                                ? Dimensions.fontSizeSmall
                                : Dimensions.fontSizeDefault,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Text(
                          PriceConverter.convertPrice(total),
                          style: robotoBold.copyWith(
                            fontSize: ResponsiveHelper.isDesktop(context)
                                ? Dimensions.fontSizeSmall
                                : Dimensions.fontSizeDefault,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            AuthHelper.isLoggedIn()
                ? TextButton(
                    onPressed: () async {
                      if (ResponsiveHelper.isDesktop(context)) {
                        await Get.dialog(
                          Dialog(
                            child: SupportReasonBottomSheet(
                              orderId: order.id,
                              timerCancel: timerCancel,
                              startApiCall: startApiCall,
                            ),
                          ),
                        );
                      } else {
                        await Get.bottomSheet(
                          SupportReasonBottomSheet(
                            orderId: order.id,
                            timerCancel: timerCancel,
                            startApiCall: startApiCall,
                          ),
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                        );
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomAssetImageWidget(
                          Images.chatSupport,
                          height: 20,
                          width: 20,
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Flexible(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${'message_to'.tr} ',
                                  style: robotoMedium.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium!.color,
                                  ),
                                ),
                                TextSpan(
                                  text: Get.find<SplashController>()
                                      .configModel!
                                      .businessName,
                                  style: robotoMedium.copyWith(
                                    color: Colors.blue,
                                    fontSize: Dimensions.fontSizeDefault,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),

            SizedBox(
              height: ResponsiveHelper.isDesktop(context)
                  ? Dimensions.paddingSizeLarge
                  : 0,
            ),
            ResponsiveHelper.isDesktop(context)
                ? Padding(
                    padding: const EdgeInsets.all(
                      Dimensions.paddingSizeDefault,
                    ),
                    child: bottomView,
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
