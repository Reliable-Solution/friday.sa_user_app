import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/features/cart/controllers/cart_controller.dart';
import 'package:friday_sa/helper/price_converter.dart';
import 'package:friday_sa/helper/route_helper.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/styles.dart';


class BottomCartWidget extends StatelessWidget {
  const BottomCartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(
      builder: (cartController) {
        return IntrinsicHeight(
          child: Container(
            width: Get.width,
            color: Colors.transparent,
            padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 0, Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault),
            child: SafeArea(
              child: InkWell(
                onTap: () => Get.toNamed(RouteHelper.getCartRoute()),
                borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                  child: Row(
                    children: [
                      // Cart Icon & Count
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 28),
                          Positioned(
                            top: -5, right: -5,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: Text(
                                '${cartController.cartList.length}',
                                style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: Dimensions.paddingSizeLarge),

                      // Price Info
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'total'.tr,
                              style: robotoMedium.copyWith(color: Colors.white.withValues(alpha: 0.7), fontSize: Dimensions.fontSizeExtraSmall),
                            ),
                            Text(
                              PriceConverter.convertPrice(cartController.calculationCart()),
                              style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge),
                            ),
                          ],
                        ),
                      ),

                      // Action
                      Row(
                        children: [
                          Text(
                            'view_cart'.tr,
                            style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
