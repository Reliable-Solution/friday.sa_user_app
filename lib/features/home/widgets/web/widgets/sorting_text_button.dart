import 'package:flutter/material.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/styles.dart';

class SortingTextButton extends StatelessWidget {
  const SortingTextButton({
    super.key,
    required this.title,
    this.onTap,
    this.isSelected = false,
  });
  final String title;
  final void Function()? onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        title,
        style: robotoMedium.copyWith(
          fontSize: Dimensions.fontSizeSmall,
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).disabledColor,
        ),
      ),
    );
  }
}
