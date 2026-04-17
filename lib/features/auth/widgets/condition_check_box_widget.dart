import 'package:flutter/gestures.dart';
import 'package:friday_sa/features/auth/controllers/auth_controller.dart';
import 'package:friday_sa/features/auth/controllers/deliveryman_registration_controller.dart';
import 'package:friday_sa/helper/route_helper.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConditionCheckBoxWidget extends StatelessWidget {
  const ConditionCheckBoxWidget({
    super.key,
    this.forDeliveryMan = false,
    this.forSignUp = true,
    this.forLogin = false,
  });
  final bool forDeliveryMan;
  final bool forSignUp;
  final bool forLogin;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        forLogin || forDeliveryMan
            ? GetBuilder<DeliverymanRegistrationController>(
                builder: (dmRegController) {
                  return GetBuilder<AuthController>(
                    builder: (authController) {
                      return Checkbox(
                        activeColor: Colors.black,
                        visualDensity: const VisualDensity(
                          horizontal: -4,
                          vertical: -4,
                        ),
                        side: BorderSide(color: Colors.black.withOpacity(0.4), width: 1.5),
                        checkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        value: forLogin
                            ? authController.acceptLoginTerms
                            : forSignUp
                                ? authController.acceptTerms
                                : dmRegController.acceptTerms,
                        onChanged: (bool? isChecked) => forLogin
                            ? authController.toggleLoginTerms()
                            : forSignUp
                                ? authController.toggleTerms()
                                : dmRegController.toggleTerms(),
                      );
                    },
                  );
                },
              )
            : const SizedBox(),
        forLogin || forDeliveryMan
            ? const SizedBox()
            : Text(
                '* ',
                style: robotoRegular.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
        Flexible(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'i_agree_with_all_the'.tr,
                  style: robotoRegular.copyWith(
                    color: forDeliveryMan
                        ? Theme.of(context).textTheme.bodyMedium!.color
                        : Theme.of(context).hintColor,
                    fontSize: forDeliveryMan
                        ? Dimensions.fontSizeDefault
                        : Dimensions.fontSizeSmall,
                  ),
                ),
                const TextSpan(text: ' '),
                TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => Get.toNamed(
                      RouteHelper.getHtmlRoute('terms-and-condition'),
                    ),
                  text: 'terms_conditions'.tr,
                  style: robotoMedium.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
