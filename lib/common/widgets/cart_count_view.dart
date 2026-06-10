import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/features/cart/controllers/cart_controller.dart';
import 'package:friday_sa/features/item/controllers/item_controller.dart';
import 'package:friday_sa/features/item/domain/models/item_model.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/styles.dart';
import 'package:friday_sa/features/store/controllers/store_controller.dart';

class CartCountView extends StatelessWidget {
  const CartCountView({
    super.key,
    required this.item,
    this.child,
    this.index = -1,
    this.isCompact = false,
  });
  final Item item;
  final Widget? child;
  final int? index;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(
      builder: (cartController) {
        int cartQty = cartController.cartQuantity(item.id!);
        int cartIndex = cartController.isExistInCart(
          item.id,
          cartController.cartVariant(item.id!),
          false,
          null,
        );
        return cartQty != 0
            ? Center(
                child: Container(
                  width: isCompact ? 92 : 115,
                  height: isCompact ? 32 : 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusExtraLarge,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: cartController.isLoading
                            ? null
                            : () {
                                if (item.storeOpen == 0 || item.storeActive == false || (item.storeOpen == null && Get.find<StoreController>().store != null && item.storeId == Get.find<StoreController>().store!.id && (Get.find<StoreController>().store!.open == 0 || Get.find<StoreController>().store!.active == false))) {
                                  Get.find<ItemController>().showStoreClosedSnackbar();
                                } else {
                                  if (cartController
                                          .cartList[cartIndex]
                                          .quantity! >
                                      1) {
                                    cartController.setDirectlyAddToCartIndex(
                                      index,
                                    );
                                    cartController.setQuantity(
                                      false,
                                      cartIndex,
                                      cartController.cartList[cartIndex].stock,
                                      cartController
                                          .cartList[cartIndex]
                                          .item!
                                          .quantityLimit,
                                    );
                                  } else {
                                    cartController.removeFromCart(cartIndex);
                                  }
                                }
                              },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          padding: EdgeInsets.all(
                            isCompact ? 4 : Dimensions.paddingSizeExtraSmall,
                          ),
                          child: Icon(
                            Icons.remove,
                            size: isCompact ? 16 : 20,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 3 : Dimensions.paddingSizeSmall,
                        ),
                        child:
                            cartController.isLoading &&
                                cartController.directAddCartItemIndex == index
                            ? SizedBox(
                                height: isCompact ? 16 : 20,
                                width: isCompact ? 16 : 20,
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).cardColor,
                                  strokeWidth: isCompact ? 1.5 : 2.0,
                                ),
                              )
                            : Text(
                                cartQty.toString(),
                                style: robotoMedium.copyWith(
                                  fontSize: isCompact ? 13 : 15,
                                  color: Theme.of(context).cardColor,
                                ),
                              ),
                      ),
                      InkWell(
                        onTap: cartController.isLoading
                            ? null
                            : () {
                                if (item.storeOpen == 0 || item.storeActive == false || (item.storeOpen == null && Get.find<StoreController>().store != null && item.storeId == Get.find<StoreController>().store!.id && (Get.find<StoreController>().store!.open == 0 || Get.find<StoreController>().store!.active == false))) {
                                  Get.find<ItemController>().showStoreClosedSnackbar();
                                } else {
                                  cartController.setDirectlyAddToCartIndex(index);
                                  cartController.setQuantity(
                                    true,
                                    cartIndex,
                                    cartController.cartList[cartIndex].stock,
                                    cartController
                                        .cartList[cartIndex]
                                        .quantityLimit,
                                  );
                                }
                              },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          padding: EdgeInsets.all(
                            isCompact ? 4 : Dimensions.paddingSizeExtraSmall,
                          ),
                          child: Icon(
                            Icons.add,
                            size: isCompact ? 16 : 20,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : InkWell(
                onTap: () {
                  if (item.storeOpen == 0 || item.storeActive == false || (item.storeOpen == null && Get.find<StoreController>().store != null && item.storeId == Get.find<StoreController>().store!.id && (Get.find<StoreController>().store!.open == 0 || Get.find<StoreController>().store!.active == false))) {
                    Get.find<ItemController>().showStoreClosedSnackbar();
                  } else {
                    cartController.setDirectlyAddToCartIndex(index);
                    Get.find<ItemController>().itemDirectlyAddToCart(
                      item,
                      context,
                    );
                  }
                },
                child:
                    child ??
                    Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).cardColor,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
              );
      },
    );
  }
}
