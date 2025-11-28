import 'package:flutter/material.dart';

class TaxiCartWidget extends StatelessWidget {
  const TaxiCartWidget({
    super.key,
    required this.color,
    required this.size,
    this.fromStore = false,
  });
  final Color? color;
  final num size;
  final bool fromStore;

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
