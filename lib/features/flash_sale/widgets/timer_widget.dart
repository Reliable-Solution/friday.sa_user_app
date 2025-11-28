import 'package:flutter/material.dart';
import 'package:friday_sa/helper/responsive_helper.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/styles.dart';

class TimerWidget extends StatelessWidget {
  const TimerWidget({
    super.key,
    required this.timeUnit,
    required this.timeCount,
  });
  final int timeCount;
  final String timeUnit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.isMobile(context)
                ? Dimensions.paddingSizeSmall
                : Dimensions.paddingSizeExtraSmall,
            vertical: ResponsiveHelper.isMobile(context)
                ? Dimensions.paddingSizeSmall
                : Dimensions.paddingSizeExtraSmall,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          child: Text(
            timeCount > 9 ? timeCount.toString() : '0${timeCount.toString()}',
            style: robotoBold.copyWith(color: Colors.white),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Text(
          timeUnit,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
