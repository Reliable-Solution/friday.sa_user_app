import 'package:flutter/material.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/styles.dart';

class StoreFilterButtonWidget extends StatelessWidget {
  const StoreFilterButtonWidget({
    super.key,
    this.isSelected,
    this.onTap,
    required this.buttonText,
  });

  final bool? isSelected;
  final void Function()? onTap;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 35,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: isSelected == true
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isSelected == true
                ? Theme.of(context).primaryColor
                : Theme.of(context).disabledColor.withValues(alpha: 0.1),
          ),
        ),
        child: Center(
          child: Text(
            buttonText,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: isSelected == true
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}
