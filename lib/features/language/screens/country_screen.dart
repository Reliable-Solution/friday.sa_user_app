import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/common/widgets/custom_button.dart';
import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/helper/route_helper.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/styles.dart';

class CountryScreen extends StatefulWidget {
  const CountryScreen({super.key, required this.page, this.fromLogin = false});

  final String page;
  final bool fromLogin;

  @override
  State<CountryScreen> createState() => _CountryScreenState();
}

class _CountryScreenState extends State<CountryScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Get.find<SplashController>().getCountryData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: GetBuilder<SplashController>(
        builder: (localizationController) {
          return localizationController.isCountryLoad ||
                  localizationController.countryModel == null
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeLarge,
                        ).copyWith(top: 20),
                        child: Text(
                          'your_country'.tr,
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
                          'please_choose_your_country_to_continue'.tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                      Expanded(
                        child: SingleChildScrollView(
                          child: ListView.builder(
                            itemCount:
                                localizationController.countryModel?.length ??
                                0,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeLarge,
                            ),
                            itemBuilder: (context, index) {
                              final data =
                                  localizationController.countryModel![index];
                              final isSelected =
                                  localizationController.selectedCountryIndex ==
                                  index;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: GestureDetector(
                                  onTap: () {
                                    localizationController.setCountry(index);
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
                                        Text(
                                          data.country ?? '',
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
                          child: GetBuilder<SplashController>(
                            builder: (controller) {
                              return CustomButton(
                                buttonText: 'continue'.tr,
                                onPressed: () {
                                  controller.changeCountry();
                                  if (widget.fromLogin) {
                                    Get.offAllNamed(
                                      RouteHelper.getSignInRoute(
                                        widget.page,
                                        fromCountry: true,
                                      ),
                                    );
                                  } else {
                                    Get.offAllNamed(
                                      RouteHelper.getLanguageRoute(widget.page),
                                    );
                                  }
                                },
                              );
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
