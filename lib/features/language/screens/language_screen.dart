import 'package:friday_sa/common/widgets/custom_asset_image_widget.dart';
import 'package:friday_sa/features/language/screens/web_language_screen.dart';
import 'package:friday_sa/features/language/widgets/language_card_widget.dart';
import 'package:friday_sa/helper/responsive_helper.dart';
import 'package:friday_sa/helper/route_helper.dart';
import 'package:friday_sa/util/styles.dart';
import 'package:friday_sa/common/widgets/custom_app_bar.dart';
import 'package:friday_sa/common/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:friday_sa/features/language/controllers/language_controller.dart';
import 'package:friday_sa/util/app_constants.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/images.dart';
import 'package:friday_sa/common/widgets/custom_button.dart';
import 'package:friday_sa/common/widgets/custom_snackbar.dart';
import 'package:get/get.dart';

class ChooseLanguageScreen extends StatefulWidget {
  const ChooseLanguageScreen({super.key, this.fromMenu = false});
  final bool fromMenu;

  @override
  State<ChooseLanguageScreen> createState() => _ChooseLanguageScreenState();
}

class _ChooseLanguageScreenState extends State<ChooseLanguageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (widget.fromMenu || ResponsiveHelper.isDesktop(context))
          ? CustomAppBar(title: 'language'.tr, backButton: true)
          : null,
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      backgroundColor: Theme.of(context).cardColor,
      body: GetBuilder<LocalizationController>(
        builder: (localizationController) {
          return ResponsiveHelper.isDesktop(context)
              ? const WebLanguageScreen()
              : SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge,
                      ).copyWith(top: 20),
                      child: Text(
                        'choose_your_language'.tr,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge,
                      ),
                      child: Text(
                        'choose_your_language_to_proceed'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                    Expanded(
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          itemCount: localizationController.languages.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeLarge,
                          ),
                          itemBuilder: (context, index) {
                            final isSelected =
                                localizationController.selectedLanguageIndex ==
                                index;
                            final language =
                                localizationController.languages[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: GestureDetector(
                                onTap: () {
                                  localizationController.setSelectLanguageIndex(
                                    index,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .color!
                                                .withValues(alpha: 0.6),
                                    ),
                                  ),
                                  child: Row(
                                    spacing: 10,
                                    children: [
                                      Icon(
                                        isSelected
                                            ? Icons.radio_button_on
                                            : Icons.radio_button_off_outlined,
                                        color: isSelected
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .color!
                                                  .withValues(alpha: 0.6),
                                      ),
                                      Image.asset(
                                        language.imageUrl!,
                                        width: 25,
                                        height: 25,
                                      ),
                                      Text(
                                        language.languageName ?? '',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: isSelected
                                              ? FontWeight.w500
                                              : FontWeight.w400,
                                          color: isSelected
                                              ? null
                                              : Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color!
                                                    .withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeDefault,
                          horizontal: Dimensions.paddingSizeExtraLarge,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.3),
                              blurRadius: 10,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: CustomButton(
                          buttonText: 'next'.tr,
                          onPressed: () {
                            if (localizationController.languages.isNotEmpty &&
                                localizationController.selectedLanguageIndex !=
                                    -1) {
                              localizationController.setLanguage(
                                Locale(
                                  AppConstants
                                      .languages[localizationController
                                          .selectedLanguageIndex]
                                      .languageCode!,
                                  AppConstants
                                      .languages[localizationController
                                          .selectedLanguageIndex]
                                      .countryCode,
                                ),
                              );
                              if (widget.fromMenu) {
                                Navigator.pop(context);
                              } else {
                                Get.offNamed(
                                  RouteHelper.getCountryRoute('splash'),
                                );
                              }
                            } else {
                              showCustomSnackBar('select_a_language'.tr);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
        },
      ),
    );
  }
}
