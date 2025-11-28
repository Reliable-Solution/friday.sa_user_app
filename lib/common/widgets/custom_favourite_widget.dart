import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/common/widgets/custom_snackbar.dart';
import 'package:friday_sa/features/favourite/controllers/favourite_controller.dart';
import 'package:friday_sa/features/item/domain/models/item_model.dart';
import 'package:friday_sa/features/store/domain/models/store_model.dart';
import 'package:friday_sa/helper/auth_helper.dart';

class CustomFavouriteWidget extends StatefulWidget {
  const CustomFavouriteWidget({
    super.key,
    this.store,
    this.item,
    this.isStore = false,
    required this.isWished,
    this.size = 25,
    this.storeId,
  });
  final Store? store;
  final Item? item;
  final bool isStore;
  final bool isWished;
  final double? size;
  final int? storeId;

  @override
  State<CustomFavouriteWidget> createState() => _CustomFavouriteWidgetState();
}

class _CustomFavouriteWidgetState extends State<CustomFavouriteWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: Get.find<FavouriteController>().isRemoving
          ? null
          : () {
              if (AuthHelper.isLoggedIn()) {
                _decideWished(widget.isWished, Get.find<FavouriteController>());
              } else {
                showCustomSnackBar(
                  'you_are_not_logged_in'.tr,
                  getXSnackBar: true,
                );
              }
              _controller.reverse().then((value) => _controller.forward());
            },
      child: ScaleTransition(
        scale: Tween(
          begin: 0.7,
          end: 1.0,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
        child: Icon(
          widget.isWished ? Icons.favorite : Icons.favorite_border_rounded,
          color: Theme.of(context).primaryColor,
          size: widget.size,
        ),
        // child: CustomAssetImageWidget(widget.isWished ? Images.favouriteIcon : Images.unFavouriteIcon, height: widget.size, width: widget.size),
      ),
    );
  }

  _decideWished(bool isWished, FavouriteController favouriteController) {
    if (widget.isStore) {
      isWished
          ? favouriteController.removeFromFavouriteList(
              widget.storeId ?? widget.store?.id,
              true,
            )
          : favouriteController.addToFavouriteList(
              null,
              widget.storeId ?? widget.store?.id,
              true,
            );
    } else {
      isWished
          ? favouriteController.removeFromFavouriteList(widget.item?.id, false)
          : favouriteController.addToFavouriteList(widget.item, null, false);
    }
  }
}
