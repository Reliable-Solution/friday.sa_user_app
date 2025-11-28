import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/styles.dart';

class NewTag extends StatelessWidget {
  const NewTag({super.key, this.top = 5, this.left = 3, this.right});
  final double? top, left, right;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          color: Theme.of(context).primaryColor,
        ),
        child: Text(
          'new'.tr,
          style: robotoMedium.copyWith(
            color: Theme.of(context).cardColor,
            fontSize: Dimensions.fontSizeSmall,
          ),
        ),
      ),
    );
  }
}
