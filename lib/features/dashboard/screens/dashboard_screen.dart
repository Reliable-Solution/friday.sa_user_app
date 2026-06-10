import 'dart:async';
import 'dart:io';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:friday_sa/features/rental_module/common/widgets/taxi_cart_widget.dart';
import 'package:friday_sa/features/dashboard/widgets/store_registration_success_bottom_sheet.dart';
import 'package:friday_sa/features/home/controllers/home_controller.dart';
import 'package:friday_sa/features/location/controllers/location_controller.dart';
import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/features/order/controllers/order_controller.dart';
import 'package:friday_sa/features/order/domain/models/order_model.dart';
import 'package:friday_sa/features/address/screens/address_screen.dart';
import 'package:friday_sa/features/auth/controllers/auth_controller.dart';
import 'package:friday_sa/features/dashboard/widgets/bottom_nav_item_widget.dart';
import 'package:friday_sa/features/parcel/controllers/parcel_controller.dart';
import 'package:friday_sa/features/store/controllers/store_controller.dart';
import 'package:friday_sa/features/rental_module/rental_cart_screen/taxi_cart_screen.dart';
import 'package:friday_sa/features/rental_module/rental_favourite/screens/vehicle_favourite_screen.dart';
import 'package:friday_sa/helper/auth_helper.dart';
import 'package:friday_sa/helper/responsive_helper.dart';
import 'package:friday_sa/helper/route_helper.dart';
import 'package:friday_sa/helper/taxi_helper.dart';
import 'package:friday_sa/util/app_constants.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/images.dart';
import 'package:friday_sa/common/widgets/cart_widget.dart';
import 'package:friday_sa/common/widgets/custom_dialog.dart';
import 'package:friday_sa/features/checkout/widgets/congratulation_dialogue.dart';
import 'package:friday_sa/features/dashboard/widgets/address_bottom_sheet_widget.dart';
import 'package:friday_sa/features/dashboard/widgets/parcel_bottom_sheet_widget.dart';
import 'package:friday_sa/features/favourite/screens/favourite_screen.dart';
import 'package:friday_sa/features/home/screens/home_screen.dart';
import 'package:friday_sa/features/menu/screens/menu_screen.dart';
import 'package:friday_sa/features/order/screens/order_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/running_order_view_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.pageIndex,
    this.fromSplash = false,
    this.isLoad = false,
  });

  final int pageIndex;
  final bool fromSplash;
  final bool isLoad;

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  PageController? _pageController;
  int _pageIndex = 0;
  late List<Widget> _screens;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();
  bool _canExit = GetPlatform.isWeb ? true : false;

  GlobalKey<ExpandableBottomSheetState> key = GlobalKey();

  late bool _isLogin;
  bool active = false;

  @override
  void initState() {
    super.initState();

    _isLogin = AuthHelper.isLoggedIn();

    _showRegistrationSuccessBottomSheet();

    if (_isLogin) {
      if (Get.find<SplashController>().configModel!.loyaltyPointStatus == 1 &&
          Get.find<AuthController>().getEarningPint().isNotEmpty &&
          !ResponsiveHelper.isDesktop(Get.context)) {
        Future.delayed(
          const Duration(seconds: 1),
          () =>
              showAnimatedDialog(Get.context!, const CongratulationDialogue()),
        );
      }
      suggestAddressBottomSheet();
      Get.find<OrderController>().getRunningOrders(1, fromDashboard: true);
    }

    _pageIndex = widget.pageIndex;

    _pageController = PageController(initialPage: widget.pageIndex);

    _screens = [
      HomeScreen(isLoad: widget.isLoad),
      const FavouriteScreen(),
      const SizedBox(),
      const OrderScreen(),
      const MenuScreen(),
    ];
  }

  _showRegistrationSuccessBottomSheet() {
    bool canShowBottomSheet = Get.find<HomeController>()
        .getRegistrationSuccessfulSharedPref();
    if (canShowBottomSheet) {
      Future.delayed(const Duration(seconds: 1), () {
        ResponsiveHelper.isDesktop(Get.context)
            ? Get.dialog(
                const Dialog(child: StoreRegistrationSuccessBottomSheet()),
              ).then((value) {
                Get.find<HomeController>().saveRegistrationSuccessfulSharedPref(
                  false,
                );
                Get.find<HomeController>().saveIsStoreRegistrationSharedPref(
                  false,
                );
                setState(() {});
              })
            : showModalBottomSheet(
                context: Get.context!,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (con) => const StoreRegistrationSuccessBottomSheet(),
              ).then((value) {
                Get.find<HomeController>().saveRegistrationSuccessfulSharedPref(
                  false,
                );
                Get.find<HomeController>().saveIsStoreRegistrationSharedPref(
                  false,
                );
                setState(() {});
              });
      });
    }
  }

  Future<void> suggestAddressBottomSheet() async {
    active = await Get.find<LocationController>().checkLocationActive();
    if (widget.fromSplash &&
        Get.find<LocationController>().showLocationSuggestion &&
        active) {
      Future.delayed(const Duration(seconds: 1), () {
        showModalBottomSheet(
          context: Get.context!,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (con) => const AddressBottomSheetWidget(),
        ).then((value) {
          Get.find<LocationController>().showSuggestedLocation(false);
          setState(() {});
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    bool keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return GetBuilder<SplashController>(
      builder: (splashController) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (_pageIndex != 0) {
              _setPage(0);
            } else {
              if (!ResponsiveHelper.isDesktop(context) &&
                  Get.find<SplashController>().module != null &&
                  Get.find<SplashController>().configModel!.module == null) {
                Get.find<SplashController>().setModule(null);
                Get.find<StoreController>().resetStoreData();
              } else {
                if (_canExit) {
                  if (GetPlatform.isAndroid) {
                    SystemNavigator.pop();
                  } else if (GetPlatform.isIOS) {
                    exit(0);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'back_press_again_to_exit'.tr,
                        style: const TextStyle(color: Colors.white),
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                      margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    ),
                  );
                  _canExit = true;
                  Timer(const Duration(seconds: 2), () {
                    _canExit = false;
                  });
                }
              }
            }
          },
          child: GetBuilder<OrderController>(
            builder: (orderController) {
              List<OrderModel> runningOrder =
                  orderController.runningOrderModel != null
                  ? orderController.runningOrderModel!.orders!
                  : [];

              
              List<OrderModel> reversOrder = List.from(runningOrder.reversed);

              return SafeArea(
                top: false,
                bottom: GetPlatform.isAndroid,
                child: Scaffold(
                  key: _scaffoldKey,
                  body: ExpandableBottomSheet(
                    background: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: _screens.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return _screens[index];
                          },
                        ),
                        ResponsiveHelper.isDesktop(context) || keyboardVisible
                            ? const SizedBox()
                            : Align(
                                alignment: Alignment.bottomCenter,
                                child: GetBuilder<SplashController>(
                                  builder: (splashController) {
                                    bool isParcel =
                                        splashController.module != null &&
                                        splashController
                                            .configModel!
                                            .moduleConfig!
                                            .module!
                                            .isParcel!;
                                    bool isTaxiWithCache =
                                        ((splashController.module != null &&
                                                splashController
                                                        .module!
                                                        .moduleType
                                                        .toString() ==
                                                    AppConstants.taxi) ||
                                            (splashController.cacheModule !=
                                                    null &&
                                                splashController
                                                        .cacheModule!
                                                        .moduleType
                                                        .toString() ==
                                                    AppConstants.taxi)) &&
                                        TaxiHelper.haveTaxiModule();
                                    bool isTaxi =
                                        splashController.module != null &&
                                        splashController.module!.moduleType
                                                .toString() ==
                                            AppConstants.taxi;
                                    isParcel = isParcel && !isTaxiWithCache;

                                    _screens = [
                                      HomeScreen(isLoad: widget.isLoad),
                                      isParcel
                                          ? const AddressScreen(
                                              fromDashboard: true,
                                            )
                                          : isTaxi
                                          ? const VehicleFavouriteScreen()
                                          : const FavouriteScreen(),
                                      const SizedBox(),
                                      OrderScreen(index: isTaxi ? 1 : 0),
                                      const MenuScreen(),
                                    ];
                                    bool hideBar = ResponsiveHelper.isDesktop(context) ||
                                        (widget.fromSplash &&
                                            Get.find<LocationController>().showLocationSuggestion &&
                                            active) ||
                                        (orderController.showBottomSheet &&
                                            orderController.runningOrderModel != null &&
                                            orderController.runningOrderModel!.orders!.isNotEmpty &&
                                            _isLogin);
                                    
                                    if (hideBar) {
                                      return const SizedBox();
                                    }

                                    Color barBgColor = Colors.white; // Pristine proper solid white!
                                    Color barBorderColor = Colors.black.withValues(alpha: 0.04); // Extremely clean, thin soft grey border!
                                    
                                    if (Get.isDarkMode) {
                                      barBgColor = const Color(0xFF141414);
                                      barBorderColor = Colors.white.withValues(alpha: 0.08);
                                    }

                                    return Container(
                                      width: size.width,
                                      height: GetPlatform.isIOS ? 100 : 85,
                                      color: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      margin: EdgeInsets.only(bottom: GetPlatform.isIOS ? 18 : 10),
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          // Background Notched Bar
                                          Positioned(
                                            left: 0,
                                            right: 0,
                                            bottom: 0,
                                            height: 70,
                                            child: CustomPaint(
                                              painter: NotchedBottomBarPainter(
                                                backgroundColor: barBgColor,
                                                borderColor: barBorderColor,
                                              ),
                                            ),
                                          ),
                                          
                                          // 4 Tab Items Row
                                          Positioned(
                                            left: 0,
                                            right: 0,
                                            bottom: 0,
                                            height: 70,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                BottomNavItemWidget(
                                                  title: 'home'.tr,
                                                  selectedIcon: Images.homeSelect,
                                                  unSelectedIcon: Images.homeUnselect,
                                                  isSelected: _pageIndex == 0,
                                                  onTap: () => _setPage(0),
                                                ),
                                                BottomNavItemWidget(
                                                  title: isParcel
                                                      ? 'address'.tr
                                                      : isTaxi
                                                      ? 'wishlist'.tr
                                                      : 'favourite'.tr,
                                                  selectedIcon: isParcel
                                                      ? Images.addressSelect
                                                      : Images.favouriteSelect,
                                                  unSelectedIcon: isParcel
                                                      ? Images.addressUnselect
                                                      : Images.favouriteUnselect,
                                                  isSelected: _pageIndex == 1,
                                                  onTap: () => _setPage(1),
                                                ),
                                                // Spacer for the center Floating Button
                                                const SizedBox(width: 72),
                                                BottomNavItemWidget(
                                                  title: isTaxi ? 'trips'.tr : 'orders'.tr,
                                                  selectedIcon: Images.orderSelect,
                                                  unSelectedIcon: Images.orderUnselect,
                                                  isSelected: _pageIndex == 3,
                                                  onTap: () => _setPage(3),
                                                ),
                                                BottomNavItemWidget(
                                                  title: 'menu'.tr,
                                                  selectedIcon: Images.menu,
                                                  unSelectedIcon: Images.menu,
                                                  isSelected: _pageIndex == 4,
                                                  onTap: () => _setPage(4),
                                                ),
                                              ],
                                            ),
                                          ),
                                          
                                          // Center Floating Action Button
                                          Positioned(
                                            bottom: 27, // Overlapping the notch beautifully
                                            left: (size.width - 32) / 2 - 27, // 32 is horizontal padding, 27 is button half-width
                                            child: Container(
                                              width: 54,
                                              height: 54,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).primaryColor, // Dynamic primary theme color!
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                                                    blurRadius: 12,
                                                    spreadRadius: 1,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  borderRadius: BorderRadius.circular(27),
                                                  onTap: () {
                                                    if (isParcel) {
                                                      showModalBottomSheet(
                                                        context: context,
                                                        isScrollControlled: true,
                                                        backgroundColor: Colors.transparent,
                                                        builder: (con) => ParcelBottomSheetWidget(
                                                          parcelCategoryList: Get.find<ParcelController>().parcelCategoryList,
                                                        ),
                                                      );
                                                    } else if (isTaxiWithCache) {
                                                      Get.to(() => const TaxiCartScreen());
                                                    } else {
                                                      Get.toNamed(RouteHelper.getCartRoute());
                                                    }
                                                  },
                                                   child: Center(
                                                     child: isTaxiWithCache
                                                         ? TaxiCartWidget(
                                                             color: Colors.white,
                                                             size: 22,
                                                           )
                                                         : isParcel
                                                         ? const Icon(
                                                             CupertinoIcons.add,
                                                             size: 30,
                                                             color: Colors.white,
                                                           )
                                                         : CartWidget(
                                                             color: Colors.white,
                                                             size: 22,
                                                           ),
                                                   ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ],
                    ),
                    persistentContentHeight:
                        (widget.fromSplash &&
                            Get.find<LocationController>()
                                .showLocationSuggestion &&
                            active)
                        ? 0
                        : GetPlatform.isIOS
                        ? 110
                        : 100,
                    onIsContractedCallback: () {
                      if (!orderController.showOneOrder) {
                        orderController.showOrders();
                      }
                    },
                    onIsExtendedCallback: () {
                      if (orderController.showOneOrder) {
                        orderController.showOrders();
                      }
                    },
                    enableToggle: true,
                    expandableContent:
                        (widget.fromSplash &&
                            Get.find<LocationController>()
                                .showLocationSuggestion &&
                            active &&
                            !ResponsiveHelper.isDesktop(context))
                        ? const SizedBox()
                        : (ResponsiveHelper.isDesktop(context) ||
                              !_isLogin ||
                              orderController.runningOrderModel == null ||
                              orderController
                                  .runningOrderModel!
                                  .orders!
                                  .isEmpty ||
                              !orderController.showBottomSheet)
                        ? const SizedBox()
                        : Dismissible(
                            key: UniqueKey(),
                            onDismissed: (direction) {
                              if (orderController.showBottomSheet) {
                                orderController.showRunningOrders();
                              }
                            },
                            child: RunningOrderViewWidget(
                              reversOrder: reversOrder,
                              onOrderTap: () {
                                _setPage(3);
                                if (orderController.showBottomSheet) {
                                  orderController.showRunningOrders();
                                }
                              },
                            ),
                          ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _setPage(int pageIndex) {
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }

  Widget trackView(BuildContext context, {required bool status}) {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        color: status
            ? Theme.of(context).primaryColor
            : Theme.of(context).disabledColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: onTap,
        splashColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        highlightColor: Colors.transparent,
        child: Container(
          width: 55,
          height: 55,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: Icon(
                  icon,
                  size: 25,
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 4,
                width: isSelected ? 4 : 0,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotchedBottomBarPainter extends CustomPainter {
  final Color backgroundColor;
  final Color borderColor;

  NotchedBottomBarPainter({
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();
    
    double r = 16.0; // Corner radius of the bar
    double cx = size.width / 2;
    double notchWidth = 72.0;
    double notchHeight = 26.0;

    // Start top-left corner
    path.moveTo(0, r);
    path.quadraticBezierTo(0, 0, r, 0);
    
    // Line to left side of the notch
    path.lineTo(cx - notchWidth / 2, 0);
    
    // Left notch curve
    path.cubicTo(
      cx - notchWidth / 2 + 12, 0,
      cx - notchWidth / 2 + 4, notchHeight,
      cx, notchHeight,
    );
    
    // Right notch curve
    path.cubicTo(
      cx + notchWidth / 2 - 4, notchHeight,
      cx + notchWidth / 2 - 12, 0,
      cx + notchWidth / 2, 0,
    );
    
    // Line to top-right corner
    path.lineTo(size.width - r, 0);
    path.quadraticBezierTo(size.width, 0, size.width, r);
    
    // Line to bottom-right corner
    path.lineTo(size.width, size.height - r);
    path.quadraticBezierTo(size.width, size.height, size.width - r, size.height);
    
    // Line to bottom-left corner
    path.lineTo(r, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - r);
    
    path.close();

    // Draw highly premium top-oriented drop shadow using custom soft blurs
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0)
      ..style = PaintingStyle.fill;

    final shadowPaintFocused = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path.shift(const Offset(0, -3)), shadowPaint);
    canvas.drawPath(path.shift(const Offset(0, -1)), shadowPaintFocused);

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
