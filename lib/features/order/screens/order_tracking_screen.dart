import 'dart:async';
import 'dart:collection';

import 'package:friday_sa/util/styles.dart';
import 'package:friday_sa/common/widgets/custom_image.dart';
import 'package:friday_sa/common/widgets/rating_bar.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:geolocator/geolocator.dart';
import 'package:friday_sa/common/controllers/theme_controller.dart';
import 'package:friday_sa/common/widgets/custom_snackbar.dart';
import 'package:friday_sa/common/widgets/footer_view.dart';
import 'package:friday_sa/features/location/controllers/location_controller.dart';
import 'package:friday_sa/features/location/widgets/permission_dialog_widget.dart';
import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/features/notification/domain/models/notification_body_model.dart';
import 'package:friday_sa/features/address/domain/models/address_model.dart';
import 'package:friday_sa/features/chat/domain/models/conversation_model.dart';
import 'package:friday_sa/features/order/controllers/order_controller.dart';
import 'package:friday_sa/features/order/domain/models/order_model.dart';
import 'package:friday_sa/features/store/domain/models/store_model.dart';
import 'package:friday_sa/helper/address_helper.dart';
import 'package:friday_sa/helper/auth_helper.dart';
import 'package:friday_sa/helper/marker_helper.dart';
import 'package:friday_sa/helper/responsive_helper.dart';
import 'package:friday_sa/helper/route_helper.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/images.dart';
import 'package:friday_sa/common/widgets/custom_app_bar.dart';
import 'package:friday_sa/common/widgets/menu_drawer.dart';
import 'package:friday_sa/features/order/widgets/track_details_view_widget.dart';
import 'package:friday_sa/features/order/widgets/tracking_stepper_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({
    super.key,
    required this.orderID,
    this.contactNumber,
  });
  final String? orderID;
  final String? contactNumber;

  @override
  OrderTrackingScreenState createState() => OrderTrackingScreenState();
}

class OrderTrackingScreenState extends State<OrderTrackingScreen> {
  GoogleMapController? _controller;
  bool _isLoading = true;
  Set<Marker> _markers = HashSet<Marker>();
  Timer? _timer;
  bool showChatPermission = true;
  bool isHovered = false;

  Future<void> _loadData() async {
    await Get.find<OrderController>().trackOrder(
      widget.orderID,
      null,
      true,
      contactNumber: widget.contactNumber,
    );
    await Get.find<LocationController>().getCurrentLocation(
      true,
      notify: false,
      defaultLatLng: LatLng(
        double.parse(AddressHelper.getUserAddressFromSharedPref()!.latitude!),
        double.parse(AddressHelper.getUserAddressFromSharedPref()!.longitude!),
      ),
    );
  }

  void _startApiCall() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      Get.find<OrderController>().timerTrackOrder(
        widget.orderID.toString(),
        contactNumber: widget.contactNumber,
      );
    });
  }

  @override
  void initState() {
    super.initState();

    _loadData();
    _startApiCall();
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    _timer?.cancel();
  }

  void onEntered(bool isHovered) {
    setState(() {
      this.isHovered = isHovered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'order_tracking'.tr),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<OrderController>(
        builder: (orderController) {
          OrderModel? track;
          if (orderController.trackModel != null) {
            track = orderController.trackModel;

            if (track!.orderType != 'parcel') {
              if (track.store!.storeBusinessModel == 'commission') {
                showChatPermission = true;
              } else if (track.store!.storeSubscription != null &&
                  track.store!.storeBusinessModel == 'subscription') {
                showChatPermission = track.store!.storeSubscription!.chat == 1;
              } else {
                showChatPermission = false;
              }
            } else {
              showChatPermission = AuthHelper.isLoggedIn();
            }
          }

          return track != null
              ? (track.orderType == 'take_away' && !ResponsiveHelper.isDesktop(context))
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                      child: Column(
                        children: [
                          TrackingStepperWidget(
                            status: track.orderStatus,
                            takeAway: true,
                          ),
                          Expanded(
                            child: Center(
                              child: SingleChildScrollView(
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'store_detail'.tr,
                                        style: robotoBold.copyWith(
                                          fontSize: Dimensions.fontSizeLarge,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: Dimensions.paddingSizeDefault),
                                      Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2), width: 2),
                                        ),
                                        child: ClipOval(
                                          child: CustomImage(
                                            image: '${track.store != null ? track.store!.logoFullUrl : ''}',
                                            height: 70,
                                            width: 70,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: Dimensions.paddingSizeSmall),
                                      Text(
                                        track.store != null ? track.store!.name! : '',
                                        textAlign: TextAlign.center,
                                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                                      ),
                                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                      Text(
                                        track.store != null ? track.store!.address! : '',
                                        textAlign: TextAlign.center,
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: Theme.of(context).disabledColor,
                                        ),
                                      ),
                                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                      RatingBar(
                                        rating: track.store?.avgRating?.toDouble(),
                                        size: 15,
                                        ratingCount: track.store?.ratingCount,
                                      ),
                                      const SizedBox(height: Dimensions.paddingSizeLarge),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 45,
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            String url =
                                                'https://www.google.com/maps/dir/?api=1&destination=${track!.store != null ? track.store!.latitude : ''}'
                                                ',${track.store != null ? track.store!.longitude : ''}&mode=d';
                                            if (await canLaunchUrlString(url)) {
                                              await launchUrlString(
                                                url,
                                                mode: LaunchMode.externalApplication,
                                              );
                                            } else {
                                              showCustomSnackBar(
                                                'unable_to_launch_google_map'.tr,
                                              );
                                            }
                                          },
                                          icon: const Icon(Icons.directions, color: Colors.white),
                                          label: Text(
                                            'direction'.tr,
                                            style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context).primaryColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: Dimensions.paddingSizeDefault),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              onTap: () async {
                                                if (track?.store?.phone != null &&
                                                    await canLaunchUrlString('tel:${track!.store!.phone}')) {
                                                  launchUrlString(
                                                    'tel:${track!.store!.phone}',
                                                    mode: LaunchMode.externalApplication,
                                                  );
                                                }
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 10),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                                  color: Colors.green.withValues(alpha: 0.1),
                                                  border: Border.all(color: Colors.green, width: 1),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(Icons.phone, color: Colors.green, size: 18),
                                                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                    Text(
                                                      'call'.tr,
                                                      style: robotoMedium.copyWith(color: Colors.green, fontSize: Dimensions.fontSizeSmall),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (showChatPermission) ...[
                                            const SizedBox(width: Dimensions.paddingSizeDefault),
                                            Expanded(
                                              child: InkWell(
                                                onTap: () async {
                                                  _timer?.cancel();
                                                  await Get.toNamed(
                                                    RouteHelper.getChatRoute(
                                                      notificationBody: NotificationBodyModel(
                                                        deliverymanId: null,
                                                        orderId: int.parse(widget.orderID!),
                                                        restaurantId: track?.store?.vendorId,
                                                      ),
                                                      user: User(
                                                        id: track?.store?.vendorId,
                                                        fName: track?.store?.name,
                                                        lName: '',
                                                        imageFullUrl: track?.store?.logoFullUrl,
                                                      ),
                                                    ),
                                                  );
                                                  _startApiCall();
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                                    border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.chat, color: Theme.of(context).primaryColor, size: 18),
                                                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                      Text(
                                                        'chat'.tr,
                                                        style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          const SizedBox(),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      physics: isHovered || !ResponsiveHelper.isDesktop(context)
                          ? const NeverScrollableScrollPhysics()
                          : const AlwaysScrollableScrollPhysics(),
                      child: FooterView(
                        child: Center(
                          child: SizedBox(
                            width: Dimensions.webMaxWidth,
                            height: ResponsiveHelper.isDesktop(context)
                                ? 700
                                : MediaQuery.of(context).size.height * 0.85,
                            child: Stack(
                              children: [
                                if (track.orderType != 'take_away')
                                  MouseRegion(
                                    onEnter: (event) => onEntered(true),
                                    onExit: (event) => onEntered(false),
                                    child: GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target: LatLng(
                                          double.parse(
                                            track.deliveryAddress!.latitude!,
                                          ),
                                          double.parse(
                                            track.deliveryAddress!.longitude!,
                                          ),
                                        ),
                                        zoom: 16,
                                      ),
                                      minMaxZoomPreference:
                                          const MinMaxZoomPreference(0, 16),
                                      zoomControlsEnabled: false,
                                      markers: _markers,
                                      onMapCreated: (GoogleMapController controller) {
                                        _controller = controller;
                                        _isLoading = false;
                                        setMarker(
                                          track!.orderType == 'parcel'
                                              ? Store(
                                                  latitude:
                                                      track.receiverDetails!.latitude,
                                                  longitude: track
                                                      .receiverDetails!
                                                      .longitude,
                                                  address:
                                                      track.receiverDetails!.address,
                                                  name: track
                                                      .receiverDetails!
                                                      .contactPersonName,
                                                )
                                              : track.store,
                                          track.deliveryMan,
                                          track.orderType == 'take_away'
                                              ? Get.find<LocationController>()
                                                            .position
                                                            .latitude ==
                                                        0
                                                    ? track.deliveryAddress
                                                    : AddressModel(
                                                        latitude:
                                                            Get.find<
                                                                  LocationController
                                                                >()
                                                                .position
                                                                .latitude
                                                                .toString(),
                                                        longitude:
                                                            Get.find<
                                                                  LocationController
                                                                >()
                                                                .position
                                                                .longitude
                                                                .toString(),
                                                        address:
                                                            Get.find<
                                                                  LocationController
                                                                >()
                                                                .address,
                                                      )
                                              : track.deliveryAddress,
                                          track.orderType == 'take_away',
                                          track.orderType == 'parcel',
                                          track.moduleType == 'food',
                                        );
                                      },
                                      style: Get.isDarkMode
                                          ? Get.find<ThemeController>().darkMap
                                          : Get.find<ThemeController>().lightMap,
                                    ),
                                  ),
                                _isLoading && track.orderType != 'take_away'
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : const SizedBox(),
                                Positioned(
                                  top: Dimensions.paddingSizeSmall,
                                  left: Dimensions.paddingSizeSmall,
                                  right: Dimensions.paddingSizeSmall,
                                  child: TrackingStepperWidget(
                                    status: track.orderStatus,
                                    takeAway: track.orderType == 'take_away',
                                  ),
                                ),
                                if (track.orderType == 'take_away')
                                  Positioned(
                                    top: 110,
                                    bottom: 125,
                                    left: Dimensions.paddingSizeDefault,
                                    right: Dimensions.paddingSizeDefault,
                                    child: Center(
                                      child: SingleChildScrollView(
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.04),
                                                blurRadius: 20,
                                                spreadRadius: 2,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                'store_detail'.tr,
                                                style: robotoBold.copyWith(
                                                  fontSize: Dimensions.fontSizeLarge,
                                                  color: Theme.of(context).primaryColor,
                                                ),
                                              ),
                                              const SizedBox(height: Dimensions.paddingSizeDefault),
                                              Container(
                                                padding: const EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2), width: 2),
                                                ),
                                                child: ClipOval(
                                                  child: CustomImage(
                                                    image: '${track.store != null ? track.store!.logoFullUrl : ''}',
                                                    height: 70,
                                                    width: 70,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: Dimensions.paddingSizeSmall),
                                              Text(
                                                track.store != null ? track.store!.name! : '',
                                                textAlign: TextAlign.center,
                                                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                                              ),
                                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                              Text(
                                                track.store != null ? track.store!.address! : '',
                                                textAlign: TextAlign.center,
                                                style: robotoRegular.copyWith(
                                                  fontSize: Dimensions.fontSizeSmall,
                                                  color: Theme.of(context).disabledColor,
                                                ),
                                              ),
                                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                              RatingBar(
                                                rating: track.store?.avgRating?.toDouble(),
                                                size: 15,
                                                ratingCount: track.store?.ratingCount,
                                              ),
                                              const SizedBox(height: Dimensions.paddingSizeLarge),
                                              SizedBox(
                                                width: double.infinity,
                                                height: 45,
                                                child: ElevatedButton.icon(
                                                  onPressed: () async {
                                                    String url =
                                                        'https://www.google.com/maps/dir/?api=1&destination=${track!.store != null ? track.store!.latitude : ''}'
                                                        ',${track.store != null ? track.store!.longitude : ''}&mode=d';
                                                    if (await canLaunchUrlString(url)) {
                                                      await launchUrlString(
                                                        url,
                                                        mode: LaunchMode.externalApplication,
                                                      );
                                                    } else {
                                                      showCustomSnackBar(
                                                        'unable_to_launch_google_map'.tr,
                                                      );
                                                    }
                                                  },
                                                  icon: const Icon(Icons.directions, color: Colors.white),
                                                  label: Text(
                                                    'direction'.tr,
                                                    style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault),
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Theme.of(context).primaryColor,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: Dimensions.paddingSizeDefault),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () async {
                                                        if (track?.store?.phone != null &&
                                                            await canLaunchUrlString('tel:${track!.store!.phone}')) {
                                                          launchUrlString(
                                                            'tel:${track!.store!.phone}',
                                                            mode: LaunchMode.externalApplication,
                                                          );
                                                        }
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                                          color: Colors.green.withValues(alpha: 0.1),
                                                          border: Border.all(color: Colors.green, width: 1),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            const Icon(Icons.phone, color: Colors.green, size: 18),
                                                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                            Text(
                                                              'call'.tr,
                                                              style: robotoMedium.copyWith(color: Colors.green, fontSize: Dimensions.fontSizeSmall),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  if (showChatPermission) ...[
                                                    const SizedBox(width: Dimensions.paddingSizeDefault),
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: () async {
                                                          _timer?.cancel();
                                                          await Get.toNamed(
                                                            RouteHelper.getChatRoute(
                                                              notificationBody: NotificationBodyModel(
                                                                deliverymanId: null,
                                                                orderId: int.parse(widget.orderID!),
                                                                restaurantId: track?.store?.vendorId,
                                                              ),
                                                              user: User(
                                                                id: track?.store?.vendorId,
                                                                fName: track?.store?.name,
                                                                lName: '',
                                                                imageFullUrl: track?.store?.logoFullUrl,
                                                              ),
                                                            ),
                                                          );
                                                          _startApiCall();
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                                            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                                            border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Icon(Icons.chat, color: Theme.of(context).primaryColor, size: 18),
                                                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                              Text(
                                                                'chat'.tr,
                                                                style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (track.orderType != 'take_away')
                                  Positioned(
                                    right: 15,
                                    bottom:
                                        track.orderType != 'take_away' &&
                                            track.deliveryMan == null
                                        ? 150
                                        : 220,
                                    child: InkWell(
                                      onTap: () => _checkPermission(() async {
                                        AddressModel address =
                                            await Get.find<LocationController>()
                                                .getCurrentLocation(
                                                  false,
                                                  mapController: _controller,
                                                );
                                        setMarker(
                                          track!.orderType == 'parcel'
                                              ? Store(
                                                  latitude:
                                                      track.receiverDetails!.latitude,
                                                  longitude: track
                                                      .receiverDetails!
                                                      .longitude,
                                                  address:
                                                      track.receiverDetails!.address,
                                                  name: track
                                                      .receiverDetails!
                                                      .contactPersonName,
                                                )
                                              : track.store,
                                          track.deliveryMan,
                                          track.orderType == 'take_away'
                                              ? Get.find<LocationController>()
                                                            .position
                                                            .latitude ==
                                                        0
                                                    ? track.deliveryAddress
                                                    : AddressModel(
                                                        latitude:
                                                            Get.find<
                                                                  LocationController
                                                                >()
                                                                .position
                                                                .latitude
                                                                .toString(),
                                                        longitude:
                                                            Get.find<
                                                                  LocationController
                                                                >()
                                                                .position
                                                                .longitude
                                                                .toString(),
                                                        address:
                                                            Get.find<
                                                                  LocationController
                                                                >()
                                                                .address,
                                                      )
                                              : track.deliveryAddress,
                                          track.orderType == 'take_away',
                                          track.orderType == 'parcel',
                                          track.moduleType == 'food',
                                          currentAddress: address,
                                          fromCurrentLocation: true,
                                        );
                                      }),
                                      child: Container(
                                        padding: const EdgeInsets.all(
                                          Dimensions.paddingSizeSmall,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(50),
                                          color: Colors.white,
                                        ),
                                        child: Icon(
                                          Icons.my_location_outlined,
                                          color: Theme.of(context).primaryColor,
                                          size: 25,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (track.orderType != 'take_away')
                                  Positioned(
                                    bottom: Dimensions.paddingSizeSmall,
                                    left: Dimensions.paddingSizeSmall,
                                    right: Dimensions.paddingSizeSmall,
                                    child: TrackDetailsViewWidget(
                                      status: track.orderStatus,
                                      track: track,
                                      showChatPermission: showChatPermission,
                                      callback: () async {
                                        _timer?.cancel();
                                        await Get.toNamed(
                                          RouteHelper.getChatRoute(
                                            notificationBody: NotificationBodyModel(
                                              deliverymanId: track!.orderType == 'take_away'
                                                  ? null
                                                  : track.deliveryMan?.id,
                                              orderId: int.parse(widget.orderID!),
                                              restaurantId: track.orderType == 'take_away'
                                                  ? track.store?.vendorId
                                                  : null,
                                            ),
                                            user: track.orderType == 'take_away'
                                                ? User(
                                                    id: track.store!.vendorId,
                                                    fName: track.store!.name,
                                                    lName: '',
                                                    imageFullUrl: track.store!.logoFullUrl,
                                                  )
                                                : User(
                                                    id: track.deliveryMan!.id,
                                                    fName: track.deliveryMan!.fName,
                                                    lName: track.deliveryMan!.lName,
                                                    imageFullUrl:
                                                        track.deliveryMan!.imageFullUrl,
                                                  ),
                                          ),
                                        );
                                        _startApiCall();
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
              : const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<void> setMarker(
    Store? store,
    DeliveryMan? deliveryMan,
    AddressModel? addressModel,
    bool takeAway,
    bool parcel,
    bool isRestaurant, {
    AddressModel? currentAddress,
    bool fromCurrentLocation = false,
  }) async {
    try {
      BitmapDescriptor restaurantImageData =
          await MarkerHelper.convertAssetToBitmapDescriptor(
            width: (isRestaurant || parcel)
                ? 30
                : isRestaurant
                ? 30
                : 50,
            imagePath: parcel
                ? Images.userMarker
                : isRestaurant
                ? Images.restaurantMarker
                : Images.markerStore,
          );

      BitmapDescriptor deliveryBoyImageData =
          await MarkerHelper.convertAssetToBitmapDescriptor(
            width: 30,
            imagePath: Images.deliveryManMarker,
          );
      BitmapDescriptor destinationImageData =
          await MarkerHelper.convertAssetToBitmapDescriptor(
            width: 30,
            imagePath: takeAway ? Images.myLocationMarker : Images.userMarker,
          );

      /// Animate to coordinate
      LatLngBounds? bounds;
      double rotation = 0;
      if (_controller != null) {
        if (double.parse(addressModel!.latitude!) <
            double.parse(store!.latitude!)) {
          bounds = LatLngBounds(
            southwest: LatLng(
              double.parse(addressModel.latitude!),
              double.parse(addressModel.longitude!),
            ),
            northeast: LatLng(
              double.parse(store.latitude!),
              double.parse(store.longitude!),
            ),
          );
          rotation = 0;
        } else {
          bounds = LatLngBounds(
            southwest: LatLng(
              double.parse(store.latitude!),
              double.parse(store.longitude!),
            ),
            northeast: LatLng(
              double.parse(addressModel.latitude!),
              double.parse(addressModel.longitude!),
            ),
          );
          rotation = 180;
        }
      }
      LatLng centerBounds = LatLng(
        (bounds!.northeast.latitude + bounds.southwest.latitude) / 2,
        (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
      );

      if (fromCurrentLocation && currentAddress != null) {
        LatLng currentLocation = LatLng(
          double.parse(currentAddress.latitude!),
          double.parse(currentAddress.longitude!),
        );
        _controller!.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: currentLocation,
              zoom: GetPlatform.isWeb ? 7 : 15,
            ),
          ),
        );
      }

      if (!fromCurrentLocation) {
        _controller!.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: centerBounds,
              zoom: GetPlatform.isWeb ? 10 : 17,
            ),
          ),
        );
        if (!ResponsiveHelper.isWeb()) {
          zoomToFit(
            _controller,
            bounds,
            centerBounds,
            padding: GetPlatform.isWeb ? 15 : 3,
          );
        }
      }

      /// user for normal order , but sender for parcel order
      _markers = HashSet<Marker>();

      ///current location marker set
      if (currentAddress != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            visible: true,
            draggable: false,
            zIndex: 2,
            flat: true,
            anchor: const Offset(0.5, 0.5),
            position: LatLng(
              double.parse(currentAddress.latitude!),
              double.parse(currentAddress.longitude!),
            ),
            icon: destinationImageData,
          ),
        );
        setState(() {});
      }

      if (currentAddress == null) {
        addressModel != null
            ? _markers.add(
                Marker(
                  markerId: const MarkerId('destination'),
                  position: LatLng(
                    double.parse(addressModel.latitude!),
                    double.parse(addressModel.longitude!),
                  ),
                  infoWindow: InfoWindow(
                    title: parcel ? 'sender'.tr : 'Destination'.tr,
                    snippet: addressModel.address,
                  ),
                  icon: destinationImageData,
                ),
              )
            : const SizedBox();
      }

      ///store for normal order , but receiver for parcel order
      store != null
          ? _markers.add(
              Marker(
                markerId: const MarkerId('store'),
                position: LatLng(
                  double.parse(store.latitude!),
                  double.parse(store.longitude!),
                ),
                infoWindow: InfoWindow(
                  title: parcel
                      ? 'receiver'.tr
                      : Get.find<SplashController>()
                            .configModel!
                            .moduleConfig!
                            .module!
                            .showRestaurantText!
                      ? 'store'.tr
                      : 'store'.tr,
                  snippet: store.address,
                ),
                icon: restaurantImageData,
              ),
            )
          : const SizedBox();

      deliveryMan != null
          ? _markers.add(
              Marker(
                markerId: const MarkerId('delivery_boy'),
                position: LatLng(
                  double.parse(deliveryMan.lat ?? '0'),
                  double.parse(deliveryMan.lng ?? '0'),
                ),
                infoWindow: InfoWindow(
                  title: 'delivery_man'.tr,
                  snippet: deliveryMan.location,
                ),
                rotation: rotation,
                icon: deliveryBoyImageData,
              ),
            )
          : const SizedBox();
    } catch (_) {}
    setState(() {});
  }

  Future<void> zoomToFit(
    GoogleMapController? controller,
    LatLngBounds? bounds,
    LatLng centerBounds, {
    double padding = 0.5,
  }) async {
    bool keepZoomingOut = true;

    while (keepZoomingOut) {
      final LatLngBounds screenBounds = await controller!.getVisibleRegion();
      if (fits(bounds!, screenBounds)) {
        keepZoomingOut = false;
        final double zoomLevel = await controller.getZoomLevel() - padding;
        controller.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: centerBounds, zoom: zoomLevel),
          ),
        );
        break;
      } else {
        // Zooming out by 0.1 zoom level per iteration
        final double zoomLevel = await controller.getZoomLevel() - 0.1;
        controller.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: centerBounds, zoom: zoomLevel),
          ),
        );
      }
    }
  }

  bool fits(LatLngBounds fitBounds, LatLngBounds screenBounds) {
    final bool northEastLatitudeCheck =
        screenBounds.northeast.latitude >= fitBounds.northeast.latitude;
    final bool northEastLongitudeCheck =
        screenBounds.northeast.longitude >= fitBounds.northeast.longitude;

    final bool southWestLatitudeCheck =
        screenBounds.southwest.latitude <= fitBounds.southwest.latitude;
    final bool southWestLongitudeCheck =
        screenBounds.southwest.longitude <= fitBounds.southwest.longitude;

    return northEastLatitudeCheck &&
        northEastLongitudeCheck &&
        southWestLatitudeCheck &&
        southWestLongitudeCheck;
  }

  Future<void> _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr);
    } else if (permission == LocationPermission.deniedForever) {
      Get.dialog(const PermissionDialogWidget());
    } else {
      onTap();
    }
  }
}
