import 'package:flutter/material.dart';
import 'package:friday_sa/util/dimensions.dart';

class TextFieldShadow extends StatelessWidget {
  const TextFieldShadow({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: child,
    );
  }
}
