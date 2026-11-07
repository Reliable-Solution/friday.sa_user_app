import 'package:friday_sa/common/widgets/custom_ink_well.dart';
import 'package:friday_sa/features/address/controllers/address_controller.dart';
import 'package:friday_sa/features/address/widgets/address_confirmation_dialogue.dart';
import 'package:friday_sa/common/widgets/address_widget.dart';
import 'package:friday_sa/helper/auth_helper.dart';
import 'package:friday_sa/helper/responsive_helper.dart';
import 'package:friday_sa/helper/route_helper.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/images.dart';
import 'package:friday_sa/util/styles.dart';
import 'package:friday_sa/common/widgets/custom_app_bar.dart';
import 'package:friday_sa/common/widgets/custom_snackbar.dart';
import 'package:friday_sa/common/widgets/footer_view.dart';
import 'package:friday_sa/common/widgets/menu_drawer.dart';
import 'package:friday_sa/common/widgets/no_data_screen.dart';
import 'package:friday_sa/common/widgets/not_logged_in_screen.dart';
import 'package:friday_sa/common/widgets/web_page_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key, this.fromDashboard = false});
  final bool fromDashboard;

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    initCall();
  }

  void initCall() {
    if (AuthHelper.isLoggedIn()) {
      Get.find<AddressController>().getAddressList();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return GetBuilder<AddressController>(
      builder: (addressController) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'my_address'.tr,
            backButton: widget.fromDashboard ? false : true,
          ),
          endDrawer: const MenuDrawer(),
          endDrawerEnableOpenDragGesture: false,
          floatingActionButton: null,
          floatingActionButtonLocation: null,
          body: Container(
            height: context.height,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: isLoggedIn
                ? RefreshIndicator(
                    onRefresh: () async {
                      await addressController.getAddressList();
                    },
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          WebScreenTitleWidget(title: 'address'.tr),
                          Center(
                            child: FooterView(
                              minHeight: 0.45,
                              child: SizedBox(
                                width: Dimensions.webMaxWidth,
                                child: Column(
                                  children: [
                                    ResponsiveHelper.isDesktop(context)
                                        ? const SizedBox(
                                            height: Dimensions.paddingSizeSmall,
                                          )
                                        : const SizedBox(),
                                    addressController.addressList != null
                                        ? addressController
                                                  .addressList!
                                                  .isNotEmpty
                                              ? Padding(
                                                  padding:
                                                      ResponsiveHelper.isMobile(
                                                        context,
                                                      )
                                                      ? const EdgeInsets.symmetric(
                                                          horizontal: Dimensions.paddingSizeDefault,
                                                          vertical: Dimensions.paddingSizeSmall,
                                                        )
                                                      : EdgeInsets.zero,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      // Section header (mobile only)
                                                      if (!ResponsiveHelper.isDesktop(context)) ...[
                                                        Row(
                                                          children: [
                                                            Text(
                                                              'saved_address'.tr,
                                                              style: robotoBold.copyWith(
                                                                fontSize: Dimensions.fontSizeLarge,
                                                                color: Theme.of(context).textTheme.bodyLarge!.color,
                                                              ),
                                                            ),
                                                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                            Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                              decoration: BoxDecoration(
                                                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                                                borderRadius: BorderRadius.circular(100),
                                                              ),
                                                              child: Text(
                                                                '${addressController.addressList!.length}',
                                                                style: robotoBold.copyWith(
                                                                  fontSize: Dimensions.fontSizeExtraSmall + 1,
                                                                  color: Theme.of(context).primaryColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: Dimensions.paddingSizeSmall),
                                                      ],
                                                      // Address list
                                                      ResponsiveHelper.isDesktop(context)
                                                      ? GridView.builder(
                                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisSpacing: Dimensions.paddingSizeLarge,
                                                            mainAxisSpacing: Dimensions.paddingSizeLarge,
                                                            childAspectRatio: 4,
                                                            crossAxisCount: 3,
                                                          ),
                                                          physics: const NeverScrollableScrollPhysics(),
                                                          shrinkWrap: true,
                                                          itemCount: addressController.addressList!.length + 1,
                                                          itemBuilder: (context, index) {
                                                            return (index == addressController.addressList!.length)
                                                                ? Container(
                                                                    margin: const EdgeInsets.only(
                                                                      bottom: Dimensions.paddingSizeSmall,
                                                                    ),
                                                                    decoration: BoxDecoration(
                                                                      color: Theme.of(context).cardColor,
                                                                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                                                          blurRadius: 5,
                                                                          spreadRadius: 1,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child: CustomInkWell(
                                                                      onTap: () => Get.toNamed(
                                                                        RouteHelper.getAddAddressRoute(false, false, 0),
                                                                      ),
                                                                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                                                      radius: Dimensions.radiusDefault,
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Icon(
                                                                            Icons.add_circle_outline,
                                                                            color: Theme.of(context).primaryColor,
                                                                          ),
                                                                          const SizedBox(height: Dimensions.paddingSizeSmall),
                                                                          Text(
                                                                            'add_new_address'.tr,
                                                                            style: robotoRegular.copyWith(
                                                                              color: Theme.of(context).primaryColor,
                                                                              fontSize: Dimensions.fontSizeSmall,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  )
                                                                : AddressWidget(
                                                                    address: addressController.addressList![index],
                                                                    fromAddress: true,
                                                                    onTap: () {
                                                                      Get.toNamed(
                                                                        RouteHelper.getMapRoute(
                                                                          addressController.addressList![index],
                                                                          'address',
                                                                          false,
                                                                        ),
                                                                      );
                                                                    },
                                                                    onEditPressed: () {
                                                                      Get.toNamed(
                                                                        RouteHelper.getEditAddressRoute(
                                                                          addressController.addressList![index],
                                                                        ),
                                                                      );
                                                                    },
                                                                    onRemovePressed: () {
                                                                      if (Get.isSnackbarOpen) {
                                                                        Get.back();
                                                                      }
                                                                      Get.dialog(
                                                                        AddressConfirmDialogue(
                                                                          icon: Images.locationConfirm,
                                                                          title: 'are_you_sure'.tr,
                                                                          description: 'you_want_to_delete_this_location'.tr,
                                                                          onYesPressed: () {
                                                                            addressController.deleteUserAddressByID(
                                                                              addressController.addressList![index].id,
                                                                              index,
                                                                            ).then((response) {
                                                                              Get.back();
                                                                              showCustomSnackBar(
                                                                                response.message,
                                                                                isError: !response.isSuccess,
                                                                              );
                                                                            });
                                                                          },
                                                                        ),
                                                                      );
                                                                    },
                                                                  );
                                                          },
                                                        )
                                                      : ListView.builder(
                                                          physics: const NeverScrollableScrollPhysics(),
                                                          shrinkWrap: true,
                                                          itemCount: addressController.addressList!.length,
                                                          itemBuilder: (context, index) {
                                                            return AddressWidget(
                                                              address: addressController.addressList![index],
                                                              fromAddress: true,
                                                              onTap: () {
                                                                Get.toNamed(
                                                                  RouteHelper.getMapRoute(
                                                                    addressController.addressList![index],
                                                                    'address',
                                                                    false,
                                                                  ),
                                                                );
                                                              },
                                                              onEditPressed: () {
                                                                Get.toNamed(
                                                                  RouteHelper.getEditAddressRoute(
                                                                    addressController.addressList![index],
                                                                  ),
                                                                );
                                                              },
                                                              onRemovePressed: () {
                                                                if (Get.isSnackbarOpen) {
                                                                  Get.back();
                                                                }
                                                                Get.dialog(
                                                                  AddressConfirmDialogue(
                                                                    icon: Images.locationConfirm,
                                                                    title: 'are_you_sure'.tr,
                                                                    description: 'you_want_to_delete_this_location'.tr,
                                                                    onYesPressed: () {
                                                                      addressController.deleteUserAddressByID(
                                                                        addressController.addressList![index].id,
                                                                        index,
                                                                      ).then((response) {
                                                                        Get.back();
                                                                        showCustomSnackBar(
                                                                          response.message,
                                                                          isError: !response.isSuccess,
                                                                        );
                                                                      });
                                                                    },
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          },
                                                        ),
                                                    ],
                                                  ),
                                                )
                                              : NoDataScreen(
                                                  text: 'no_saved_address_found'
                                                      .tr,
                                                  fromAddress: true,
                                                )
                                        : const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : NotLoggedInScreen(
                    callBack: (value) {
                      initCall();
                      setState(() {});
                    },
                  ),
          ),
          bottomNavigationBar: (!ResponsiveHelper.isDesktop(context) && isLoggedIn && addressController.addressList != null && addressController.addressList!.isNotEmpty)
              ? Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: GetPlatform.isIOS ? Dimensions.paddingSizeDefault + 10 : Dimensions.paddingSizeDefault,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: ElevatedButton(
                      onPressed: () => Get.toNamed(
                        RouteHelper.getAddAddressRoute(false, false, 0, isNavbar: true),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_location_alt_outlined, color: Theme.of(context).cardColor, size: 20),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          Text(
                            'add_new_address'.tr,
                            style: robotoMedium.copyWith(
                              color: Theme.of(context).cardColor,
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : widget.fromDashboard
                  ? Container(height: GetPlatform.isIOS ? 80 : 65)
                  : const SizedBox(),
        );
      },
    );
  }
}
