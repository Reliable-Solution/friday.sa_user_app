import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/util/dimensions.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({super.key, required this.child, this.showCard = true});
  final Widget child;
  final bool showCard;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      padding: showCard
          ? const EdgeInsets.all(Dimensions.paddingSizeSmall)
          : null,
      decoration: showCard
          ? BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            )
          : null,
      child: child,
    );
  }
}
