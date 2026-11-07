                         import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:friday_sa/common/widgets/custom_image.dart';
import 'package:friday_sa/common/widgets/custom_loader.dart';
import 'package:friday_sa/common/widgets/custom_text_field.dart';
import 'package:friday_sa/common/widgets/menu_drawer.dart';
import 'package:friday_sa/common/widgets/web_menu_bar.dart';
import 'package:friday_sa/features/language/controllers/language_controller.dart';
import 'package:friday_sa/features/profile/controllers/profile_controller.dart';
import 'package:friday_sa/features/profile/domain/models/update_user_model.dart';
import 'package:friday_sa/features/auth/controllers/auth_controller.dart';
import 'package:friday_sa/features/profile/widgets/profile_bg_widget.dart';
import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/helper/custom_validator.dart';
import 'package:friday_sa/helper/responsive_helper.dart';
import 'package:friday_sa/helper/validate_check.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/images.dart';
import 'package:friday_sa/util/styles.dart';
import 'package:friday_sa/common/widgets/custom_button.dart';
import 'package:friday_sa/common/widgets/custom_snackbar.dart';
import 'package:friday_sa/common/widgets/footer_view.dart';
import 'package:friday_sa/common/widgets/not_logged_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  JustTheController toolController = JustTheController();
  final ScrollController scrollController = ScrollController();
  bool isPhoneVerified = false;
  bool isEmailVerified = false;
  String? _countryDialCode;
  bool _isPhoneLoading = true;

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  void _initCall() {
    AuthController authController = Get.find<AuthController>();
    _countryDialCode = authController.getUserCountryCode().isNotEmpty
        ? authController.getUserCountryCode()
        : CountryCode.fromCountryCode(
      Get.find<SplashController>().configModel!.country!,
    ).dialCode;

    if (Get.find<AuthController>().isLoggedIn() &&
        Get.find<ProfileController>().userInfoModel == null) {
      Get.find<ProfileController>().getUserInfo();
    }
    Get.find<ProfileController>().getUserInfo();
    Get.find<ProfileController>().initData();
  }

  @override
  void dispose() {
    toolController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _splitPhoneNumber(String number) async {
    _isPhoneLoading = true;
    try {
      PhoneValid phoneNumber = await CustomValidator.isPhoneValid(number);
      _phoneController.text = phoneNumber.phone.replaceFirst(
        '+${phoneNumber.countryCode}',
        '',
      );
      _countryDialCode = '+${phoneNumber.countryCode}';
    } catch (_) {}
    setState(() {
      _isPhoneLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    return
      Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GetBuilder<ProfileController>(
        builder: (profileController) {
          if (profileController.userInfoModel != null &&
              _phoneController.text.isEmpty &&
              _isPhoneLoading) {
            if (profileController.userInfoModel?.phone != null &&
                profileController.userInfoModel!.phone!.isNotEmpty) {
              _splitPhoneNumber(profileController.userInfoModel!.phone!);
            }
          }

          if (profileController.userInfoModel != null &&
              _nameController.text.isEmpty) {
            _nameController.text =
            '${profileController.userInfoModel?.fName ?? ''} ${profileController.userInfoModel?.lName ?? ''}';
          }

          if (profileController.userInfoModel != null &&
              _emailController.text.isEmpty) {
            _emailController.text =
                profileController.userInfoModel?.email ?? '';
          }

          return isLoggedIn
              ? profileController.userInfoModel != null
              ? ResponsiveHelper.isDesktop(context)
              ? webView(profileController, isLoggedIn)
              : ProfileBgWidget(
            backButton: true,
            circularImage: Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  InkWell(
                    onTap: () => _pickImage(profileController),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 3,
                          color: Colors.white,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: profileController.pickedFile != null
                            ? GetPlatform.isWeb
                                ? Image.network(
                                    profileController.pickedFile!.path,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(profileController.pickedFile!.path),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                            : FadeInImage.assetNetwork(
                                placeholder: Images.placeholder,
                                image: '${profileController.userInfoModel!.imageFullUrl}',
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                                imageErrorBuilder: (c, o, s) => Image.asset(
                                  Images.placeholder,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () => _pickImage(profileController),
                      child: Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 2,
                            color: Colors.white,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            mainWidget: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(
                      Dimensions.paddingSizeSmall,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 1170,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 25,
                            ),
                            Container(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                                border: Border.all(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          CupertinoIcons.person_crop_circle,
                                          color: Theme.of(context).primaryColor,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: Dimensions.paddingSizeSmall),
                                      Text(
                                        'personal_info'.tr,
                                        style: robotoBold.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          color: Theme.of(context).textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeSmall),
                                  const Divider(),
                                  const SizedBox(height: Dimensions.paddingSizeSmall),
                                  CustomTextField(
                                    titleText: 'enter_name'.tr,
                                    controller: _nameController,
                                    capitalization: TextCapitalization.words,
                                    inputType: TextInputType.name,
                                    focusNode: _nameFocus,
                                    nextFocus: _emailFocus,
                                    prefixIcon: CupertinoIcons.person_fill,
                                    labelText: 'name'.tr,
                                    validator: (value) => ValidateCheck.validateEmptyText(
                                      value,
                                      "please_enter_first_name".tr,
                                    ),
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeLarge),
                                  CustomTextField(
                                    titleText: 'enter_email'.tr,
                                    controller: _emailController,
                                    focusNode: _emailFocus,
                                    inputType: TextInputType.emailAddress,
                                    prefixIcon: CupertinoIcons.mail_solid,
                                    labelText: 'email'.tr,
                                    validator: ValidateCheck.validateEmail,
                                    suffixImage: profileController.userInfoModel!.isEmailVerified! &&
                                            profileController.userInfoModel!.email == _emailController.text
                                        ? Images.verifiedIcon
                                        : Get.find<SplashController>().configModel!.centralizeLoginSetup!.emailVerificationStatus!
                                            ? Images.unverifiedIcon
                                            : null,
                                    suffixOnPressed: () async {
                                      if (!profileController.userInfoModel!.isEmailVerified! ||
                                          profileController.userInfoModel!.email != _emailController.text) {
                                        Get.dialog(const CustomLoaderWidget());
                                        await _updateProfile(
                                          profileController: profileController,
                                          fromButton: false,
                                          fromPhone: false,
                                        );
                                      }
                                    },
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeLarge),
                                  Stack(
                                    children: [
                                      CustomTextField(
                                        titleText: 'write_phone_number'.tr,
                                        controller: _phoneController,
                                        focusNode: _phoneFocus,
                                        inputType: TextInputType.phone,
                                        prefixIcon: CupertinoIcons.phone_fill,
                                        isEnabled: !profileController.userInfoModel!.isPhoneVerified! ||
                                            profileController.userInfoModel!.phone == null,
                                        fromUpdateProfile: true,
                                        labelText: 'phone'.tr,
                                        required: true,
                                        isPhone: true,
                                        onCountryChanged: (CountryCode countryCode) =>
                                            _countryDialCode = countryCode.dialCode,
                                        countryDialCode: _countryDialCode ??
                                            Get.find<LocalizationController>().locale.countryCode,
                                        suffixImage: profileController.userInfoModel!.isPhoneVerified!
                                            ? Images.verifiedIcon
                                            : null,
                                      ),
                                      Positioned(
                                        right: 15,
                                        top: 15,
                                        child: !profileController.userInfoModel!.isPhoneVerified! &&
                                                Get.find<SplashController>()
                                                    .configModel!
                                                    .centralizeLoginSetup!
                                                    .phoneVerificationStatus!
                                            ? InkWell(
                                                onTap: () async {
                                                  if (!profileController.userInfoModel!.isPhoneVerified! &&
                                                      Get.find<SplashController>()
                                                          .configModel!
                                                          .centralizeLoginSetup!
                                                          .phoneVerificationStatus!) {
                                                    Get.dialog(const CustomLoaderWidget());
                                                    await _updateProfile(
                                                      profileController: profileController,
                                                      fromButton: false,
                                                      fromPhone: true,
                                                    );
                                                  }
                                                },
                                                child: Image.asset(
                                                  Images.unverifiedIcon,
                                                  height: 20,
                                                  width: 20,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : const SizedBox(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: CustomButton(
                    isLoading: profileController.isLoading,
                    onPressed: () => _updateProfile(
                      profileController: profileController,
                      fromButton: true,
                      fromPhone: false,
                    ),
                    margin: const EdgeInsets.all(
                      Dimensions.paddingSizeDefault,
                    ),
                    radius: Dimensions.radiusDefault,
                    buttonText: 'update'.tr,
                  ),
                ),
              ],
            ),
          )
              : const Center(child: CircularProgressIndicator())
              : NotLoggedInScreen(
            callBack: (value) {
              _initCall();
              setState(() {});
            },
          );
        },
      ),
    );
  }

  Widget webView(ProfileController profileController, bool isLoggedIn) {
    return SingleChildScrollView(
      controller: scrollController,
      child: FooterView(
        child: Stack(
          children: [
            SizedBox(height: 520, width: context.width),
            Center(
              child: Container(
                height: 300,
                width: Dimensions.webMaxWidth,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  image: const DecorationImage(
                    image: AssetImage(Images.profileBg),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: Dimensions.paddingSizeDefault,
                    ),
                    child: Text(
                      'profile'.tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Theme.of(context).cardColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      alignment: Alignment.topCenter,
                      height: 400,
                      width: Dimensions.webMaxWidth,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(Dimensions.radiusExtraLarge),
                          bottom: Radius.circular(Dimensions.radiusDefault),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: -50,
                      left: 0,
                      right: 0,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            InkWell(
                              onTap: () => _pickImage(profileController),
                              borderRadius: BorderRadius.circular(50),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 3,
                                    color: Colors.white,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: profileController.pickedFile != null
                                      ? GetPlatform.isWeb
                                          ? Image.network(
                                              profileController.pickedFile!.path,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.file(
                                              File(profileController.pickedFile!.path),
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            )
                                      : CustomImage(
                                          image: '${profileController.userInfoModel!.imageFullUrl}',
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () => _pickImage(profileController),
                                child: Container(
                                  height: 32,
                                  width: 32,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 2,
                                      color: Colors.white,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 80,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 90),
                        child: Center(
                          child: SizedBox(
                            width: 500,
                            child: Column(
                              children: [
                                CustomTextField(
                                  titleText: 'enter_name'.tr,
                                  controller: _nameController,
                                  capitalization: TextCapitalization.words,
                                  inputType: TextInputType.name,
                                  focusNode: _nameFocus,
                                  nextFocus: _emailFocus,
                                  prefixIcon:
                                  CupertinoIcons.person_fill,
                                  labelText: 'name'.tr,
                                  required: true,
                                  validator: (value) =>
                                      ValidateCheck.validateEmptyText(
                                        value,
                                        "first_name_field_is_required".tr,
                                      ),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeLarge,
                                ),
                                CustomTextField(
                                  titleText: 'enter_email'.tr,
                                  controller: _emailController,
                                  focusNode: _emailFocus,
                                  inputType: TextInputType.emailAddress,
                                  prefixIcon: CupertinoIcons.mail_solid,
                                  labelText: 'email'.tr,
                                  showLabelText: false,
                                  required: false,
                                  validator: ValidateCheck.validateEmail,
                                  onChanged: (value) {
                                    profileController.update();
                                  },
                                  suffixImage:
                                  profileController
                                      .userInfoModel!
                                      .isEmailVerified! &&
                                      profileController
                                          .userInfoModel!
                                          .email ==
                                          _emailController.text
                                      ? Images.verifiedIcon
                                      : Get.find<SplashController>()
                                      .configModel!
                                      .centralizeLoginSetup!
                                      .emailVerificationStatus!
                                      ? Images.unverifiedIcon
                                      : null,
                                  suffixOnPressed: () {
                                    if (!profileController
                                        .userInfoModel!
                                        .isEmailVerified! ||
                                        profileController
                                            .userInfoModel!
                                            .email !=
                                            _emailController.text) {
                                      _updateProfile(
                                        profileController: profileController,
                                        fromButton: false,
                                        fromPhone: false,
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeLarge,
                                ),
                                Stack(
                                  children: [
                                    CustomTextField(
                                      titleText: 'phone'.tr,
                                      controller: _phoneController,
                                      focusNode: _phoneFocus,
                                      inputType: TextInputType.phone,
                                      isEnabled:
                                      !profileController
                                          .userInfoModel!
                                          .isPhoneVerified! ||
                                          profileController
                                              .userInfoModel!
                                              .phone ==
                                              null,
                                      fromUpdateProfile: true,
                                      labelText: 'phone'.tr,
                                      required: true,
                                      isPhone: true,
                                      prefixIcon: CupertinoIcons.phone_fill,
                                      onCountryChanged:
                                          (CountryCode countryCode) =>
                                      _countryDialCode =
                                          countryCode.dialCode,
                                      countryDialCode:
                                      _countryDialCode ??
                                          Get.find<LocalizationController>()
                                              .locale
                                              .countryCode,
                                      suffixImage:
                                      profileController
                                          .userInfoModel!
                                          .isPhoneVerified!
                                          ? Images.verifiedIcon
                                          : null,
                                    ),
                                    Positioned(
                                      right: 10,
                                      top: 10,
                                      child:
                                      !profileController
                                          .userInfoModel!
                                          .isPhoneVerified! &&
                                          Get.find<SplashController>()
                                              .configModel!
                                              .centralizeLoginSetup!
                                              .phoneVerificationStatus!
                                          ? InkWell(
                                        onTap: () {
                                          if (!profileController
                                              .userInfoModel!
                                              .isPhoneVerified! &&
                                              Get.find<SplashController>()
                                                  .configModel!
                                                  .centralizeLoginSetup!
                                                  .phoneVerificationStatus!) {
                                            _updateProfile(
                                              profileController:
                                              profileController,
                                              fromButton: false,
                                              fromPhone: true,
                                            );
                                          }
                                        },
                                        child: Image.asset(
                                          Images.unverifiedIcon,
                                          height: 25,
                                          width: 25,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                          : const SizedBox(),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeExtraOverLarge,
                                ),
                                CustomButton(
                                  width: 500,
                                  buttonText: 'update_profile'.tr,
                                  fontSize: Dimensions.fontSizeDefault,
                                  isBold: false,
                                  radius: Dimensions.radiusSmall,
                                  isLoading: profileController.isLoading,
                                  onPressed: () => _updateProfile(
                                    profileController: profileController,
                                    fromButton: true,
                                    fromPhone: false,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
    );
  }

  Future<void> _updateProfile({
    required ProfileController profileController,
    required bool fromButton,
    required bool fromPhone,
  }) async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String phoneNumber = _phoneController.text.trim();
    String numberWithCountryCode = _countryDialCode! + phoneNumber;
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(
      numberWithCountryCode,
    );
    numberWithCountryCode = phoneValid.phone;

    // if (name.isEmpty) {
    //   showCustomSnackBar('enter_your_name'.tr);
    // } else
    if (!phoneValid.isValid) {
      showCustomSnackBar('invalid_phone_number'.tr);
    }
    // else if (email.isEmpty) {
    //   showCustomSnackBar('enter_email_address'.tr);
    // } else if (!GetUtils.isEmail(email)) {
    //   showCustomSnackBar('enter_a_valid_email_address'.tr);
    // }
    else if (phoneNumber.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    } else if (phoneNumber.length < 6) {
      showCustomSnackBar('enter_a_valid_phone_number'.tr);
    } else {
      UpdateUserModel updatedUser = UpdateUserModel(
        name: name,
        email: email,
        phone: numberWithCountryCode,
        buttonType: fromButton
            ? ''
            : fromPhone
            ? 'phone'
            : 'email',
      );
      await profileController.updateUserInfo(
        updatedUser,
        Get.find<AuthController>().getUserToken(),
        fromButton: fromButton,
      );
    }
  }



  void _pickImage(ProfileController profileController) {
    if (ResponsiveHelper.isDesktop(context)) {
      profileController.pickImage(ImageSource.gallery);
    } else {
      Get.bottomSheet(
        Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(Dimensions.radiusExtraLarge),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _imagePickerOption(
                    icon: Icons.photo_library,
                    label: 'gallery'.tr,
                    onTap: () {
                      Get.back();
                      profileController.pickImage(ImageSource.gallery);
                    },
                  ),
                  _imagePickerOption(
                    icon: Icons.camera_alt,
                    label: 'camera'.tr,
                    onTap: () {
                      Get.back();
                      profileController.pickImage(ImageSource.camera);
                    },
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
            ],
          ),
        ),
      );
    }
  }

  Widget _imagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(
            label,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
          ),
        ],
      ),);
  }
}
