import 'package:friday_sa/common/widgets/custom_ink_well.dart';
import 'package:friday_sa/features/address/domain/models/address_model.dart';
import 'package:friday_sa/helper/responsive_helper.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/images.dart';
import 'package:friday_sa/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressWidget extends StatelessWidget {
  const AddressWidget({
    super.key,
    required this.address,
    required this.fromAddress,
    this.onRemovePressed,
    this.onEditPressed,
    this.onTap,
    this.fromCheckout = false,
    this.isSelected = false,
    this.fromDashBoard = false,
  });
  final AddressModel? address;
  final bool fromAddress;
  final bool fromCheckout;
  final Function? onRemovePressed;
  final Function? onEditPressed;
  final Function? onTap;
  final bool isSelected;
  final bool fromDashBoard;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: fromCheckout ? 0 : Dimensions.paddingSizeSmall,
      ),
      child: Container(
        decoration: fromDashBoard
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  width: isSelected ? 1 : 0,
                ),
              )
            : fromCheckout
            ? const BoxDecoration()
            : BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).cardColor,
                  width: isSelected ? 0.5 : 0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
        child: CustomInkWell(
          onTap: onTap as void Function()?,
          radius: fromDashBoard
              ? Dimensions.radiusDefault
              : fromCheckout
              ? 0
              : Dimensions.radiusSmall,
          child: Padding(
            padding: EdgeInsets.all(
              ResponsiveHelper.isDesktop(context)
                  ? Dimensions.paddingSizeDefault
                  : Dimensions.paddingSizeSmall,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            address!.addressType == 'home'
                                ? Images.homeIcon
                                : address!.addressType == 'office'
                                ? Images.workIcon
                                : Images.otherIcon,
                            color: Theme.of(context).primaryColor,
                            height: ResponsiveHelper.isDesktop(context)
                                ? 25
                                : 20,
                            width: ResponsiveHelper.isDesktop(context)
                                ? 25
                                : 20,
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Text(
                            address!.addressType!.tr,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Text(
                        address!.address!,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).disabledColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                fromAddress
                    ? IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.blueGrey,
                          size: 25,
                        ),
                        onPressed: onEditPressed as void Function()?,
                      )
                    : const SizedBox(),
                fromAddress
                    ? IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 25,
                        ),
                        onPressed: onRemovePressed as void Function()?,
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
