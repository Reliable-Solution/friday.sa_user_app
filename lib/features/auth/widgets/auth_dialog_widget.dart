import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/features/auth/widgets/sign_in/sign_in_view.dart';
import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/helper/centralize_login_helper.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/images.dart';

class AuthDialogWidget extends StatefulWidget {
  const AuthDialogWidget({
    super.key,
    required this.exitFromApp,
    required this.backFromThis,
  });
  final bool exitFromApp;
  final bool backFromThis;

  @override
  AuthDialogWidgetState createState() => AuthDialogWidgetState();
}

class AuthDialogWidgetState extends State<AuthDialogWidget> {
  bool _isOtpViewEnable = false;

  @override
  Widget build(BuildContext context) {
    double width = _isOtpViewEnable
        ? 400
        : CentralizeLoginHelper.getPreferredLoginMethod(
            Get.find<SplashController>().configModel!.centralizeLoginSetup!,
            false,
          ).size;
    return SizedBox(
      width: width,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ),
        backgroundColor: Theme.of(context).cardColor,
        insetPadding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: Get.back,
                icon: const Icon(Icons.clear),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeExtremeLarge,
                ),
                child: Column(
                  children: [
                    Image.asset(Images.logo, width: 130),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    SignInView(
                      exitFromApp: widget.exitFromApp,
                      backFromThis: widget.backFromThis,
                      isOtpViewEnable: (bool val) {
                        setState(() {
                          _isOtpViewEnable = true;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
