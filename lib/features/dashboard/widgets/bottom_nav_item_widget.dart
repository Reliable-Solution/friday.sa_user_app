import 'package:flutter/material.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/styles.dart';

class BottomNavItemWidget extends StatelessWidget {
  const BottomNavItemWidget({
    super.key,
    this.onTap,
    this.isSelected = false,
    required this.title,
    required this.selectedIcon,
    required this.unSelectedIcon,
  });
  final String selectedIcon;
  final String unSelectedIcon;
  final String title;
  final Function? onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap as void Function()?,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              isSelected ? selectedIcon : unSelectedIcon,
              height: 25,
              width: 25,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).textTheme.bodyMedium!.color!,
            ),
            SizedBox(
              height: isSelected
                  ? Dimensions.paddingSizeExtraSmall
                  : Dimensions.paddingSizeSmall,
            ),
            Text(
              title,
              style: robotoRegular.copyWith(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).textTheme.bodyMedium!.color!,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
