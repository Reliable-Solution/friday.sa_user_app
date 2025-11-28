import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:get/get.dart';
import 'package:friday_sa/util/styles.dart';

class PriceConverter {
  static String convertPrice(
    num? price, {
    num? discount,
    String? discountType,
    bool forDM = false,
    bool isFoodVariation = false,
    String? formatedStringPrice,
    bool forTaxi = false,
  }) {
    if (discount != null && discountType != null) {
      if (discountType == 'amount' && !isFoodVariation) {
        price = price! - discount;
      } else if (discountType == 'percent') {
        price = price! - ((discount / 100) * price);
      }
    }
    bool isRightSide =
        Get.find<SplashController>().configModel!.currencySymbolDirection ==
        'right';

    if (forTaxi && price! > 100000) {
      return '${isRightSide ? '' : '${Get.find<SplashController>().configModel!.currencySymbol!} '}'
          '${intl.NumberFormat.compact().format(price)}'
          '${isRightSide ? ' ${Get.find<SplashController>().configModel!.currencySymbol!}' : ''}';
    }
    return '${isRightSide ? '' : '${Get.find<SplashController>().configModel!.currencySymbol!} '}'
        '${formatedStringPrice ?? toFixed(price!).toStringAsFixed(forDM ? 0 : Get.find<SplashController>().configModel!.digitAfterDecimalPoint!).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'
        '${isRightSide ? ' ${Get.find<SplashController>().configModel!.currencySymbol!}' : ''}';
  }

  static Widget convertAnimationPrice(
    num? price, {
    num? discount,
    String? discountType,
    bool forDM = false,
    TextStyle? textStyle,
  }) {
    if (discount != null && discountType != null) {
      if (discountType == 'amount') {
        price = price! - discount;
      } else if (discountType == 'percent') {
        price = price! - ((discount / 100) * price);
      }
    }
    bool isRightSide =
        Get.find<SplashController>().configModel!.currencySymbolDirection ==
        'right';
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AnimatedFlipCounter(
        duration: const Duration(milliseconds: 500),
        value: toFixed(price!),
        textStyle: textStyle ?? robotoMedium,
        fractionDigits: forDM
            ? 0
            : Get.find<SplashController>().configModel!.digitAfterDecimalPoint!,
        prefix: isRightSide
            ? ''
            : '${Get.find<SplashController>().configModel!.currencySymbol!} ',
        suffix: isRightSide
            ? '${Get.find<SplashController>().configModel!.currencySymbol!} '
            : '',
      ),
    );
  }

  static num? convertWithDiscount(
    num? price,
    num? discount,
    String? discountType, {
    bool isFoodVariation = false,
  }) {
    if (discountType == 'amount' && !isFoodVariation) {
      price = price! - discount!;
    } else if (discountType == 'percent') {
      price = price! - ((discount! / 100) * price);
    }
    return price;
  }

  static num calculation(num amount, num? discount, String type, int quantity) {
    num calculatedAmount = 0;
    if (type == 'amount' || type == 'fixed') {
      calculatedAmount = discount! * quantity;
    } else if (type == 'percent') {
      calculatedAmount = (discount! / 100) * (amount * quantity);
    }
    return calculatedAmount;
  }

  static String percentageCalculation(
    String price,
    String discount,
    String discountType,
  ) {
    return '$discount${discountType == 'percent' ? '%' : Get.find<SplashController>().configModel!.currencySymbol} OFF';
  }

  static num toFixed(num val) {
    num mod = power(
      10,
      Get.find<SplashController>().configModel!.digitAfterDecimalPoint!,
    );
    return (val * mod)
            .toDouble()
            .toPrecision(
              Get.find<SplashController>().configModel!.digitAfterDecimalPoint!,
            )
            .floor() /
        mod;
  }

  static int power(int x, int n) {
    int retval = 1;
    for (int i = 0; i < n; i++) {
      retval *= x;
    }
    return retval;
  }
}
