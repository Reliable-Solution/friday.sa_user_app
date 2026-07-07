import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:friday_sa/common/widgets/address_widget.dart';
import 'package:friday_sa/features/address/controllers/address_controller.dart';
import 'package:friday_sa/features/address/domain/models/address_model.dart';
import 'package:friday_sa/features/checkout/controllers/checkout_controller.dart';
import 'package:friday_sa/features/location/controllers/location_controller.dart';
import 'package:friday_sa/helper/address_helper.dart';
import 'package:friday_sa/helper/auth_helper.dart';
import 'package:friday_sa/helper/responsive_helper.dart';
import 'package:friday_sa/helper/route_helper.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/styles.dart';
import 'package:friday_sa/common/widgets/custom_dropdown.dart';
import 'package:friday_sa/common/widgets/custom_text_field.dart';
import 'package:friday_sa/features/checkout/widgets/guest_delivery_address.dart';

class DeliverySection extends StatelessWidget {
  const DeliverySection({
    super.key,
    required this.checkoutController,
    required this.address,
    required this.addressList,
    required this.guestNameTextEditingController,
    required this.guestNumberTextEditingController,
    required this.guestNumberNode,
    required this.guestEmailController,
    required this.guestEmailNode,
  });
  final CheckoutController checkoutController;
  final List<AddressModel> address;
  final List<DropdownItem<int>> addressList;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;

  @override
  Widget build(BuildContext context) {
    bool isGuestLoggedIn = AuthHelper.isGuestLoggedIn();
    bool takeAway = (checkoutController.orderType == 'take_away');
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return Column(
      children: [
        isGuestLoggedIn
            ? GuestDeliveryAddress(
                checkoutController: checkoutController,
                guestNumberNode: guestNumberNode,
                guestNameTextEditingController: guestNameTextEditingController,
                guestNumberTextEditingController:
                    guestNumberTextEditingController,
                guestEmailController: guestEmailController,
                guestEmailNode: guestEmailNode,
              )
            : !takeAway
            ? Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('deliver_to'.tr, style: robotoMedium),
                        TextButton.icon(
                          onPressed: () async {
                            var newAddress = await Get.toNamed(
                              RouteHelper.getAddAddressRoute(
                                true,
                                false,
                                checkoutController.store!.zoneId,
                              ),
                            );
                            if (newAddress != null) {
                              checkoutController.setAddressLoading(true);
                              if (newAddress.zoneData == null || newAddress.zoneData!.isEmpty) {
                                var zoneResp = await Get.find<LocationController>().getZone(
                                  newAddress.latitude,
                                  newAddress.longitude,
                                  false,
                                );
                                if (zoneResp.isSuccess) {
                                  newAddress.zoneData = zoneResp.zoneData;
                                }
                              }

                              List<AddressModel> tempAddressList = [];
                              if (AddressHelper.getUserAddressFromSharedPref() != null) {
                                tempAddressList.add(AddressHelper.getUserAddressFromSharedPref()!);
                              }
                              var originalAddressList = Get.find<AddressController>().addressList;
                              if (originalAddressList != null && checkoutController.store != null) {
                                for (int index = 0; index < originalAddressList.length; index++) {
                                  if (originalAddressList[index].zoneIds!.contains(checkoutController.store!.zoneId)) {
                                    tempAddressList.add(originalAddressList[index]);
                                  }
                                }
                              }

                              int newIndex = tempAddressList.indexWhere((element) =>
                                (element.id != null && element.id == newAddress.id) ||
                                (element.latitude == newAddress.latitude && element.longitude == newAddress.longitude)
                              );

                              if (newIndex != -1) {
                                checkoutController.setAddressIndex(newIndex);
                              }

                              await checkoutController.getDistanceInKM(
                                LatLng(
                                  double.parse(newAddress.latitude),
                                  double.parse(newAddress.longitude),
                                ),
                                LatLng(
                                  double.parse(
                                    checkoutController.store!.latitude!,
                                  ),
                                  double.parse(
                                    checkoutController.store!.longitude!,
                                  ),
                                ),
                              );
                              checkoutController.setAddressLoading(false);
                              checkoutController.streetNumberController.text =
                                  newAddress.streetNumber ?? '';
                              checkoutController.houseController.text =
                                  newAddress.house ?? '';
                              checkoutController.floorController.text =
                                  newAddress.floor ?? '';
                            }
                          },
                          icon: const Icon(Icons.add, size: 20),
                          label: Text(
                            'add_new'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                        ),
                      ],
                    ),
                    address.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error),
                                const SizedBox(width: Dimensions.paddingSizeSmall),
                                Expanded(
                                  child: Text(
                                    'please_setup_your_delivery_address_first'.tr,
                                    style: robotoMedium.copyWith(color: Theme.of(context).colorScheme.error),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : isDesktop
                            ? Stack(
                                children: [
                                  Container(
                                    constraints: const BoxConstraints(
                                      minHeight: 90,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        Dimensions.radiusDefault,
                                      ),
                                      color: Theme.of(
                                        context,
                                      ).primaryColor.withValues(alpha: 0.1),
                                    ),
                                    child: Container(
                                      height: 45,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: Dimensions.paddingSizeExtraSmall,
                                        horizontal:
                                            Dimensions.paddingSizeExtraSmall,
                                      ),
                                      child: AddressWidget(
                                        address:
                                            address[checkoutController
                                                .addressIndex!],
                                        fromAddress: false,
                                        fromCheckout: true,
                                      ),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: PopupMenuButton(
                                        position: PopupMenuPosition.under,
                                        icon: const Icon(Icons.keyboard_arrow_down),
                                        onSelected: (value) {},
                                        itemBuilder: (context) => List.generate(
                                          address.length,
                                          (index) => PopupMenuItem(
                                            child: InkWell(
                                              onTap: () async {
                                                double? originLat = double.tryParse(address[index].latitude ?? '');
                                                double? originLng = double.tryParse(address[index].longitude ?? '');
                                                double? destLat = double.tryParse(checkoutController.store?.latitude ?? '');
                                                double? destLng = double.tryParse(checkoutController.store?.longitude ?? '');
                                                if (originLat != null && originLng != null && destLat != null && destLng != null) {
                                                  checkoutController.setAddressLoading(true);
                                                  if (address[index].zoneData == null || address[index].zoneData!.isEmpty) {
                                                    var zoneResp = await Get.find<LocationController>().getZone(
                                                      address[index].latitude,
                                                      address[index].longitude,
                                                      false,
                                                    );
                                                    if (zoneResp.isSuccess) {
                                                      address[index].zoneData = zoneResp.zoneData;
                                                    }
                                                  }
                                                  await checkoutController.getDistanceInKM(
                                                    LatLng(originLat, originLng),
                                                    LatLng(destLat, destLng),
                                                  );
                                                  checkoutController.setAddressLoading(false);
                                                }
                                                checkoutController.setAddressIndex(
                                                  index,
                                                );
                                                checkoutController
                                                        .streetNumberController
                                                        .text =
                                                    address[checkoutController
                                                            .addressIndex!]
                                                        .streetNumber ??
                                                    '';
                                                checkoutController
                                                        .houseController
                                                        .text =
                                                    address[checkoutController
                                                            .addressIndex!]
                                                        .house ??
                                                    '';
                                                checkoutController
                                                        .floorController
                                                        .text =
                                                    address[checkoutController
                                                            .addressIndex!]
                                                        .floor ??
                                                    '';
                                                Navigator.pop(context);
                                              },
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    height: 20,
                                                    width: 20,
                                                    padding: const EdgeInsets.all(
                                                      3,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color:
                                                            checkoutController
                                                                    .addressIndex ==
                                                                index
                                                            ? Theme.of(
                                                                context,
                                                              ).primaryColor
                                                            : Theme.of(
                                                                context,
                                                              ).disabledColor,
                                                      ),
                                                    ),
                                                    child:
                                                        checkoutController
                                                                .addressIndex ==
                                                            index
                                                        ? Container(
                                                            height: 15,
                                                            width: 15,
                                                            decoration:
                                                                BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: Theme.of(
                                                                    context,
                                                                  ).primaryColor,
                                                                ),
                                                          )
                                                        : const SizedBox(),
                                                  ),
                                                  const SizedBox(
                                                    width:
                                                        Dimensions.paddingSizeSmall,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          address[index]
                                                              .addressType!
                                                              .tr,
                                                          style: robotoMedium
                                                              .copyWith(
                                                                fontSize: Dimensions
                                                                    .fontSizeSmall,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: Dimensions
                                                              .paddingSizeExtraSmall,
                                                        ),
                                                        Text(
                                                          address[index].address!,
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow.ellipsis,
                                                          style: robotoRegular.copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeExtraSmall,
                                                            color: Theme.of(
                                                              context,
                                                            ).disabledColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                constraints: BoxConstraints(
                                  minHeight: ResponsiveHelper.isDesktop(context)
                                      ? 90
                                      : 75,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault,
                                  ),
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.1),
                                ),
                                child: CustomDropdown<int>(
                                  onChange: (int? value, int index) async {
                                    double? originLat = double.tryParse(address[index].latitude ?? '');
                                    double? originLng = double.tryParse(address[index].longitude ?? '');
                                    double? destLat = double.tryParse(checkoutController.store?.latitude ?? '');
                                    double? destLng = double.tryParse(checkoutController.store?.longitude ?? '');
                                    if (originLat != null && originLng != null && destLat != null && destLng != null) {
                                      checkoutController.setAddressLoading(true);
                                      if (address[index].zoneData == null || address[index].zoneData!.isEmpty) {
                                        var zoneResp = await Get.find<LocationController>().getZone(
                                          address[index].latitude,
                                          address[index].longitude,
                                          false,
                                        );
                                        if (zoneResp.isSuccess) {
                                          address[index].zoneData = zoneResp.zoneData;
                                        }
                                      }
                                      await checkoutController.getDistanceInKM(
                                        LatLng(originLat, originLng),
                                        LatLng(destLat, destLng),
                                      );
                                      checkoutController.setAddressLoading(false);
                                    }
                                    checkoutController.setAddressIndex(index);

                                    checkoutController.streetNumberController.text =
                                        address[checkoutController.addressIndex!]
                                            .streetNumber ??
                                        '';
                                    checkoutController.houseController.text =
                                        address[checkoutController.addressIndex!]
                                            .house ??
                                        '';
                                    checkoutController.floorController.text =
                                        address[checkoutController.addressIndex!]
                                            .floor ??
                                            '';
                                  },
                                  dropdownButtonStyle: DropdownButtonStyle(
                                    height: 45,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: Dimensions.paddingSizeExtraSmall,
                                      horizontal: Dimensions.paddingSizeExtraSmall,
                                    ),
                                    primaryColor: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge!.color,
                                  ),
                                  dropdownStyle: DropdownStyle(
                                    elevation: 10,
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault,
                                    ),
                                    padding: const EdgeInsets.all(
                                      Dimensions.paddingSizeExtraSmall,
                                    ),
                                  ),
                                  items: addressList,
                                  child: AddressWidget(
                                    address:
                                        address[checkoutController.addressIndex!],
                                    fromAddress: false,
                                    fromCheckout: true,
                                  ),
                                ),
                              ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    !isDesktop
                        ? CustomTextField(
                            labelText: 'street_number'.tr,
                            titleText: 'write_street_number'.tr,
                            inputType: TextInputType.streetAddress,
                            focusNode: checkoutController.streetNode,
                            nextFocus: checkoutController.houseNode,
                            controller:
                                checkoutController.streetNumberController,
                          )
                        : const SizedBox(),
                    SizedBox(
                      height: !isDesktop ? Dimensions.paddingSizeLarge : 0,
                    ),
                    Row(
                      children: [
                        isDesktop
                            ? Expanded(
                                child: CustomTextField(
                                  titleText: 'write_street_number'.tr,
                                  labelText: 'street_number'.tr,
                                  inputType: TextInputType.streetAddress,
                                  focusNode: checkoutController.streetNode,
                                  nextFocus: checkoutController.houseNode,
                                  controller:
                                      checkoutController.streetNumberController,
                                ),
                              )
                            : const SizedBox(),
                        SizedBox(
                          width: isDesktop ? Dimensions.paddingSizeSmall : 0,
                        ),

                        Expanded(
                          child: CustomTextField(
                            titleText: 'write_house_number'.tr,
                            labelText: 'house'.tr,
                            inputType: TextInputType.text,
                            focusNode: checkoutController.houseNode,
                            nextFocus: checkoutController.floorNode,
                            controller: checkoutController.houseController,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Expanded(
                          child: CustomTextField(
                            titleText: 'write_floor_number'.tr,
                            labelText: 'floor'.tr,
                            inputType: TextInputType.text,
                            focusNode: checkoutController.floorNode,
                            inputAction: TextInputAction.done,
                            controller: checkoutController.floorController,
                          ),
                        ),
                        //const SizedBox(height: Dimensions.paddingSizeLarge),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  ],
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
