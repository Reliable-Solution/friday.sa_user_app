import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:friday_sa/common/controllers/theme_controller.dart';
import 'package:friday_sa/features/language/controllers/language_controller.dart';
import 'package:friday_sa/features/location/controllers/location_controller.dart';
import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/features/profile/controllers/profile_controller.dart';
import 'package:friday_sa/features/address/controllers/address_controller.dart';
import 'package:friday_sa/features/address/domain/models/address_model.dart';
import 'package:friday_sa/features/auth/controllers/auth_controller.dart';
import 'package:friday_sa/features/location/widgets/permission_dialog_widget.dart';
import 'package:friday_sa/helper/auth_helper.dart';
import 'package:friday_sa/helper/custom_validator.dart';
import 'package:friday_sa/helper/responsive_helper.dart';
import 'package:friday_sa/helper/route_helper.dart';
import 'package:friday_sa/util/app_constants.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/images.dart';
import 'package:friday_sa/util/styles.dart';
import 'package:friday_sa/common/widgets/custom_app_bar.dart';
import 'package:friday_sa/common/widgets/custom_button.dart';
import 'package:friday_sa/common/widgets/custom_snackbar.dart';
import 'package:friday_sa/common/widgets/custom_text_field.dart';
import 'package:friday_sa/common/widgets/footer_view.dart';
import 'package:friday_sa/common/widgets/menu_drawer.dart';
import 'package:friday_sa/features/location/screens/pick_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({
    super.key,
    required this.fromCheckout,
    required this.fromRide,
    this.address,
    this.zoneId,
    this.forGuest = false,
    this.fromNavBar = false,
  });
  final bool fromCheckout;
  final bool fromRide;
  final AddressModel? address;
  final int? zoneId;
  final bool forGuest;
  final bool fromNavBar;

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactPersonNameController =
      TextEditingController();
  final TextEditingController _contactPersonNumberController =
      TextEditingController();
  final TextEditingController _streetNumberController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _addressNode = FocusNode();
  final FocusNode _nameNode = FocusNode();
  final FocusNode _numberNode = FocusNode();
  final FocusNode _streetNode = FocusNode();
  final FocusNode _houseNode = FocusNode();
  final FocusNode _floorNode = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  CameraPosition? _cameraPosition;
  late LatLng _initialPosition;

  String? _countryDialCode =
      Get.find<AuthController>().getUserCountryCode().isNotEmpty
      ? Get.find<AuthController>().getUserCountryCode()
      : CountryCode.fromCountryCode(
          Get.find<SplashController>().configModel!.country!,
        ).dialCode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initLocation();

    if (widget.address != null) {
      splitPhoneNumber(widget.address!.contactPersonNumber!);
      _contactPersonNameController.text =
          widget.address!.contactPersonName ?? '';
      _emailController.text = widget.address!.email ?? '';
      _streetNumberController.text = widget.address!.streetNumber ?? '';
      _houseController.text = widget.address!.house ?? '';
      _floorController.text = widget.address!.floor ?? '';
    } else if (Get.find<ProfileController>().userInfoModel != null &&
        _contactPersonNameController.text.isEmpty) {
      _contactPersonNameController.text =
          '${Get.find<ProfileController>().userInfoModel!.fName} ${Get.find<ProfileController>().userInfoModel!.lName}';
      splitPhoneNumber(Get.find<ProfileController>().userInfoModel!.phone!);
    }
  }

  void _initLocation() async {
    initCall();
    if (widget.address == null) {
      setState(() => _isLoading = true);
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
          _initialPosition = LatLng(position.latitude, position.longitude);
        }
      } catch (e) {
        debugPrint('Error getting current location: $e');
      }
      setState(() => _isLoading = false);
    }
  }

  void initCall() {
    Get.find<LocationController>().setAddressTypeIndex(0, isUpdate: false);
    if (AuthHelper.isLoggedIn() &&
        Get.find<ProfileController>().userInfoModel == null) {
      Get.find<ProfileController>().getUserInfo();
    }
    if (widget.address == null) {
      _initialPosition = LatLng(
        double.parse(
          Get.find<SplashController>().configModel!.defaultLocation!.lat ?? '0',
        ),
        double.parse(
          Get.find<SplashController>().configModel!.defaultLocation!.lng ?? '0',
        ),
      );
    } else {
      Get.find<LocationController>().setUpdateAddress(widget.address!);
      _initialPosition = LatLng(
        double.parse(widget.address!.latitude ?? '0'),
        double.parse(widget.address!.longitude ?? '0'),
      );

      if (widget.address!.addressType == 'home') {
        Get.find<LocationController>().setAddressTypeIndex(0, isUpdate: false);
      } else if (widget.address!.addressType == 'office') {
        Get.find<LocationController>().setAddressTypeIndex(1, isUpdate: false);
      } else if (widget.address!.addressType == 'others') {

      }
    }
  }

  Future<void> splitPhoneNumber(String number) async {
    try {
      PhoneNumber phoneNumber = PhoneNumber.parse(number);
      _countryDialCode = '+${phoneNumber.countryCode}';
      _contactPersonNumberController.text = phoneNumber.international.substring(
        _countryDialCode!.length,
      );
    } catch (e) {
      debugPrint('number can\'t parse : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      appBar: CustomAppBar(
        title: widget.forGuest
            ? 'set_address'.tr
            : widget.address == null
            ? 'add_new_address'.tr
            : 'update_address'.tr,
      ),
      body: SafeArea(
        child: GetBuilder<ProfileController>(
          builder: (profileController) {
            return GetBuilder<LocationController>(
              builder: (locationController) {
                _addressController.text = locationController.address!;

                return ResponsiveHelper.isDesktop(context)
                    ? SingleChildScrollView(
                        child: FooterView(
                          child: Column(
                            children: [
                              Container(
                                height: 64,
                                color: Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.10),
                                child: Center(
                                  child: Text(
                                    'address'.tr,
                                    style: robotoMedium,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeLarge,
                              ),
                              Center(
                                child: SizedBox(
                                  width: Dimensions.webMaxWidth,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(
                                          Dimensions.paddingSizeLarge,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            Dimensions.radiusDefault,
                                          ),
                                          color: Theme.of(context).cardColor,
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 5,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 680,
                                              height: 250,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      Dimensions.radiusSmall,
                                                    ),
                                                border: Border.all(
                                                  width: 2,
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColor,
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      Dimensions.radiusSmall,
                                                    ),
                                                child: _isLoading ? const Center(child: CircularProgressIndicator()) : Stack(
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    GoogleMap(
                                                      initialCameraPosition:
                                                          CameraPosition(
                                                            target:
                                                                _initialPosition,
                                                            zoom: 16,
                                                          ),
                                                      minMaxZoomPreference:
                                                          const MinMaxZoomPreference(
                                                            0,
                                                            16,
                                                          ),
                                                      onTap: (latLng) {
                                                        if (ResponsiveHelper.isDesktop(
                                                          Get.context,
                                                        )) {
                                                        } else {
                                                          Get.toNamed(
                                                            RouteHelper.getPickMapRoute(
                                                              'add-address',
                                                              false,
                                                            ),
                                                            arguments: PickMapScreen(
                                                              fromAddAddress:
                                                                  true,
                                                              fromSignUp: false,
                                                              googleMapController:
                                                                  locationController
                                                                      .mapController,
                                                              route: null,
                                                              canRoute: false,
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      zoomControlsEnabled:
                                                          false,
                                                      compassEnabled: false,
                                                      indoorViewEnabled: true,
                                                      mapToolbarEnabled: false,
                                                      onCameraIdle: () {
                                                        locationController
                                                            .updatePosition(
                                                              _cameraPosition,
                                                              true,
                                                            );
                                                      },
                                                      onCameraMove:
                                                          (position) =>
                                                              _cameraPosition =
                                                                  position,
                                                      onMapCreated:
                                                          (
                                                            GoogleMapController
                                                            controller,
                                                          ) {
                                                            locationController
                                                                .setMapController(
                                                                  controller,
                                                                );
                                                            if (widget
                                                                    .address ==
                                                                null) {
                                                              locationController
                                                                  .getCurrentLocation(
                                                                    true,
                                                                    mapController:
                                                                        controller,
                                                                  );
                                                            }
                                                          },
                                                      style: Get.isDarkMode
                                                          ? Get.find<
                                                                  ThemeController
                                                                >()
                                                                .darkMap
                                                          : Get.find<
                                                                  ThemeController
                                                                >()
                                                                .lightMap,
                                                      gestureRecognizers:
                                                          const <
                                                            Factory<
                                                              OneSequenceGestureRecognizer
                                                            >
                                                          >{
                                                            Factory<
                                                              OneSequenceGestureRecognizer
                                                            >(
                                                              EagerGestureRecognizer
                                                                  .new,
                                                            ),
                                                            Factory<
                                                              PanGestureRecognizer
                                                            >(
                                                              PanGestureRecognizer
                                                                  .new,
                                                            ),
                                                            Factory<
                                                              ScaleGestureRecognizer
                                                            >(
                                                              ScaleGestureRecognizer
                                                                  .new,
                                                            ),
                                                            Factory<
                                                              TapGestureRecognizer
                                                            >(
                                                              TapGestureRecognizer
                                                                  .new,
                                                            ),
                                                            Factory<
                                                              VerticalDragGestureRecognizer
                                                            >(
                                                              VerticalDragGestureRecognizer
                                                                  .new,
                                                            ),
                                                          },
                                                    ),
                                                    locationController.loading
                                                        ? const Center(
                                                            child:
                                                                CircularProgressIndicator(),
                                                          )
                                                        : const SizedBox(),
                                                    Center(
                                                      child:
                                                          !locationController.loading
                                                          ? Stack(alignment: Alignment.topCenter, children: [
                                                              Image.asset(
                                                                Images.pickMarkerBack,
                                                                height: 60,
                                                                width: 60,
                                                              ),
                                                              Positioned(
                                                                top: 05,
                                                                child: Text(
                                                                  'pick'.tr,
                                                                  style: robotoBold.copyWith(color: Colors.white, fontSize: 13),
                                                                ),
                                                              ),
                                                            ])
                                                          : const CircularProgressIndicator(),
                                                    ),
                                                    Positioned(
                                                      bottom: 10,
                                                      right: 0,
                                                      child: InkWell(
                                                        onTap: () => _checkPermission(() {
                                                          locationController
                                                              .getCurrentLocation(
                                                                true,
                                                                mapController:
                                                                    locationController
                                                                        .mapController,
                                                              );
                                                        }),
                                                        child: Container(
                                                          width: 30,
                                                          height: 30,
                                                          margin: const EdgeInsets.only(
                                                            right: Dimensions
                                                                .paddingSizeLarge,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  Dimensions
                                                                      .radiusSmall,
                                                                ),
                                                            color: Colors.white,
                                                          ),
                                                          child: Icon(
                                                            Icons.my_location,
                                                            color: Theme.of(
                                                              context,
                                                            ).primaryColor,
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 10,
                                                      right: 0,
                                                      child: InkWell(
                                                        onTap: () {
                                                          if (ResponsiveHelper.isDesktop(
                                                            Get.context,
                                                          )) {
                                                            showGeneralDialog(
                                                              context: context,
                                                              pageBuilder: (_, __, ___) {
                                                                return SizedBox(
                                                                  height: 300,
                                                                  width: 300,
                                                                  child: PickMapScreen(
                                                                    fromSignUp:
                                                                        false,
                                                                    canRoute:
                                                                        false,
                                                                    fromAddAddress:
                                                                        true,
                                                                    route: null,
                                                                    googleMapController:
                                                                        locationController
                                                                            .mapController,
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          } else {
                                                            Get.toNamed(
                                                              RouteHelper.getPickMapRoute(
                                                                'add-address',
                                                                false,
                                                              ),
                                                              arguments: PickMapScreen(
                                                                fromAddAddress:
                                                                    true,
                                                                fromSignUp:
                                                                    false,
                                                                googleMapController:
                                                                    locationController
                                                                        .mapController,
                                                                route: null,
                                                                canRoute: false,
                                                              ),
                                                            );
                                                          }
                                                        },
                                                        child: Container(
                                                          width: 30,
                                                          height: 30,
                                                          margin: const EdgeInsets.only(
                                                            right: Dimensions
                                                                .paddingSizeLarge,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  Dimensions
                                                                      .radiusSmall,
                                                                ),
                                                            color: Colors.white,
                                                          ),
                                                          child: Icon(
                                                            Icons.fullscreen,
                                                            color: Theme.of(
                                                              context,
                                                            ).primaryColor,
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeLarge,
                                            ),
                                            Text(
                                              'label_as'.tr,
                                              style: robotoRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                                color: Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium!.color,
                                              ),
                                            ),
                                            const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeSmall,
                                            ),
                                            SizedBox(
                                              height: 50,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: locationController
                                                    .addressTypeList
                                                    .length,
                                                itemBuilder: (context, index) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: Dimensions
                                                            .paddingSizeSmall,
                                                      ),
                                                  child: InkWell(
                                                    onTap: () {

                                                      locationController
                                                          .setAddressTypeIndex(
                                                            index,
                                                          );
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: Dimensions
                                                            .paddingSizeLarge,
                                                        vertical: Dimensions
                                                            .paddingSizeSmall,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              Dimensions
                                                                  .radiusDefault,
                                                            ),
                                                        color:
                                                            locationController
                                                                    .addressTypeIndex ==
                                                                index
                                                            ? Theme.of(
                                                                context,
                                                              ).primaryColor
                                                            : Theme.of(
                                                                context,
                                                              ).cardColor,
                                                        boxShadow: const [
                                                          BoxShadow(
                                                            color:
                                                                Colors.black12,
                                                            spreadRadius: 1,
                                                            blurRadius: 5,
                                                          ),
                                                        ],
                                                        // border: Border.all(color: locationController.addressTypeIndex == index ? Theme.of(context).primaryColor : Theme.of(context).disabledColor)
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            height: 24,
                                                            width: 24,
                                                            child: Image.asset(
                                                              index == 0
                                                                  ? Images
                                                                        .homeIcon
                                                                  : index == 1
                                                                  ? Images
                                                                        .workIcon
                                                                  : Images
                                                                        .otherIcon,
                                                              color:
                                                                  locationController
                                                                          .addressTypeIndex ==
                                                                      index
                                                                  ? Theme.of(
                                                                      context,
                                                                    ).cardColor
                                                                  : Theme.of(
                                                                      context,
                                                                    ).disabledColor,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: Dimensions
                                                                .paddingSizeSmall,
                                                          ),
                                                          Text(
                                                            index == 0
                                                                ? 'homes'.tr
                                                                : index == 1
                                                                ? 'office'.tr
                                                                : 'others'.tr,
                                                            style: robotoRegular.copyWith(
                                                              color:
                                                                  locationController
                                                                          .addressTypeIndex ==
                                                                      index
                                                                  ? Theme.of(
                                                                      context,
                                                                    ).cardColor
                                                                  : Theme.of(
                                                                      context,
                                                                    ).disabledColor,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeSmall,
                                            ),

                                            const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeLarge,
                                            ),
                                            SizedBox(
                                              height: 90,
                                              width: 680,
                                              child: CustomTextField(
                                                suffixIcon: Icons.my_location,
                                                showTitle: true,
                                                titleText:
                                                    'delivery_address'.tr,
                                                hintText:
                                                    'write_delivery_address'.tr,
                                                inputType:
                                                    TextInputType.streetAddress,
                                                controller: _addressController,
                                                focusNode: _addressNode,
                                                nextFocus: _nameNode,
                                                onChanged: (text) =>
                                                    locationController
                                                        .setPlaceMark(text),
                                              ),
                                            ),
                                            const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeLarge,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: Dimensions.paddingSizeLarge,
                                      ),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(
                                            Dimensions.paddingSizeLarge,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              Dimensions.radiusDefault,
                                            ),
                                            color: Theme.of(context).cardColor,
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 5,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: [
                                              CustomTextField(
                                                showTitle: true,
                                                titleText:
                                                    'contact_person_name'.tr,
                                                hintText: 'write_name'.tr,
                                                showLabelText: false,
                                                inputType: TextInputType.name,
                                                controller:
                                                    _contactPersonNameController,
                                                focusNode: _nameNode,
                                                nextFocus: _numberNode,
                                                capitalization:
                                                    TextCapitalization.words,
                                              ),
                                              const SizedBox(
                                                height:
                                                    Dimensions.paddingSizeLarge,
                                              ),
                                              CustomTextField(
                                                showTitle: true,
                                                titleText:
                                                    'contact_person_number'.tr,
                                                hintText: 'write_number'.tr,
                                                showLabelText: false,
                                                controller:
                                                    _contactPersonNumberController,
                                                focusNode: _numberNode,
                                                nextFocus: widget.forGuest
                                                    ? _emailFocus
                                                    : _streetNode,
                                                inputType: TextInputType.phone,
                                                isPhone: true,
                                                onCountryChanged:
                                                    (CountryCode countryCode) {
                                                      _countryDialCode =
                                                          countryCode.dialCode;
                                                    },
                                                countryDialCode:
                                                    _countryDialCode ??
                                                    Get.find<
                                                          LocalizationController
                                                        >()
                                                        .locale
                                                        .countryCode,
                                              ),
                                              const SizedBox(
                                                height:
                                                    Dimensions.paddingSizeLarge,
                                              ),
                                              widget.forGuest
                                                  ? CustomTextField(
                                                      showTitle: true,
                                                      titleText: 'email'.tr,
                                                      hintText: 'email'.tr,
                                                      showLabelText: false,
                                                      controller:
                                                          _emailController,
                                                      focusNode: _emailFocus,
                                                      nextFocus: _streetNode,
                                                      inputType: TextInputType
                                                          .emailAddress,
                                                    )
                                                  : const SizedBox(),
                                              SizedBox(
                                                height: widget.forGuest
                                                    ? Dimensions
                                                          .paddingSizeLarge
                                                    : 0,
                                              ),
                                              CustomTextField(
                                                showTitle: true,
                                                hintText: 'street_number'.tr,
                                                titleText:
                                                    '${'street_number'.tr} (${'optional'.tr})',
                                                showLabelText: false,
                                                inputType:
                                                    TextInputType.streetAddress,
                                                focusNode: _streetNode,
                                                nextFocus: _houseNode,
                                                controller:
                                                    _streetNumberController,
                                              ),
                                              const SizedBox(
                                                height:
                                                    Dimensions.paddingSizeLarge,
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: CustomTextField(
                                                      showTitle: true,
                                                      hintText: 'house_name'.tr,
                                                      titleText:
                                                          '${'house'.tr} (${'optional'.tr})',
                                                      showLabelText: false,
                                                      inputType:
                                                          TextInputType.text,
                                                      focusNode: _houseNode,
                                                      nextFocus: _floorNode,
                                                      controller:
                                                          _houseController,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeSmall,
                                                  ),
                                                  Expanded(
                                                    child: CustomTextField(
                                                      hintText:
                                                          'floor_number'.tr,
                                                      showLabelText: false,
                                                      showTitle: true,
                                                      titleText:
                                                          "${'floor'.tr} (${'optional'.tr})",
                                                      inputType:
                                                          TextInputType.text,
                                                      focusNode: _floorNode,
                                                      inputAction:
                                                          TextInputAction.done,
                                                      controller:
                                                          _floorController,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height:
                                                    Dimensions.paddingSizeLarge,
                                              ),
                                              button(locationController),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeSmall,
                                horizontal: Dimensions.paddingSizeLarge,
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: Dimensions.webMaxWidth,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 160,
                                        width: MediaQuery.of(
                                          context,
                                        ).size.width,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            Dimensions.radiusDefault,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.08),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            Dimensions.radiusDefault,
                                          ),
                                          child: _isLoading ? const Center(child: CircularProgressIndicator()) : Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              GoogleMap(
                                                initialCameraPosition:
                                                    CameraPosition(
                                                      target: _initialPosition,
                                                      zoom: 16,
                                                    ),
                                                minMaxZoomPreference:
                                                    const MinMaxZoomPreference(
                                                      0,
                                                      16,
                                                    ),
                                                onTap: (latLng) {
                                                  if (ResponsiveHelper.isDesktop(
                                                    Get.context,
                                                  )) {
                                                    showGeneralDialog(
                                                      context: context,
                                                      pageBuilder: (_, __, ___) {
                                                        return SizedBox(
                                                          height: 300,
                                                          width: 300,
                                                          child: PickMapScreen(
                                                            fromSignUp: false,
                                                            canRoute: false,
                                                            fromAddAddress:
                                                                true,
                                                            route: null,
                                                            googleMapController:
                                                                locationController
                                                                    .mapController,
                                                          ),
                                                        );
                                                      },
                                                    );
                                                    // Get.dialog(PickMapScreen(fromSignUp: false, canRoute: false, fromAddAddress: true, route: null, googleMapController: locationController.mapController));
                                                  } else {
                                                    Get.toNamed(
                                                      RouteHelper.getPickMapRoute(
                                                        'add-address',
                                                        false,
                                                      ),
                                                      arguments: PickMapScreen(
                                                        fromAddAddress: true,
                                                        fromSignUp: false,
                                                        googleMapController:
                                                            locationController
                                                                .mapController,
                                                        route: null,
                                                        canRoute: false,
                                                      ),
                                                    );
                                                  }
                                                },
                                                zoomControlsEnabled: false,
                                                compassEnabled: false,
                                                indoorViewEnabled: true,
                                                mapToolbarEnabled: false,
                                                onCameraIdle: () {
                                                  locationController
                                                      .updatePosition(
                                                        _cameraPosition,
                                                        true,
                                                      );
                                                },
                                                onCameraMove: (position) {
                                                  _cameraPosition = position;
                                                },
                                                onMapCreated:
                                                    (
                                                      GoogleMapController
                                                      controller,
                                                    ) {
                                                      locationController
                                                          .setMapController(
                                                            controller,
                                                          );
                                                      if (widget.address ==
                                                          null) {
                                                        locationController
                                                            .getCurrentLocation(
                                                              true,
                                                              mapController:
                                                                  controller,
                                                            );
                                                      }
                                                    },
                                                myLocationButtonEnabled: false,
                                                style: Get.isDarkMode
                                                    ? Get.find<
                                                            ThemeController
                                                          >()
                                                          .darkMap
                                                    : Get.find<
                                                            ThemeController
                                                          >()
                                                          .lightMap,
                                                gestureRecognizers:
                                                    const <
                                                      Factory<
                                                        OneSequenceGestureRecognizer
                                                      >
                                                    >{
                                                      Factory<
                                                        OneSequenceGestureRecognizer
                                                      >(
                                                        EagerGestureRecognizer
                                                            .new,
                                                      ),
                                                      Factory<
                                                        PanGestureRecognizer
                                                      >(
                                                        PanGestureRecognizer
                                                            .new,
                                                      ),
                                                      Factory<
                                                        ScaleGestureRecognizer
                                                      >(
                                                        ScaleGestureRecognizer
                                                            .new,
                                                      ),
                                                      Factory<
                                                        TapGestureRecognizer
                                                      >(
                                                        TapGestureRecognizer
                                                            .new,
                                                      ),
                                                      Factory<
                                                        VerticalDragGestureRecognizer
                                                      >(
                                                        VerticalDragGestureRecognizer
                                                            .new,
                                                      ),
                                                    },
                                              ),
                                              locationController.loading
                                                  ? const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    )
                                                  : const SizedBox(),
                                              Center(
                                                child:
                                                    !locationController.loading
                                                    ? Stack(alignment: Alignment.topCenter, children: [
                                                  Image.asset(
                                                    Images.pickMarkerBack,
                                                    height: 60,
                                                    width: 60,
                                                  ),
                                                  Positioned(
                                                    top: 05,
                                                    child: Text(
                                                      'pick'.tr,
                                                      style: robotoBold.copyWith(color: Colors.white, fontSize: 13),
                                                    ),
                                                  ),
                                                ])
                                                    : const CircularProgressIndicator(),
                                              ),
                                              Positioned(
                                                bottom: 10,
                                                right: 10,
                                                child: Material(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                                  elevation: 3,
                                                  clipBehavior: Clip.antiAlias,
                                                  child: InkWell(
                                                    onTap: () => _checkPermission(() {
                                                      locationController
                                                          .getCurrentLocation(
                                                            true,
                                                            mapController:
                                                                locationController
                                                                    .mapController,
                                                          );
                                                    }),
                                                    child: Container(
                                                      width: 36,
                                                      height: 36,
                                                      alignment: Alignment.center,
                                                      child: Icon(
                                                        Icons.my_location,
                                                        color: Theme.of(
                                                          context,
                                                        ).primaryColor,
                                                        size: 20,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 10,
                                                right: 10,
                                                child: Material(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                                  elevation: 3,
                                                  clipBehavior: Clip.antiAlias,
                                                  child: InkWell(
                                                    onTap: () {
                                                      if (ResponsiveHelper.isDesktop(
                                                        Get.context,
                                                      )) {
                                                        showGeneralDialog(
                                                          context: context,
                                                          pageBuilder: (_, __, ___) {
                                                            return SizedBox(
                                                              height: 300,
                                                              width: 300,
                                                              child: PickMapScreen(
                                                                fromSignUp: false,
                                                                canRoute: false,
                                                                fromAddAddress:
                                                                    true,
                                                                route: null,
                                                                googleMapController:
                                                                    locationController
                                                                        .mapController,
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      } else {
                                                        Get.toNamed(
                                                          RouteHelper.getPickMapRoute(
                                                            'add-address',
                                                            false,
                                                          ),
                                                          arguments: PickMapScreen(
                                                            fromAddAddress: true,
                                                            fromSignUp: false,
                                                            googleMapController:
                                                                locationController
                                                                    .mapController,
                                                            route: null,
                                                            canRoute: false,
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child: Container(
                                                      width: 36,
                                                      height: 36,
                                                      alignment: Alignment.center,
                                                      child: Icon(
                                                        Icons.fullscreen,
                                                        color: Theme.of(
                                                          context,
                                                        ).primaryColor,
                                                        size: 20,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: Dimensions.paddingSizeSmall,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Get.toNamed(
                                            RouteHelper.getPickMapRoute(
                                              'add-address',
                                              false,
                                            ),
                                            arguments: PickMapScreen(
                                              fromAddAddress: true,
                                              fromSignUp: false,
                                              googleMapController:
                                                  locationController
                                                      .mapController,
                                              route: null,
                                              canRoute: false,
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: Dimensions.paddingSizeDefault,
                                            vertical: Dimensions.paddingSizeSmall + 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor.withValues(alpha: 0.06),
                                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                            border: Border.all(
                                              color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.location_on_outlined,
                                                size: 18,
                                                color: Theme.of(context).primaryColor,
                                              ),
                                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                              Expanded(
                                                child: Text(
                                                  'set_location'.tr,
                                                  style: robotoMedium.copyWith(
                                                    fontSize: Dimensions.fontSizeDefault,
                                                    color: Theme.of(context).primaryColor,
                                                  ),
                                                ),
                                              ),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                size: 14,
                                                color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: Dimensions.paddingSizeLarge,
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Icon(
                                              Icons.label_outline,
                                              size: 16,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                          const SizedBox(width: Dimensions.paddingSizeExtraSmall + 2),
                                          Text(
                                            'label_as'.tr,
                                            style: robotoBold.copyWith(
                                              fontSize: Dimensions.fontSizeDefault,
                                              color: Theme.of(context).textTheme.bodyLarge!.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: Dimensions.paddingSizeSmall,
                                      ),
                                      SizedBox(
                                        height: 50,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: locationController
                                              .addressTypeList
                                              .length,
                                          itemBuilder: (context, index) => Padding(
                                            padding: const EdgeInsets.only(
                                              right:
                                                  Dimensions.paddingSizeSmall,
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () {

                                                  locationController
                                                      .setAddressTypeIndex(index);
                                                },
                                                borderRadius: BorderRadius.circular(
                                                  Dimensions.radiusDefault,
                                                ),
                                                child: AnimatedContainer(
                                                  duration: const Duration(milliseconds: 200),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: Dimensions
                                                            .paddingSizeLarge,
                                                        vertical: Dimensions
                                                            .paddingSizeSmall,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          Dimensions
                                                              .radiusDefault,
                                                        ),
                                                    color:
                                                        locationController
                                                                .addressTypeIndex ==
                                                            index
                                                        ? Theme.of(context)
                                                              .primaryColor
                                                              .withValues(
                                                                alpha: 0.1,
                                                              )
                                                        : Theme.of(
                                                            context,
                                                          ).cardColor,
                                                    border: Border.all(
                                                      color:
                                                          locationController
                                                                  .addressTypeIndex ==
                                                              index
                                                          ? Theme.of(
                                                              context,
                                                            ).primaryColor
                                                          : Theme.of(
                                                              context,
                                                            ).disabledColor.withValues(alpha: 0.3),
                                                      width: locationController
                                                                  .addressTypeIndex ==
                                                              index
                                                          ? 1.5
                                                          : 1,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        height: 20,
                                                        width: 20,
                                                        child: Image.asset(
                                                          index == 0
                                                              ? Images.homeIcon
                                                              : index == 1
                                                              ? Images.workIcon
                                                              : Images.otherIcon,
                                                          color:
                                                              locationController
                                                                      .addressTypeIndex ==
                                                                  index
                                                              ? Theme.of(
                                                                  context,
                                                                ).primaryColor
                                                              : Theme.of(
                                                                  context,
                                                                ).disabledColor,
                                                        ),
                                                      ),
                                                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                      Text(
                                                        index == 0
                                                            ? 'homes'.tr
                                                            : index == 1
                                                            ? 'office'.tr
                                                            : 'others'.tr,
                                                        style: robotoMedium.copyWith(
                                                          fontSize: Dimensions.fontSizeSmall,
                                                          color:
                                                              locationController
                                                                      .addressTypeIndex ==
                                                                  index
                                                              ? Theme.of(
                                                                  context,
                                                                ).primaryColor
                                                              : Theme.of(
                                                                  context,
                                                                ).disabledColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: Dimensions.paddingSizeLarge + 4,
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Icon(
                                              Icons.location_on_outlined,
                                              size: 16,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                          const SizedBox(width: Dimensions.paddingSizeExtraSmall + 2),
                                          Text(
                                            'delivery_address'.tr,
                                            style: robotoBold.copyWith(
                                              fontSize: Dimensions.fontSizeDefault,
                                              color: Theme.of(context).textTheme.bodyLarge!.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: Dimensions.paddingSizeSmall,
                                      ),
                                      CustomTextField(
                                        labelText:
                                            widget.fromRide ||
                                                (Get.find<SplashController>()
                                                            .module !=
                                                        null &&
                                                    Get.find<SplashController>()
                                                            .module!
                                                            .moduleType
                                                            .toString() ==
                                                        AppConstants.taxi)
                                            ? 'pickup_address'.tr
                                            : 'delivery_address'.tr,
                                        titleText: 'write_delivery_address'.tr,
                                        inputType: TextInputType.streetAddress,
                                        controller: _addressController,
                                        focusNode: _addressNode,
                                        nextFocus: _nameNode,
                                        onChanged: (text) => locationController
                                            .setPlaceMark(text),
                                      ),

                                      // Contact Details Section
                                      const SizedBox(height: Dimensions.paddingSizeLarge + 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Icon(
                                              Icons.person_outline,
                                              size: 16,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                          const SizedBox(width: Dimensions.paddingSizeExtraSmall + 2),
                                          Text(
                                            'contact_person_name'.tr,
                                            style: robotoBold.copyWith(
                                              fontSize: Dimensions.fontSizeDefault,
                                              color: Theme.of(context).textTheme.bodyLarge!.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: Dimensions.paddingSizeSmall),
                                      Container(
                                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                          border: Border.all(
                                            color: Theme.of(context).disabledColor.withValues(alpha: 0.15),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            CustomTextField(
                                              labelText: 'contact_person_name'.tr,
                                              titleText: 'write_name'.tr,
                                              inputType: TextInputType.name,
                                              controller:
                                                  _contactPersonNameController,
                                              focusNode: _nameNode,
                                              nextFocus: _numberNode,
                                              capitalization:
                                                  TextCapitalization.words,
                                            ),
                                            const SizedBox(
                                              height: Dimensions.paddingSizeLarge,
                                            ),
                                            CustomTextField(
                                              labelText: 'contact_person_number'.tr,
                                              titleText: 'write_number'.tr,
                                              controller:
                                                  _contactPersonNumberController,
                                              focusNode: _numberNode,
                                              nextFocus: widget.forGuest
                                                  ? _emailFocus
                                                  : _streetNode,
                                              inputType: TextInputType.phone,
                                              isPhone: true,
                                              onCountryChanged:
                                                  (CountryCode countryCode) {
                                                    _countryDialCode =
                                                        countryCode.dialCode;
                                                  },
                                              countryDialCode:
                                                  _countryDialCode ??
                                                  Get.find<LocalizationController>()
                                                      .locale
                                                      .countryCode,
                                            ),
                                            if (widget.forGuest) ...[
                                              const SizedBox(
                                                height: Dimensions.paddingSizeLarge,
                                              ),
                                              CustomTextField(
                                                labelText: 'email'.tr,
                                                titleText: 'enter_email'.tr,
                                                controller: _emailController,
                                                focusNode: _emailFocus,
                                                nextFocus: _streetNode,
                                                inputType:
                                                    TextInputType.emailAddress,
                                                prefixIcon: Icons.mail,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),

                                      // Additional Details Section
                                      const SizedBox(height: Dimensions.paddingSizeLarge + 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Icon(
                                              Icons.home_outlined,
                                              size: 16,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                          const SizedBox(width: Dimensions.paddingSizeExtraSmall + 2),
                                          Text(
                                            '${'street_number'.tr} & ${'house'.tr}',
                                            style: robotoBold.copyWith(
                                              fontSize: Dimensions.fontSizeDefault,
                                              color: Theme.of(context).textTheme.bodyLarge!.color,
                                            ),
                                          ),
                                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                          Text(
                                            '(${'optional'.tr})',
                                            style: robotoRegular.copyWith(
                                              fontSize: Dimensions.fontSizeSmall,
                                              color: Theme.of(context).disabledColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: Dimensions.paddingSizeSmall),
                                      Container(
                                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                          border: Border.all(
                                            color: Theme.of(context).disabledColor.withValues(alpha: 0.15),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            CustomTextField(
                                              labelText:
                                                  '${'street_number'.tr} (${'optional'.tr})',
                                              titleText: 'write_street_number'.tr,
                                              inputType: TextInputType.streetAddress,
                                              focusNode: _streetNode,
                                              nextFocus: _houseNode,
                                              controller: _streetNumberController,
                                            ),
                                            const SizedBox(
                                              height: Dimensions.paddingSizeLarge,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextField(
                                                    labelText:
                                                        '${'house'.tr} (${'optional'.tr})',
                                                    titleText:
                                                        'write_house_number'.tr,
                                                    inputType: TextInputType.text,
                                                    focusNode: _houseNode,
                                                    nextFocus: _floorNode,
                                                    controller: _houseController,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: Dimensions.paddingSizeDefault,
                                                ),
                                                Expanded(
                                                  child: CustomTextField(
                                                    labelText:
                                                        "${'floor'.tr} (${'optional'.tr})",
                                                    titleText:
                                                        'write_floor_number'.tr,
                                                    inputType: TextInputType.text,
                                                    focusNode: _floorNode,
                                                    inputAction: TextInputAction.done,
                                                    controller: _floorController,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: Dimensions.paddingSizeLarge,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          button(locationController),
                        ],
                      );
              },
            );
          },
        ),
      ),
    );
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

  Widget button(LocationController locationController) {
    return Container(
      width: Dimensions.webMaxWidth,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
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
        child: CustomButton(
          radius: Dimensions.radiusDefault,
          isBold: true,
          isLoading: locationController.isLoading,
          buttonText: widget.forGuest
              ? 'done'.tr
              : widget.address == null
              ? 'save_location'.tr
              : 'update_address'.tr,
          onPressed: () async => _onSaveOrUpdateButtonPressed(locationController),
        ),
      ),
    );
  }

  Future<void> _onSaveOrUpdateButtonPressed(
    LocationController locationController,
  ) async {
    String numberWithCountryCode =
        _countryDialCode! + _contactPersonNumberController.text;
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(
      numberWithCountryCode,
    );
    numberWithCountryCode = phoneValid.phone;

    AddressModel? addressModel = _prepareAddressModel(
      locationController,
      phoneValid.isValid,
      numberWithCountryCode,
    );
    if (addressModel == null) {
      return;
    }

    if (widget.forGuest) {
      addressModel.email = _emailController.text;
      Get.back(result: addressModel);
    } else {
      if (widget.address == null) {
        _addAddress(addressModel);
      } else {
        _updateAddress(addressModel);
      }
    }
  }

  AddressModel? _prepareAddressModel(
    LocationController locationController,
    bool isValid,
    String numberWithCountryCode,
  ) {
    String? addressType =
        locationController.addressTypeList[locationController.addressTypeIndex];
    if (_addressController.text.isEmpty) {
      showCustomSnackBar('please_enter_the_delivery_address'.tr);
    } else if (_contactPersonNameController.text.isEmpty) {
      showCustomSnackBar('please_enter_the_contact_person_name'.tr);
    } else if (_contactPersonNumberController.text.isEmpty) {
      showCustomSnackBar('please_enter_the_phone_number'.tr);
    } else if (!isValid) {
      showCustomSnackBar('invalid_phone_number'.tr);
    } else if (widget.forGuest && _emailController.text.isEmpty) {
      showCustomSnackBar('please_enter_contact_person_email'.tr);
    } else {
      AddressModel addressModel = AddressModel(
        id: widget.address?.id,
        addressType: addressType,
        contactPersonName: _contactPersonNameController.text,
        contactPersonNumber:
            _countryDialCode! + _contactPersonNumberController.text,
        address: _addressController.text,
        latitude: locationController.position.latitude.toString(),
        longitude: locationController.position.longitude.toString(),
        zoneId: locationController.zoneID,
        streetNumber: _streetNumberController.text,
        house: _houseController.text,
        floor: _floorController.text,
      );
      return addressModel;
    }
    return null;
  }

  void _addAddress(AddressModel addressModel) {
    Get.find<AddressController>()
        .addAddress(addressModel, widget.fromCheckout, widget.zoneId)
        .then((response) {
          if (response.isSuccess && !widget.fromCheckout) {
            widget.fromNavBar
                ? Get.back()
                : Get.offNamed(RouteHelper.getAddressRoute());
            showCustomSnackBar(
              'new_address_added_successfully'.tr,
              isError: false,
            );
          } else if (response.isSuccess && widget.fromCheckout) {
            AddressModel? addressModel;
            try {
              addressModel = Get.find<AddressController>().addressList![0];
            } catch (_) {}
            Get.back(result: addressModel);
            showCustomSnackBar(response.message, isError: false);
          } else if (widget.fromRide) {
            Get.back();
          } else {
            showCustomSnackBar(response.message);
          }
        });
  }

  void _updateAddress(AddressModel addressModel) {
    Get.find<AddressController>()
        .updateAddress(addressModel, widget.address!.id)
        .then((response) {
          if (response.isSuccess) {
            Get.back();
            showCustomSnackBar(response.message, isError: false);
          } else {
            showCustomSnackBar(response.message);
          }
        });
  }
}
