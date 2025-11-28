import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/images.dart';
import 'package:friday_sa/util/styles.dart';
import 'package:friday_sa/common/widgets/custom_button.dart';
import 'package:friday_sa/common/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key, required this.isUpdate});
  final bool isUpdate;

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                widget.isUpdate ? Images.update : Images.maintenance,
                width: MediaQuery.of(context).size.height * 0.4,
                height: MediaQuery.of(context).size.height * 0.4,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Text(
                widget.isUpdate ? 'update'.tr : 'we_are_under_maintenance'.tr,
                style: robotoBold.copyWith(
                  fontSize: MediaQuery.of(context).size.height * 0.023,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Text(
                widget.isUpdate
                    ? 'your_app_is_deprecated'.tr
                    : 'we_will_be_right_back'.tr,
                style: robotoRegular.copyWith(
                  fontSize: MediaQuery.of(context).size.height * 0.0175,
                  color: Theme.of(context).disabledColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: widget.isUpdate
                    ? MediaQuery.of(context).size.height * 0.04
                    : 0,
              ),
              widget.isUpdate
                  ? CustomButton(
                      buttonText: 'update_now'.tr,
                      onPressed: () async {
                        String? appUrl = 'https://google.com';
                        if (GetPlatform.isAndroid) {
                          appUrl = Get.find<SplashController>()
                              .configModel!
                              .appUrlAndroid;
                        } else if (GetPlatform.isIOS) {
                          appUrl = Get.find<SplashController>()
                              .configModel!
                              .appUrlIos;
                        }
                        if (await canLaunchUrlString(appUrl!)) {
                          launchUrlString(
                            appUrl,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          showCustomSnackBar('${'can_not_launch'.tr} $appUrl');
                        }
                      },
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
