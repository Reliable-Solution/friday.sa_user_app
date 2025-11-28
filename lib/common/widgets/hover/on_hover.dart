import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/common/controllers/theme_controller.dart';
import 'package:friday_sa/util/dimensions.dart';

class OnHover extends StatefulWidget {
  const OnHover({
    super.key,
    required this.child,
    this.isItem = false,
    this.fromMenu = false,
  });
  final Widget child;
  final bool isItem;
  final bool fromMenu;

  @override
  State<OnHover> createState() => _OnHoverState();
}

class _OnHoverState extends State<OnHover> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    final hoverTransformed = Matrix4.identity()..scale(1.05, 1.03);
    final transform = isHovered ? hoverTransformed : Matrix4.identity();
    final shadow1 = BoxDecoration(
      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      color: widget.fromMenu
          ? Theme.of(context).primaryColor.withValues(alpha: 0.10)
          : Theme.of(context).cardColor,
      boxShadow: [
        widget.fromMenu
            ? const BoxShadow(color: Colors.transparent)
            : BoxShadow(
                color: Get.find<ThemeController>().darkTheme
                    ? const Color(0xFFBDBDBD).withValues(alpha: 0.1)
                    : Theme.of(context).primaryColor.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 10),
              ),
      ],
    );
    final shadow2 = BoxDecoration(
      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      boxShadow: const [
        BoxShadow(
          color: Colors.transparent,
          blurRadius: 0,
          offset: Offset(0, 0),
        ),
      ],
    );
    return MouseRegion(
      onEnter: (event) => onEntered(true),
      onExit: (event) => onEntered(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: widget.isItem
            ? isHovered
                  ? shadow1
                  : shadow2
            : shadow2,
        transform: widget.isItem ? Matrix4.identity() : transform,
        child: widget.child,
      ),
    );
  }

  void onEntered(bool isHovered) {
    setState(() {
      this.isHovered = isHovered;
    });
  }
}
