import 'package:friday_sa/features/auth/widgets/sign_up_widget.dart';
import 'package:friday_sa/helper/responsive_helper.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/images.dart';
import 'package:friday_sa/util/styles.dart';
import 'package:friday_sa/common/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, this.exitFromApp = false});
  final bool exitFromApp;

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (ResponsiveHelper.isDesktop(context)
          ? null
          : !widget.exitFromApp
          ? AppBar(
              leading: IconButton(
                onPressed: Get.back,
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              actions: const [SizedBox()],
            )
          : null),
      backgroundColor: ResponsiveHelper.isDesktop(context)
          ? Colors.transparent
          : Theme.of(context).cardColor,
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: SafeArea(
        child: Center(
          child: Container(
            width: context.width > 700 ? 700 : context.width,
            padding: context.width > 700
                ? const EdgeInsets.all(0)
                : const EdgeInsets.all(Dimensions.paddingSizeLarge),
            margin: context.width > 700
                ? const EdgeInsets.all(Dimensions.paddingSizeDefault)
                : null,
            decoration: context.width > 700
                ? BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  )
                : null,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ResponsiveHelper.isDesktop(context)
                      ? Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            onPressed: Get.back,
                            icon: const Icon(Icons.clear),
                          ),
                        )
                      : const SizedBox(),
                  Image.asset(Images.logo, width: 125),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'sign_up'.tr,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeExtraLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  const SignUpWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
