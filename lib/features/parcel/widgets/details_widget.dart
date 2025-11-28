import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/features/address/domain/models/address_model.dart';
import 'package:friday_sa/helper/auth_helper.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/styles.dart';

class DetailsWidget extends StatelessWidget {
  const DetailsWidget({super.key, required this.title, required this.address});
  final String title;
  final AddressModel? address;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: robotoMedium),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        Text(
          address!.contactPersonName ?? '',
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(
          address!.address ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
        ),
        Wrap(
          children: [
            (address!.streetNumber != null && address!.streetNumber!.isNotEmpty)
                ? Text(
                    '${'street_number'.tr}: ${address!.streetNumber!}, ',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).hintColor,
                    ),
                  )
                : const SizedBox(),
            (address!.house != null &&
                    address?.house != 'null' &&
                    address!.house!.isNotEmpty)
                ? Text(
                    '${'house'.tr}: ${address!.house!}, ',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).hintColor,
                    ),
                  )
                : const SizedBox(),
            (address!.floor != null && address!.floor!.isNotEmpty)
                ? Text(
                    '${'floor'.tr}: ${address!.floor!}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).hintColor,
                    ),
                  )
                : const SizedBox(),
          ],
        ),
        Text(
          address!.contactPersonNumber ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
        ),
        AuthHelper.isGuestLoggedIn()
            ? Text(
                address?.email ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
