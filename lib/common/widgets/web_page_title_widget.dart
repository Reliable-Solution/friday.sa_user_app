import 'package:flutter/material.dart';
import 'package:friday_sa/helper/responsive_helper.dart';
import 'package:friday_sa/util/styles.dart';

class WebScreenTitleWidget extends StatelessWidget {
  const WebScreenTitleWidget({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isDesktop(context)
        ? Container(
            height: 64,
            color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
            child: Center(child: Text(title, style: robotoMedium)),
          )
        : const SizedBox();
  }
}
