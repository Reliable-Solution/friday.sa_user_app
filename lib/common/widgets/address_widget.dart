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
    if (address == null) {
      return const SizedBox();
    }

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
                      : Theme.of(context).primaryColor.withValues(alpha: 0.08),
                  width: isSelected ? 1.5 : 1,
                ),
              )
            : fromCheckout
            ? const BoxDecoration()
            : BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).disabledColor.withValues(alpha: 0.15),
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
        child: CustomInkWell(
          onTap: onTap as void Function()?,
          radius: fromDashBoard
              ? Dimensions.radiusDefault
              : fromCheckout
              ? 0
              : Dimensions.radiusDefault,
          child: Padding(
            padding: fromCheckout
                ? const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeExtraSmall,
                    vertical: 2,
                  )
                : const EdgeInsets.all(
                    Dimensions.paddingSizeDefault,
                  ),
            child: fromCheckout
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        address!.addressType == 'home'
                            ? Images.homeIcon
                            : address!.addressType == 'office'
                            ? Images.workIcon
                            : Images.otherIcon,
                        color: Theme.of(context).primaryColor,
                        height: 16,
                        width: 16,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              address!.addressType!.tr,
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).textTheme.bodyLarge!.color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              address!.address!,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: Theme.of(context).disabledColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Address type icon badge
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            ),
                            child: Image.asset(
                              address!.addressType == 'home'
                                  ? Images.homeIcon
                                  : address!.addressType == 'office'
                                  ? Images.workIcon
                                  : Images.otherIcon,
                              color: Theme.of(context).primaryColor,
                              height: ResponsiveHelper.isDesktop(context) ? 22 : 20,
                              width: ResponsiveHelper.isDesktop(context) ? 22 : 20,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall + 2),
                          // Address info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      address!.addressType!.tr,
                                      style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context).textTheme.bodyLarge!.color,
                                      ),
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'default'.tr,
                                          style: robotoMedium.copyWith(
                                            fontSize: Dimensions.fontSizeExtraSmall,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  address!.address!,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).disabledColor,
                                    height: 1.4,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Action buttons row
                      if (fromAddress) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall + 2),
                          child: Row(
                            children: [
                              Expanded(
                                child: Material(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall + 2),
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    onTap: onEditPressed as void Function()?,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.edit_outlined,
                                            color: Theme.of(context).primaryColor,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'edit'.tr,
                                            style: robotoMedium.copyWith(
                                              fontSize: Dimensions.fontSizeSmall,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeSmall),
                              Expanded(
                                child: Material(
                                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall + 2),
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    onTap: onRemovePressed as void Function()?,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.delete_outline,
                                            color: Theme.of(context).colorScheme.error,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'delete'.tr,
                                            style: robotoMedium.copyWith(
                                              fontSize: Dimensions.fontSizeSmall,
                                              color: Theme.of(context).colorScheme.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}


