import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:friday_sa/common/widgets/address_widget.dart';
import 'package:friday_sa/common/widgets/custom_ink_well.dart';
import 'package:friday_sa/features/banner/controllers/banner_controller.dart';
import 'package:friday_sa/features/home/widgets/popular_store_view.dart';
import 'package:friday_sa/features/location/controllers/location_controller.dart';
import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/features/address/controllers/address_controller.dart';
import 'package:friday_sa/features/address/domain/models/address_model.dart';
import 'package:friday_sa/helper/address_helper.dart';
import 'package:friday_sa/helper/auth_helper.dart';
import 'package:friday_sa/helper/responsive_helper.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/styles.dart';
import 'package:friday_sa/common/widgets/custom_image.dart';
import 'package:friday_sa/common/widgets/custom_loader.dart';
import 'package:friday_sa/common/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/features/home/widgets/banner_view.dart';


class ModuleView extends StatelessWidget {
  const ModuleView({super.key, required this.splashController});
  final SplashController splashController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GetBuilder<BannerController>(
          builder: (bannerController) {
            return const BannerView(isFeatured: true);
          },
        ),
        splashController.moduleList != null
            ? splashController.moduleList!.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall,
                            vertical: Dimensions.paddingSizeDefault,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AuthHelper.isLoggedIn()
                                    ? 'what_are_you_looking_for_today'.tr
                                    : 'hey_there'.tr,
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeExtraLarge,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AuthHelper.isLoggedIn()
                                    ? 'start_ordering_from_your_favorite_store'.tr
                                    : 'pick_a_module_to_begin'.tr,
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: Dimensions.paddingSizeDefault,
                            crossAxisSpacing: Dimensions.paddingSizeDefault,
                            childAspectRatio: MediaQuery.of(context).size.width < 340 ? 1 / 1.55 : 1 / 1.35,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                          itemCount: splashController.moduleList!.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return CustomInkWell(
                              onTap: () => splashController.switchModule(index, true),
                              radius: Dimensions.radiusLarge,
                              child: SingleChildScrollView(
                                physics: const NeverScrollableScrollPhysics(),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                        color: Theme.of(context).cardColor,
                                        border: Border.all(
                                          color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.03),
                                            blurRadius: 15,
                                            spreadRadius: 0,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: CustomImage(
                                        image: '${splashController.moduleList![index].iconFullUrl}',
                                        height: 35,
                                        width: 35,
                                      ),
                                    ),
                                    const SizedBox(height: Dimensions.paddingSizeSmall),
                                    Text(
                                      splashController.moduleList![index].moduleName!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: robotoBold.copyWith(
                                        fontSize: 10,
                                        color: Theme.of(context).textTheme.bodyLarge!.color,
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: Dimensions.paddingSizeSmall,
                        ),
                        child: Text('no_module_found'.tr),
                      ),
                    )
            : ModuleShimmer(isEnabled: splashController.moduleList == null),
        // GetBuilder<AddressController>(
        //   builder: (locationController) {
        //     List<AddressModel?> addressList = [];
        //     if (AuthHelper.isLoggedIn() &&
        //         locationController.addressList != null) {
        //       addressList = [];
        //       bool contain = false;
        //       if (AddressHelper.getUserAddressFromSharedPref()!.id != null) {
        //         for (
        //           int index = 0;
        //           index < locationController.addressList!.length;
        //           index++
        //         ) {
        //           if (locationController.addressList![index].id ==
        //               AddressHelper.getUserAddressFromSharedPref()!.id) {
        //             contain = true;
        //             break;
        //           }
        //         }
        //       }
        //       if (!contain) {
        //         addressList.add(AddressHelper.getUserAddressFromSharedPref());
        //       }
        //       addressList.addAll(locationController.addressList!);
        //     }
        //     return (!AuthHelper.isLoggedIn() ||
        //             locationController.addressList != null)
        //         ? addressList.isNotEmpty
        //               ? Column(
        //                   children: [
        //                     const SizedBox(height: Dimensions.paddingSizeLarge),
        //                     Padding(
        //                       padding: const EdgeInsets.symmetric(
        //                         horizontal: Dimensions.paddingSizeSmall,
        //                       ),
        //                       child: TitleWidget(title: 'deliver_to'.tr),
        //                     ),
        //                     const SizedBox(
        //                       height: Dimensions.paddingSizeExtraSmall,
        //                     ),
        //                     SizedBox(
        //                       height: 95,
        //                       child: ListView.builder(
        //                         physics: const BouncingScrollPhysics(),
        //                         itemCount: addressList.length,
        //                         scrollDirection: Axis.horizontal,
        //                         padding: const EdgeInsets.only(
        //                           left: Dimensions.paddingSizeSmall,
        //                           right: Dimensions.paddingSizeSmall,
        //                           top: Dimensions.paddingSizeExtraSmall,
        //                         ),
        //                         itemBuilder: (context, index) {
        //                           return Container(
        //                             width: 300,
        //                             padding: const EdgeInsets.only(
        //                               right: Dimensions.paddingSizeSmall,
        //                             ),
        //                             child: AddressWidget(
        //                               address: addressList[index],
        //                               fromAddress: false,
        //                               onTap: () {
        //                                 if (AddressHelper.getUserAddressFromSharedPref()!
        //                                         .id !=
        //                                     addressList[index]!.id) {
        //                                   Get.dialog(
        //                                     const CustomLoaderWidget(),
        //                                     barrierDismissible: false,
        //                                   );
        //                                   Get.find<LocationController>()
        //                                       .saveAddressAndNavigate(
        //                                         addressList[index],
        //                                         false,
        //                                         null,
        //                                         false,
        //                                         ResponsiveHelper.isDesktop(
        //                                           context,
        //                                         ),
        //                                       );
        //                                 }
        //                               },
        //                             ),
        //                           );
        //                         },
        //                       ),
        //                     ),
        //                   ],
        //                 )
        //               : const SizedBox()
        //         : AddressShimmer(
        //             isEnabled:
        //                 AuthHelper.isLoggedIn() &&
        //                 locationController.addressList == null,
        //           );
        //   },
        // ),
        const PopularStoreView(isPopular: false, isFeatured: true),
        const SizedBox(height: 120),
      ],
    );
  }
}

class ModuleShimmer extends StatelessWidget {
  const ModuleShimmer({super.key, required this.isEnabled});
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: Dimensions.paddingSizeDefault,
        crossAxisSpacing: Dimensions.paddingSizeDefault,
        childAspectRatio: 1 / 1.4,
      ),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      itemCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 15, spreadRadius: 0, offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: isEnabled,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black12,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Expanded(
                  child: Center(
                    child: Container(
                      height: 15,
                      width: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        color: Colors.black12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AddressShimmer extends StatelessWidget {
  const AddressShimmer({super.key, required this.isEnabled});
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: Dimensions.paddingSizeLarge),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeSmall,
          ),
          child: TitleWidget(title: 'deliver_to'.tr),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        SizedBox(
          height: 85,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: 5,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
            ),
            itemBuilder: (context, index) {
              return Container(
                width: 300,
                padding: const EdgeInsets.only(
                  right: Dimensions.paddingSizeSmall,
                ),
                child: Container(
                  padding: EdgeInsets.all(
                    ResponsiveHelper.isDesktop(context)
                        ? Dimensions.paddingSizeDefault
                        : Dimensions.paddingSizeSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: ResponsiveHelper.isDesktop(context) ? 50 : 40,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: Shimmer(
                          duration: const Duration(seconds: 2),
                          enabled: isEnabled,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 15,
                                width: 100,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall,
                              ),
                              Container(
                                height: 10,
                                width: 150,
                                color: Colors.grey[300],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
