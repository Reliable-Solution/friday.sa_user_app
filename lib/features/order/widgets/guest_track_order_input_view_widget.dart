import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/features/language/controllers/language_controller.dart';
import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/features/auth/controllers/auth_controller.dart';
import 'package:friday_sa/features/order/controllers/order_controller.dart';
import 'package:friday_sa/features/rental_module/rental_order/controllers/taxi_order_controller.dart';
import 'package:friday_sa/features/rental_module/rental_order/screens/taxi_order_details_screen.dart';
import 'package:friday_sa/helper/custom_validator.dart';
import 'package:friday_sa/helper/responsive_helper.dart';
import 'package:friday_sa/helper/route_helper.dart';
import 'package:friday_sa/helper/validate_check.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/common/widgets/custom_button.dart';
import 'package:friday_sa/common/widgets/custom_snackbar.dart';
import 'package:friday_sa/common/widgets/custom_text_field.dart';
import 'package:friday_sa/common/widgets/footer_view.dart';

import '../../../util/images.dart';
import '../../../util/styles.dart';

class GuestTrackOrderInputViewWidget extends StatefulWidget {
  const GuestTrackOrderInputViewWidget({super.key, this.selectType = 0});
  final int? selectType;

  @override
  State<GuestTrackOrderInputViewWidget> createState() =>
      _GuestTrackOrderInputViewWidgetState();
}

class _GuestTrackOrderInputViewWidgetState
    extends State<GuestTrackOrderInputViewWidget> {
  final TextEditingController _orderIdController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final FocusNode _orderFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  String? _countryDialCode;
  bool isOrder = true;

  @override
  void initState() {
    super.initState();

    isOrder = widget.selectType! == 0;
    _countryDialCode =
        Get.find<AuthController>().getUserCountryCode().isNotEmpty
        ? Get.find<AuthController>().getUserCountryCode()
        : CountryCode.fromCountryCode(
            Get.find<SplashController>().configModel!.country!,
          ).dialCode;
  }

  
  @override
  void didUpdateWidget(covariant GuestTrackOrderInputViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    isOrder = widget.selectType! == 0;
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    Widget mainContent = Container(
      width: isDesktop ? 450 : double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              Images.tracking,
              height: 50,
              width: 50,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          Text(
            isOrder ? 'track_order'.tr : 'track_trip'.tr,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeExtraLarge,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Text(
            isOrder
                ? 'enter_your_order_id_and_phone_number_to_track_order'.tr
                : 'enter_your_trip_id_and_phone_number_to_track_trip'.tr,
            textAlign: TextAlign.center,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),
          CustomTextField(
            labelText: isOrder ? 'order_id'.tr : 'trip_id'.tr,
            titleText: isOrder ? 'write_order_id'.tr : 'write_trip_id'.tr,
            controller: _orderIdController,
            focusNode: _orderFocus,
            nextFocus: _phoneFocus,
            inputType: TextInputType.number,
            showTitle: false,
            required: true,
            validator: (value) => ValidateCheck.validateEmptyText(value, null),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          CustomTextField(
            titleText: 'enter_phone_number'.tr,
            labelText: 'phone'.tr,
            controller: _phoneNumberController,
            focusNode: _phoneFocus,
            inputType: TextInputType.phone,
            inputAction: TextInputAction.done,
            isPhone: true,
            showTitle: false,
            onCountryChanged: (CountryCode countryCode) {
              _countryDialCode = countryCode.dialCode;
            },
            countryDialCode:
                _countryDialCode ??
                Get.find<LocalizationController>().locale.countryCode,
            required: true,
            validator: (value) => ValidateCheck.validateEmptyText(value, null),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),
          GetBuilder<OrderController>(
            builder: (orderController) {
              return GetBuilder<TaxiOrderController>(
                builder: (taxiOrderController) {
                  return CustomButton(
                    buttonText: isOrder ? 'track_order'.tr : 'track_trip'.tr,
                    isLoading:
                        orderController.isLoading ||
                        taxiOrderController.isLoading,
                    width: double.infinity,
                    onPressed: () async {
                      String phone = _phoneNumberController.text.trim();
                      String orderId = _orderIdController.text.trim();
                      String numberWithCountryCode = _countryDialCode! + phone;
                      PhoneValid phoneValid =
                          await CustomValidator.isPhoneValid(
                            numberWithCountryCode,
                          );
                      numberWithCountryCode = phoneValid.phone;

                      if (orderId.isEmpty) {
                        showCustomSnackBar(
                          isOrder
                              ? 'please_enter_order_id'.tr
                              : 'please_enter_order_id'.tr,
                        );
                      } else if (phone.isEmpty) {
                        showCustomSnackBar('enter_phone_number'.tr);
                      } else if (!phoneValid.isValid) {
                        showCustomSnackBar('invalid_phone_number'.tr);
                      } else {
                        if (isOrder) {
                          orderController
                              .trackOrder(
                                orderId,
                                null,
                                false,
                                contactNumber: numberWithCountryCode,
                                fromGuestInput: true,
                              )
                              .then((response) {
                                if (response!.isSuccess) {
                                  Get.toNamed(
                                    RouteHelper.getGuestTrackOrderScreen(
                                      orderId,
                                      numberWithCountryCode,
                                    ),
                                  );
                                }
                              });
                        } else {
                          taxiOrderController
                              .getTripDetails(
                                int.parse(orderId),
                                phone: numberWithCountryCode,
                              )
                              .then((success) {
                                if (success) {
                                  Get.to(
                                    () => TaxiOrderDetailsScreen(
                                      tripId: int.parse(orderId),
                                      phone: numberWithCountryCode,
                                    ),
                                  );
                                }
                              });
                        }
                      }
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
        ],
      ),
    );

    return isDesktop
        ? Expanded(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: FooterView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: Center(child: mainContent),
                  ),
                ),
              ),
            ),
          )
        : Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: mainContent,
              ),
            ),
          );
  }
}
