import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/features/cart/controllers/cart_controller.dart';
import 'package:friday_sa/features/item/controllers/item_controller.dart';
import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/features/checkout/domain/models/place_order_body_model.dart';
import 'package:friday_sa/features/cart/domain/models/cart_model.dart';
import 'package:friday_sa/features/item/domain/models/item_model.dart';
import 'package:friday_sa/helper/price_converter.dart';
import 'package:friday_sa/helper/responsive_helper.dart';
import 'package:friday_sa/helper/route_helper.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/images.dart';
import 'package:friday_sa/util/styles.dart';
import 'package:friday_sa/common/widgets/confirmation_dialog.dart';
import 'package:friday_sa/common/widgets/custom_app_bar.dart';
import 'package:friday_sa/common/widgets/custom_button.dart';
import 'package:friday_sa/common/widgets/custom_snackbar.dart';
import 'package:friday_sa/common/widgets/menu_drawer.dart';
import 'package:friday_sa/features/checkout/screens/checkout_screen.dart';
import 'package:friday_sa/features/item/widgets/details_app_bar_widget.dart';
import 'package:friday_sa/features/item/widgets/details_web_view_widget.dart';
import 'package:friday_sa/features/item/widgets/item_image_view_widget.dart';
import 'package:friday_sa/features/item/widgets/item_title_view_widget.dart';

import '../../coupon/domain/models/coupon_model.dart';
import '../../store/controllers/store_controller.dart';
import '../../store/domain/models/store_model.dart' as store_model;

class ItemDetailsScreen extends StatefulWidget {
  const ItemDetailsScreen({
    super.key,
    required this.item,
    required this.inStorePage,
    this.isCampaign,
  });
  final Item? item;
  final bool inStorePage;
  final bool? isCampaign;

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  final Size size = Get.size;
  final GlobalKey<ScaffoldMessengerState> _globalKey = GlobalKey();
  final GlobalKey<DetailsAppBarWidgetState> _key = GlobalKey();
  int? _initialQuantity;
  List<int>? _initialVariationIndex;
  List<bool>? _initialAddOnActiveList;
  List<int?>? _initialAddOnQtyList;
  List<int>? _lastVariationIndex;
  int? _lastCartIndex;


  @override
  void initState() {
    super.initState();

    Get.find<ItemController>().getProductDetails(widget.item!);
    Get.find<ItemController>().setSelect(0, false);
    if (!widget.inStorePage) {
      Get.find<StoreController>().getStoreDetails(store_model.Store(id: widget.item!.storeId), false);
    }

    _initInitialState();
  }

  void _initInitialState() {
      ItemController itemController = Get.find<ItemController>();
    CartController cartController = Get.find<CartController>();
    if (itemController.cartIndex != -1 && itemController.cartIndex < cartController.cartList.length) {
      CartModel cart = cartController.cartList[itemController.cartIndex];
      _initialQuantity = cart.quantity;
      _initialVariationIndex = List.from(itemController.variationIndex!);
      _initialAddOnActiveList = List.from(itemController.addOnActiveList);
      _initialAddOnQtyList = List.from(itemController.addOnQtyList);
    } else {
      _initialQuantity = itemController.quantity;
      _initialVariationIndex = itemController.variationIndex != null ? List.from(itemController.variationIndex!) : null;
      _initialAddOnActiveList = List.from(itemController.addOnActiveList);
      _initialAddOnQtyList = List.from(itemController.addOnQtyList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(
      builder: (cartController) {
        return GetBuilder<ItemController>(
          builder: (itemController) {
            int? stock = 0;
            CartModel? cartModel;
            OnlineCart? cart;
            num priceWithAddons = 0;
            int? cartId = cartController.getCartId(itemController.cartIndex);
            if (itemController.item != null &&
                itemController.variationIndex != null) {
              List<String> variationList = [];
              for (
                int index = 0;
                index < itemController.item!.choiceOptions!.length;
                index++
              ) {
                if (itemController.variationIndex!.length > index && itemController.item!.choiceOptions![index].options!.isNotEmpty && itemController.item!.choiceOptions![index].options!.length > itemController.variationIndex![index]) {
                  variationList.add(
                    itemController
                        .item!
                        .choiceOptions![index]
                        .options![itemController.variationIndex![index]]
                        .replaceAll(' ', ''),
                  );
                }
              }
              String variationType = '';
              bool isFirst = true;
              for (var variation in variationList) {
                if (isFirst) {
                  variationType = '$variationType$variation';
                  isFirst = false;
                } else {
                  variationType = '$variationType-$variation';
                }
              }

              num? price = itemController.item!.price;
              Variation? variation;
              stock = itemController.item!.stock ?? 0;
              for (Variation v in itemController.item!.variations!) {
                if (v.type == variationType) {
                  price = v.price;
                  variation = v;
                  stock = v.stock;
                  break;
                }
              }

              num? discount =
                  (itemController.item!.availableDateStarts != null ||
                      itemController.item!.storeDiscount == 0)
                  ? itemController.item!.discount
                  : itemController.item!.storeDiscount;
              String? discountType =
                  (itemController.item!.availableDateStarts != null ||
                      itemController.item!.storeDiscount == 0)
                  ? itemController.item!.discountType
                  : 'percent';
              num priceWithDiscount = PriceConverter.convertWithDiscount(
                price,
                discount,
                discountType,
              ) ?? 0;
              num priceWithQuantity =
                  priceWithDiscount * itemController.quantity!;
              num addonsCost = 0;
              List<AddOn> addOnIdList = [];
              List<AddOns> addOnsList = [];
              for (
                int index = 0;
                index < itemController.item!.addOns!.length;
                index++
              ) {
                if (itemController.addOnActiveList.length > index && itemController.addOnActiveList[index]) {
                  addonsCost =
                      addonsCost +
                      (itemController.item!.addOns![index].price! *
                          (itemController.addOnQtyList.length > index ? itemController.addOnQtyList[index]! : 1));
                  addOnIdList.add(
                    AddOn(
                      id: itemController.item!.addOns![index].id,
                      quantity: itemController.addOnQtyList.length > index ? itemController.addOnQtyList[index] : 1,
                    ),
                  );
                  addOnsList.add(itemController.item!.addOns![index]);
                }
              }

              cartModel = CartModel(
                null,
                price,
                priceWithDiscount,
                variation != null ? [variation] : [],
                [],
                price! -
                    PriceConverter.convertWithDiscount(
                      price,
                      discount,
                      discountType,
                    )!,
                itemController.quantity,
                addOnIdList,
                addOnsList,
                itemController.item!.availableDateStarts != null,
                stock,
                itemController.item,
                itemController.item?.quantityLimit,
              );

              List<int?> listOfAddOnId = _getSelectedAddonIds(
                addOnIdList: addOnIdList,
              );
              List<int?> listOfAddOnQty = _getSelectedAddonQtnList(
                addOnIdList: addOnIdList,
              );

              cart = OnlineCart(
                cartId,
                widget.item!.id,
                null,
                priceWithDiscount.toString(),
                '',
                variation != null ? [variation] : [],
                null,
                (itemController.cartIndex != -1 && itemController.cartIndex < cartController.cartList.length)
                    ? cartController.cartList[itemController.cartIndex].quantity
                    : itemController.quantity,
                listOfAddOnId,
                addOnsList,
                listOfAddOnQty,
                'Item',
              );
              priceWithAddons =
                  priceWithQuantity +
                  (Get.find<SplashController>()
                          .configModel!
                          .moduleConfig!
                          .module!
                          .addOn!
                      ? addonsCost
                      : 0);

              if (_initialQuantity == null) {
                _initInitialState();
              }

              if (itemController.variationIndex != null) {
                if (_lastVariationIndex == null || !_areListsEqual(_lastVariationIndex!, itemController.variationIndex!)) {
                  _lastVariationIndex = List.from(itemController.variationIndex!);
                  _initInitialState();
                }
              }

              if (_lastCartIndex == null || _lastCartIndex != itemController.cartIndex) {
                _lastCartIndex = itemController.cartIndex;
                _initInitialState();
              }
            }

            bool isChanged = false;
            if (itemController.item != null && _initialQuantity != null) {
              int currentQuantity = (itemController.cartIndex != -1 && itemController.cartIndex < cartController.cartList.length)
                  ? cartController.cartList[itemController.cartIndex].quantity!
                  : itemController.quantity!;

              bool variationChanged = false;
              if (_initialVariationIndex != null && itemController.variationIndex != null) {
                if (!_areListsEqual(_initialVariationIndex!, itemController.variationIndex!)) {
                  variationChanged = true;
                }
              }

              bool addOnChanged = false;
              for (int i = 0; i < _initialAddOnActiveList!.length; i++) {
                if (itemController.addOnActiveList.length > i && (_initialAddOnActiveList![i] != itemController.addOnActiveList[i] ||
                    (itemController.addOnQtyList.length > i && _initialAddOnQtyList![i] != null && itemController.addOnQtyList[i] != null && _initialAddOnQtyList![i] != itemController.addOnQtyList[i]))) {
                  addOnChanged = true;
                  break;
                }
              }

              isChanged = (currentQuantity != _initialQuantity) || variationChanged || addOnChanged;
            }

            return Scaffold(
              key: _globalKey,
              backgroundColor: Theme.of(context).cardColor,
              endDrawer: const MenuDrawer(),
              endDrawerEnableOpenDragGesture: false,
              appBar: ResponsiveHelper.isDesktop(context)
                  ? const CustomAppBar(title: '')
                  : DetailsAppBarWidget(key: _key),
              body: SafeArea(
                child: (itemController.item != null)
                    ? ResponsiveHelper.isDesktop(context)
                          ? DetailsWebViewWidget(
                              cartModel: cartModel,
                              stock: stock,
                              priceWithAddOns: priceWithAddons,
                              cart: cart,
                            )
                          : Column(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.all(
                                      Dimensions.paddingSizeSmall,
                                    ),
                                    physics: const BouncingScrollPhysics(),
                                    child: Center(
                                      child: SizedBox(
                                        width: Dimensions.webMaxWidth,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ItemImageViewWidget(
                                              item: itemController.item,
                                              isCampaign:
                                                  widget.isCampaign ?? false,
                                            ),
                                            const SizedBox(height: 20),

                                            Builder(
                                              builder: (context) {
                                                return ItemTitleViewWidget(
                                                  item: itemController.item,
                                                  inStorePage:
                                                      widget.inStorePage,
                                                  isCampaign:
                                                      itemController
                                                          .item!
                                                          .availableDateStarts !=
                                                      null,
                                                  inStock:
                                                      Get.find<
                                                            SplashController
                                                          >()
                                                          .configModel!
                                                          .moduleConfig!
                                                          .module!
                                                          .stock! &&
                                                      stock! <= 0,
                                                );
                                              },
                                            ),
                                            const Divider(
                                              height: 20,
                                              thickness: 2,
                                            ),

                                            // Variation
                                            ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: itemController
                                                  .item!
                                                  .choiceOptions!
                                                  .length,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      itemController
                                                          .item!
                                                          .choiceOptions![index]
                                                          .title!,
                                                      style: robotoMedium
                                                          .copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeLarge,
                                                          ),
                                                    ),
                                                    const SizedBox(
                                                      height: Dimensions
                                                          .paddingSizeExtraSmall,
                                                    ),
                                                    GridView.builder(
                                                      gridDelegate:
                                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisCount: 3,
                                                            crossAxisSpacing:
                                                                20,
                                                            mainAxisSpacing: 10,
                                                            childAspectRatio:
                                                                1 / 0.25,
                                                          ),
                                                      shrinkWrap: true,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemCount: itemController
                                                          .item!
                                                          .choiceOptions![index]
                                                          .options!
                                                          .length,
                                                      itemBuilder: (context, i) {
                                                        return InkWell(
                                                          onTap: () {
                                                            itemController
                                                                .setCartVariationIndex(
                                                                  index,
                                                                  i,
                                                                  itemController
                                                                      .item,
                                                                );
                                                          },
                                                          child: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      Dimensions
                                                                          .paddingSizeExtraSmall,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  itemController
                                                                          .variationIndex![index] !=
                                                                      i
                                                                  ? Theme.of(
                                                                      context,
                                                                    ).disabledColor
                                                                  : Theme.of(
                                                                      context,
                                                                    ).primaryColor,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    5,
                                                                  ),
                                                              border:
                                                                  itemController
                                                                          .variationIndex![index] !=
                                                                      i
                                                                  ? Border.all(
                                                                      color: Theme.of(
                                                                        context,
                                                                      ).disabledColor,
                                                                      width: 2,
                                                                    )
                                                                  : null,
                                                            ),
                                                            child: Text(
                                                              itemController
                                                                  .item!
                                                                  .choiceOptions![index]
                                                                  .options![i]
                                                                  .trim(),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: robotoRegular.copyWith(
                                                                color:
                                                                    itemController
                                                                            .variationIndex![index] !=
                                                                        i
                                                                    ? Colors
                                                                          .black
                                                                    : Colors
                                                                          .white,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          index !=
                                                              itemController
                                                                      .item!
                                                                      .choiceOptions!
                                                                      .length -
                                                                  1
                                                          ? Dimensions
                                                                .paddingSizeLarge
                                                          : 0,
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                            itemController
                                                    .item!
                                                    .choiceOptions!
                                                    .isNotEmpty
                                                ? const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeLarge,
                                                  )
                                                : const SizedBox(),

                                            // Quantity
                                            GetBuilder<CartController>(
                                              builder: (cartController) {
                                                return Row(
                                                  children: [
                                                    Text(
                                                      'quantity'.tr,
                                                      style: robotoMedium
                                                          .copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeLarge,
                                                          ),
                                                    ),
                                                    const Expanded(
                                                      child: SizedBox(),
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(
                                                          context,
                                                        ).disabledColor,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              5,
                                                            ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          InkWell(
                                                            onTap:
                                                                cartController
                                                                    .isLoading
                                                                ? null
                                                                : () {
                                                                     if (itemController.cartIndex != -1 && itemController.cartIndex < cartController.cartList.length) {
                                                                       if (cartController.cartList[itemController.cartIndex].quantity! > 1) {
                                                                         cartController.setQuantity(
                                                                           false,
                                                                           itemController.cartIndex,
                                                                           stock,
                                                                           cartController.cartList[itemController.cartIndex].quantity,
                                                                         );
                                                                       } else {
                                                                          cartController.removeFromCart(itemController.cartIndex, item: itemController.item);
                                                                          itemController.setQuantity(false, stock, itemController.item!.quantityLimit);
                                                                       }
                                                                     } else {
                                                                      if (itemController.quantity! > 0) {
                                                                        itemController.setQuantity(
                                                                          false,
                                                                          stock,
                                                                          itemController.item!.quantityLimit,
                                                                        );
                                                                      }
                                                                    }
                                                                  },
                                                            child: Padding(
                                                              padding: EdgeInsets.symmetric(
                                                                horizontal:
                                                                    Dimensions
                                                                        .paddingSizeSmall,
                                                                vertical: Dimensions
                                                                    .paddingSizeExtraSmall,
                                                              ),
                                                              child: Icon(
                                                                Icons.remove,
                                                                size: 20,
                                                                color: (itemController.cartIndex == -1 && itemController.quantity == 0)
                                                                    ? Theme.of(context).disabledColor
                                                                    : Colors.black,
                                                              ),
                                                            ),
                                                          ),
                                                           Text(
                                                             (itemController.cartIndex != -1 && itemController.cartIndex < cartController.cartList.length)
                                                                 ? cartController
                                                                       .cartList[itemController
                                                                           .cartIndex]
                                                                       .quantity
                                                                       .toString()
                                                                 : itemController
                                                                       .quantity
                                                                       .toString(),
                                                             style: robotoMedium
                                                                 .copyWith(
                                                                   fontSize:
                                                                       Dimensions
                                                                           .fontSizeExtraLarge,
                                                                 ),
                                                           ),
                                                           InkWell(
                                                             onTap:
                                                                 cartController
                                                                     .isLoading
                                                                 ? null
                                                                 : () =>
                                                                       (itemController.cartIndex != -1 && itemController.cartIndex < cartController.cartList.length)
                                                                       ? cartController.setQuantity(
                                                                           true,
                                                                           itemController
                                                                               .cartIndex,
                                                                           stock,
                                                                           cartController
                                                                               .cartList[itemController.cartIndex]
                                                                               .quantityLimit,
                                                                         )
                                                                      : itemController.setQuantity(
                                                                          true,
                                                                          stock,
                                                                          itemController
                                                                              .item!
                                                                              .quantityLimit,
                                                                        ),
                                                            child: const Padding(
                                                              padding: EdgeInsets.symmetric(
                                                                horizontal:
                                                                    Dimensions
                                                                        .paddingSizeSmall,
                                                                vertical: Dimensions
                                                                        .paddingSizeExtraSmall,
                                                              ),
                                                              child: Icon(
                                                                Icons.add,
                                                                size: 20,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                            const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeLarge,
                                            ),

                                            Row(
                                              children: [
                                                Text(
                                                  '${'total_amount'.tr}:',
                                                  style: robotoMedium.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeLarge,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeExtraSmall,
                                                ),
                                                Text(
                                                  PriceConverter.convertPrice(
                                                    (itemController.cartIndex !=
                                                            -1 && itemController.cartIndex < Get.find<CartController>().cartList.length)
                                                        ? _getItemDetailsDiscountPrice(
                                                            cart:
                                                                Get.find<
                                                                      CartController
                                                                    >()
                                                                    .cartList[itemController
                                                                    .cartIndex],
                                                          )
                                                        : priceWithAddons,
                                                  ),
                                                  style: robotoBold.copyWith(
                                                    color: Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                    fontSize: Dimensions
                                                        .fontSizeLarge,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: Dimensions
                                                  .paddingSizeExtraLarge,
                                            ),

                                            itemController
                                                    .item!
                                                    .isPrescriptionRequired!
                                                ? Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: Dimensions
                                                              .paddingSizeSmall,
                                                          vertical: Dimensions
                                                              .paddingSizeExtraSmall,
                                                        ),
                                                    margin:
                                                        const EdgeInsets.only(
                                                          bottom: Dimensions
                                                              .paddingSizeSmall,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .error
                                                          .withValues(
                                                            alpha: 0.1,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            Dimensions
                                                                .radiusSmall,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      '* ${'prescription_required'.tr}',
                                                      style: robotoRegular
                                                          .copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeSmall,
                                                            color: Theme.of(
                                                              context,
                                                            ).colorScheme.error,
                                                          ),
                                                    ),
                                                  )
                                                : const SizedBox(),

                                            (itemController.item!.description !=
                                                        null &&
                                                    itemController
                                                        .item!
                                                        .description!
                                                        .isNotEmpty)
                                                ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'description'.tr,
                                                        style: robotoMedium,
                                                      ),
                                                      const SizedBox(
                                                        height: Dimensions
                                                            .paddingSizeExtraSmall,
                                                      ),
                                                      Text(
                                                        itemController
                                                            .item!
                                                            .description!,
                                                        style: robotoRegular,
                                                      ),
                                                      const SizedBox(
                                                        height: Dimensions
                                                            .paddingSizeLarge,
                                                      ),
                                                    ],
                                                  )
                                                : const SizedBox(),

                                            (widget.item!.nutritionsName !=
                                                        null &&
                                                    widget
                                                        .item!
                                                        .nutritionsName!
                                                        .isNotEmpty)
                                                ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'nutrition_details'.tr,
                                                        style: robotoMedium,
                                                      ),
                                                      const SizedBox(
                                                        height: Dimensions
                                                            .paddingSizeExtraSmall,
                                                      ),
                                                      Wrap(
                                                        children: List.generate(
                                                          widget
                                                              .item!
                                                              .nutritionsName!
                                                              .length,
                                                          (index) {
                                                            return Text(
                                                              '${widget.item!.nutritionsName![index]}${widget.item!.nutritionsName!.length - 1 == index ? '.' : ', '}',
                                                              style: robotoRegular.copyWith(
                                                                color:
                                                                    Theme.of(
                                                                          context,
                                                                        )
                                                                        .textTheme
                                                                        .bodyLarge!
                                                                        .color
                                                                        ?.withValues(
                                                                          alpha:
                                                                              0.5,
                                                                        ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: Dimensions
                                                            .paddingSizeLarge,
                                                      ),
                                                    ],
                                                  )
                                                : const SizedBox(),

                                            (widget.item!.allergiesName !=
                                                        null &&
                                                    widget
                                                        .item!
                                                        .allergiesName!
                                                        .isNotEmpty)
                                                ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'allergic_ingredients'
                                                            .tr,
                                                        style: robotoMedium,
                                                      ),
                                                      const SizedBox(
                                                        height: Dimensions
                                                            .paddingSizeExtraSmall,
                                                      ),
                                                      Wrap(
                                                        children: List.generate(
                                                          widget
                                                              .item!
                                                              .allergiesName!
                                                              .length,
                                                          (index) {
                                                            return Text(
                                                              '${widget.item!.allergiesName![index]}${widget.item!.allergiesName!.length - 1 == index ? '.' : ', '}',
                                                              style: robotoRegular.copyWith(
                                                                color:
                                                                    Theme.of(
                                                                          context,
                                                                        )
                                                                        .textTheme
                                                                        .bodyLarge!
                                                                        .color
                                                                        ?.withValues(
                                                                          alpha:
                                                                              0.5,
                                                                        ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: Dimensions
                                                            .paddingSizeLarge,
                                                      ),
                                                    ],
                                                  )
                                                : const SizedBox(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                GetBuilder<StoreController>(
                                  builder: (storeController) {
                                    bool isStoreClosed = (itemController.item!.storeOpen == 0 || itemController.item!.storeActive == false) || (storeController.store != null && (storeController.store!.open == 0 || storeController.store!.active == false));

                                    return GetBuilder<CartController>(
                                      builder: (cartController) {
                                        return Container(
                                          width: Dimensions.webMaxWidth,
                                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: CustomButton(
                                                  isLoading: cartController.isLoading,
                                                  radius: Dimensions.radiusLarge,
                                                  height: 50,
                                                  color: isStoreClosed ? Theme.of(context).disabledColor : (itemController.cartIndex != -1 && itemController.cartIndex < cartController.cartList.length && !isChanged) ? Theme.of(context).disabledColor : Theme.of(context).primaryColor,
                                                  textColor: isStoreClosed ? Theme.of(context).cardColor : (itemController.cartIndex != -1 && itemController.cartIndex < cartController.cartList.length && !isChanged) ? Theme.of(context).cardColor : Colors.white,
                                                  buttonText: isStoreClosed
                                                      ? 'this_store_is_closed_now'.tr
                                                      : (Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! && stock! <= 0)
                                                      ? 'out_of_stock'.tr
                                                      : itemController.item!.availableDateStarts != null
                                                      ? 'order_now'.tr
                                                      : (itemController.cartIndex != -1 && itemController.cartIndex < cartController.cartList.length)
                                                      ? 'update_in_cart'.tr
                                                      : 'add_to_cart'.tr,
                                                  onPressed: isStoreClosed ? null :
                                                      (!Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! || (stock! > 0 && (((itemController.cartIndex != -1 && itemController.cartIndex < cartController.cartList.length) && isChanged) || ((itemController.cartIndex == -1 || itemController.cartIndex >= cartController.cartList.length) && itemController.quantity! > 0))))
                                                      ? () async {
                                                      if (!Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! || stock! > 0) {
                                                        if (itemController.item!.availableDateStarts != null) {
                                                          Get.toNamed(RouteHelper.getCheckoutRoute('campaign'), arguments: CheckoutScreen(storeId: null, fromCart: false, cartList: [cartModel]));
                                                        } else {
                                                          if (cartController.existAnotherStoreItem(cartModel!.item!.storeId, Get.find<SplashController>().module == null ? Get.find<SplashController>().cacheModule!.id : Get.find<SplashController>().module!.id)) {
                                                            Get.dialog(ConfirmationDialog(
                                                              icon: Images.warning,
                                                              title: 'are_you_sure_to_reset'.tr,
                                                              description: Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText! ? 'if_you_continue'.tr : 'if_you_continue_without_another_store'.tr,
                                                              onYesPressed: () {
                                                                Get.back();
                                                                cartController.clearCartOnline().then((success) async {
                                                                  if (success) {
                                                                    await cartController.addToCartOnline(cart!);
                                                                    itemController.setExistInCart(widget.item, null);
                                                                  }
                                                                });
                                                              },
                                                            ), barrierDismissible: false);
                                                          } else {
                                                            if (itemController.cartIndex == -1 || itemController.cartIndex >= cartController.cartList.length) {
                                                              await cartController.addToCartOnline(cart!).then((success) {
                                                                if (success) {
                                                                  itemController.setExistInCart(widget.item, null);
                                                                  _key.currentState!.shake();
                                                                  _initInitialState();
                                                                  setState(() {});
                                                                }
                                                              });
                                                            } else {
                                                              await cartController.updateCartOnline(cart!).then((success) {
                                                                if (success) {
                                                                  _key.currentState!.shake();
                                                                  _initInitialState();
                                                                  setState(() {});
                                                                }
                                                              });
                                                            }
                                                          }
                                                        }
                                                      }
                                                    } : null,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            )
                    : const Center(child: CircularProgressIndicator()),
              ),
            );
          },
        );
      },
    );
  }

  List<int?> _getSelectedAddonIds({required List<AddOn> addOnIdList}) {
    List<int?> listOfAddOnId = [];
    for (var addOn in addOnIdList) {
      listOfAddOnId.add(addOn.id);
    }
    return listOfAddOnId;
  }

  List<int?> _getSelectedAddonQtnList({required List<AddOn> addOnIdList}) {
    List<int?> listOfAddOnQty = [];
    for (var addOn in addOnIdList) {
      listOfAddOnQty.add(addOn.quantity);
    }
    return listOfAddOnQty;
  }

  num _getItemDetailsDiscountPrice({required CartModel cart}) {
    num discountedPrice = 0;

    num? discount = cart.item!.storeDiscount == 0
        ? cart.item!.discount!
        : cart.item!.storeDiscount!;
    String? discountType = (cart.item!.storeDiscount == 0)
        ? cart.item!.discountType
        : 'percent';
    String variationType = cart.variation != null && cart.variation!.isNotEmpty
        ? cart.variation![0].type!
        : '';

    if (cart.variation != null && cart.variation!.isNotEmpty) {
      for (Variation variation in cart.item!.variations!) {
        if (variation.type == variationType) {
          discountedPrice =
              PriceConverter.convertWithDiscount(
                variation.price,
                discount,
                discountType,
              )! *
              cart.quantity!;
          break;
        }
      }
    } else {
      discountedPrice =
          PriceConverter.convertWithDiscount(
            cart.item!.price,
            discount,
            discountType,
          )! *
          cart.quantity!;
    }

    return discountedPrice;
  }

  bool _areListsEqual(List list1, List list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  Widget _quantityButton(BuildContext context, IconData icon, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: isActive ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.2),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class QuantityButton extends StatelessWidget {
  const QuantityButton({
    super.key,
    required this.isIncrement,
    required this.quantity,
    required this.stock,
    required this.isExistInCart,
    required this.cartIndex,
    this.isCartWidget = false,
    this.quantityLimit,
    required this.cartController,
  });
  final bool isIncrement;
  final int? quantity;
  final bool isCartWidget;
  final int? stock;
  final bool isExistInCart;
  final int cartIndex;
  final int? quantityLimit;
  final CartController cartController;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: cartController.isLoading
          ? null
          : () {
              if (isExistInCart) {
                if (!isIncrement && quantity! > 1) {
                  Get.find<CartController>().setQuantity(
                    false,
                    cartIndex,
                    stock,
                    quantityLimit,
                  );
                } else if (!isIncrement && quantity! == 1) {
                  Get.find<CartController>().removeFromCart(cartIndex);
                  Get.find<ItemController>().setQuantity(false, stock, quantityLimit);
                } else if (isIncrement && quantity! >= 0) {
                  if (quantityLimit != null && quantityLimit != 0 && quantity! >= quantityLimit!) {
                    showCustomSnackBar('${'maximum_quantity_limit'.tr} $quantityLimit');
                  } else if (quantity! < stock! ||
                      !Get.find<SplashController>()
                          .configModel!
                          .moduleConfig!
                          .module!
                          .stock!) {
                    Get.find<CartController>().setQuantity(
                      true,
                      cartIndex,
                      stock,
                      quantityLimit,
                    );
                  } else {
                    showCustomSnackBar('out_of_stock'.tr);
                  }
                }
              } else {
                if (!isIncrement && quantity! > 0) {
                  Get.find<ItemController>().setQuantity(
                    false,
                    stock,
                    quantityLimit,
                  );
                } else if (isIncrement && quantity! >= 0) {
                  if (quantity! < stock! ||
                      !Get.find<SplashController>()
                          .configModel!
                          .moduleConfig!
                          .module!
                          .stock!) {
                    Get.find<ItemController>().setQuantity(
                      true,
                      stock,
                      quantityLimit,
                    );
                  } else {
                    showCustomSnackBar('out_of_stock'.tr);
                  }
                }
              }
            },
      child: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (quantity! == 0 && !isIncrement) || cartController.isLoading
              ? Theme.of(context).disabledColor
              : Theme.of(context).primaryColor,
        ),
        child: Center(
          child: Icon(
            isIncrement ? Icons.add : Icons.remove,
            color: Colors.white,
            size: isCartWidget ? 26 : 20,
          ),
        ),
      ),
    );
  }
}
