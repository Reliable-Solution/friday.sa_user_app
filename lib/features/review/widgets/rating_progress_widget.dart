import 'package:friday_sa/helper/responsive_helper.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:friday_sa/util/styles.dart';

class RatingProgressWidget extends StatelessWidget {
  const RatingProgressWidget({
    super.key,
    required this.ratingNumber,
    required this.ratingPercent,
    required this.progressValue,
  });
  final String ratingNumber;
  final num ratingPercent;
  final double progressValue;

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Row(
      children: [
        Text(
          ratingNumber,
          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
          child: LinearProgressIndicator(
            minHeight: isDesktop
                ? Dimensions.paddingSizeSmall
                : Dimensions.paddingSizeExtraSmall,
            value: progressValue,
            backgroundColor: Theme.of(context).hintColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ),
        Container(
          alignment: Alignment.centerRight,
          width: 30,
          child: Text(
            '${ratingPercent.toStringAsFixed(0)}%',
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium!.color?.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}
