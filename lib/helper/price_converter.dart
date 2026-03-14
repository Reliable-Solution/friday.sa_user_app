import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:get/get.dart';

import '../features/language/controllers/language_controller.dart';
import '../features/splash/controllers/splash_controller.dart';
import '../util/styles.dart';

class PriceConverter {
  /// Helper method to check if current language is Arabic
  static bool _isArabicLanguage() {
    try {
      if (Get.isRegistered<LocalizationController>()) {
        return Get.find<LocalizationController>().locale.languageCode
            .startsWith('ar');
      } else if (Get.locale != null) {
        return Get.locale!.languageCode.startsWith('ar');
      }
    } catch (e) {
      // Fallback to false if any error occurs
    }
    return false;
  }

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
    String? symbol =
        Get.find<SplashController>().configModel?.currencySymbol ?? '﷼';
    bool isRightSide =
        Get.find<SplashController>().configModel?.currencySymbolDirection
            ?.toLowerCase()
            .trim() ==
        'right';

    // For Arabic language, invert the direction logic
    // English: Left = Symbol,Price | Right = Price,Symbol
    // Arabic:  Left = Price,Symbol | Right = Symbol,Price
    if (_isArabicLanguage()) {
      isRightSide = !isRightSide;
    }

    int digitAfterDecimal =
        Get.find<SplashController>().configModel?.digitAfterDecimalPoint ?? 2;

    if (forTaxi && price! > 100000) {
      String compact = intl.NumberFormat.compact().format(price);
      return isRightSide
          ? '\u202D$compact $symbol\u202C'
          : '\u202D$symbol $compact\u202C';
    }

    String formattedPrice =
        formatedStringPrice ??
        toFixed(price!)
            .toStringAsFixed(forDM ? 0 : digitAfterDecimal)
            .replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            );

    return isRightSide
        ? '\u202D$formattedPrice $symbol\u202C'
        : '\u202D$symbol $formattedPrice\u202C';
  }

  /// Converts price with a prefix sign (+) or (-) based on language direction
  /// For Arabic: Symbol Price (sign) e.g., ﷼ 100.00 (-)
  /// For English: (sign) Symbol Price e.g., (-) ﷼ 100.00
  static String convertPriceWithSign(
    num? price, {
    bool isPositive = false, // true for (+), false for (-)
    num? discount,
    String? discountType,
    bool forDM = false,
    bool isFoodVariation = false,
  }) {
    String priceStr = convertPrice(
      price,
      discount: discount,
      discountType: discountType,
      forDM: forDM,
      isFoodVariation: isFoodVariation,
    );

    String sign = isPositive ? '(+)' : '(-)';

    // For Arabic: price then sign | For English: sign then price
    return _isArabicLanguage()
        ? '\u202D$priceStr $sign\u202C'
        : '\u202D$sign $priceStr\u202C';
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
    String? symbol =
        Get.find<SplashController>().configModel?.currencySymbol ?? '﷼';
    bool isRightSide =
        Get.find<SplashController>().configModel?.currencySymbolDirection
            ?.toLowerCase()
            .trim() ==
        'right';

    // For Arabic language, invert the direction logic
    if (_isArabicLanguage()) {
      isRightSide = !isRightSide;
    }

    int digitAfterDecimal =
        Get.find<SplashController>().configModel?.digitAfterDecimalPoint ?? 2;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: AnimatedFlipCounter(
        duration: const Duration(milliseconds: 500),
        value: toFixed(price!),
        textStyle: textStyle ?? robotoMedium,
        fractionDigits: forDM ? 0 : digitAfterDecimal,
        prefix: isRightSide ? '' : '$symbol ',
        suffix: isRightSide ? ' $symbol' : '',
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
    String? price,
    String discount,
    String discountType,
  ) {
    String? symbol =
        Get.find<SplashController>().configModel?.currencySymbol ?? '﷼';
    bool isRightSide =
        Get.find<SplashController>().configModel?.currencySymbolDirection
            ?.toLowerCase()
            .trim() ==
        'right';

    // For Arabic language, invert the direction logic
    if (_isArabicLanguage()) {
      isRightSide = !isRightSide;
    }

    return '\u202D${(isRightSide || discountType == 'percent') ? '' : '$symbol '}$discount${discountType == 'percent'
        ? '%'
        : isRightSide
        ? ' $symbol'
        : ''} ${'off'.tr}\u202C';
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
