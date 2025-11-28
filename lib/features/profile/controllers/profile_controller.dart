import 'package:friday_sa/features/cart/controllers/cart_controller.dart';
import 'package:friday_sa/features/favourite/controllers/favourite_controller.dart';
import 'package:friday_sa/features/chat/domain/models/conversation_model.dart';
import 'package:friday_sa/common/models/response_model.dart';
import 'package:friday_sa/features/location/controllers/location_controller.dart';
import 'package:friday_sa/features/profile/domain/models/update_user_model.dart';
import 'package:friday_sa/features/profile/domain/models/userinfo_model.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:friday_sa/features/auth/controllers/auth_controller.dart';
import 'package:friday_sa/features/verification/screens/verification_screen.dart';
import 'package:friday_sa/helper/responsive_helper.dart';
import 'package:friday_sa/helper/route_helper.dart';
import 'package:friday_sa/common/widgets/custom_snackbar.dart';
import 'package:friday_sa/features/profile/domain/services/profile_service_interface.dart';

class ProfileController extends GetxController implements GetxService {
  ProfileController({required this.profileServiceInterface});
  final ProfileServiceInterface profileServiceInterface;

  UserInfoModel? _userInfoModel;
  UserInfoModel? get userInfoModel => _userInfoModel;

  XFile? _pickedFile;
  XFile? get pickedFile => _pickedFile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> getUserInfo() async {
    _pickedFile = null;
    UserInfoModel? userInfoModel = await profileServiceInterface.getUserInfo();
    if (userInfoModel != null) {
      _userInfoModel = userInfoModel;
    }
    update();
  }

  void setForceFullyUserEmpty() {
    _userInfoModel = null;
  }

  Future<ResponseModel> updateUserInfo(
    UpdateUserModel updateUserModel,
    String token, {
    bool fromVerification = false,
    bool fromButton = false,
  }) async {
    if (fromButton) {
      _isLoading = true;
      update();
    }
    ResponseModel responseModel = await profileServiceInterface.updateProfile(
      updateUserModel,
      _pickedFile,
      token,
    );
    if (!fromVerification) {
      _updateProfileResponseHandle(responseModel, updateUserModel, token);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<void> _updateProfileResponseHandle(
    ResponseModel responseModel,
    UpdateUserModel updateUserModel,
    String token,
  ) async {
    updateUserModel.verificationOn =
        responseModel.updateProfileResponseModel?.verificationOn;
    updateUserModel.verificationMedium =
        responseModel.updateProfileResponseModel?.verificationMedium;

    if (responseModel.isSuccess &&
        responseModel.updateProfileResponseModel != null &&
        responseModel.updateProfileResponseModel!.verificationOn != null &&
        responseModel.updateProfileResponseModel!.verificationOn! == 'phone') {
      if (responseModel.updateProfileResponseModel!.verificationMedium! ==
          'firebase') {
        Get.find<AuthController>().firebaseVerifyPhoneNumber(
          updateUserModel.phone!,
          token,
          '',
          fromSignUp: false,
          updateUserModel: updateUserModel,
        );
      } else {
        if (Get.isDialogOpen!) {
          Get.back();
        }
        if (ResponsiveHelper.isDesktop(Get.context)) {
          Get.dialog(
            VerificationScreen(
              number: updateUserModel.phone,
              email: null,
              token: '',
              fromSignUp: false,
              fromForgetPassword: false,
              loginType: '',
              password: '',
              userModel: updateUserModel,
            ),
          );
        } else {
          Get.toNamed(
            RouteHelper.getVerificationRoute(
              updateUserModel.phone,
              null,
              '',
              '',
              null,
              '',
              updateUserModel: updateUserModel,
            ),
          );
        }
      }
    } else if (responseModel.isSuccess &&
        responseModel.updateProfileResponseModel != null &&
        responseModel.updateProfileResponseModel!.verificationOn != null &&
        responseModel.updateProfileResponseModel!.verificationOn! == 'email') {
      if (Get.isDialogOpen!) {
        Get.back();
      }
      if (ResponsiveHelper.isDesktop(Get.context)) {
        Get.dialog(
          VerificationScreen(
            number: null,
            email: updateUserModel.email,
            token: '',
            fromSignUp: false,
            fromForgetPassword: false,
            loginType: '',
            password: '',
            userModel: updateUserModel,
          ),
        );
      } else {
        Get.toNamed(
          RouteHelper.getVerificationRoute(
            null,
            updateUserModel.email,
            '',
            '',
            null,
            '',
            updateUserModel: updateUserModel,
          ),
        );
      }
    } else if (responseModel.isSuccess &&
        responseModel.updateProfileResponseModel == null) {
      if (Get.isDialogOpen!) {
        Get.back();
      }
      await getUserInfo();
      if (!ResponsiveHelper.isDesktop(Get.context)) {
        Get.back();
        Get.back();
      }
      _pickedFile = null;
      showCustomSnackBar(responseModel.message, isError: false);
    } else if (!responseModel.isSuccess &&
        responseModel.updateProfileResponseModel != null) {
      if (Get.isDialogOpen!) {
        Get.back();
      }
      showCustomSnackBar(responseModel.updateProfileResponseModel!.message);
    } else {
      if (Get.isDialogOpen!) {
        Get.back();
      }
      showCustomSnackBar(responseModel.message);
    }
  }

  Future<ResponseModel> changePassword(UserInfoModel updatedUserModel) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await profileServiceInterface.changePassword(
      updatedUserModel,
    );
    _isLoading = false;
    update();
    return responseModel;
  }

  void updateUserWithNewData(User? user) {
    _userInfoModel!.userInfo = user;
  }

  Future<void> pickImage() async {
    _pickedFile = await profileServiceInterface.pickImageFromGallery();
    update();
  }

  void initData({bool isUpdate = false}) {
    _pickedFile = null;
    if (isUpdate) {
      update();
    }
  }

  Future<void> deleteUser() async {
    _isLoading = true;
    update();
    Response response = await profileServiceInterface.deleteUser();
    _isLoading = false;
    if (response.statusCode == 200) {
      await Get.find<AuthController>().clearSharedData(removeToken: false);
      await Get.find<AuthController>().clearUserNumberAndPassword();
      await Get.find<CartController>().clearCartList();
      if (Get.find<AuthController>().isActiveRememberMe) {
        Get.find<AuthController>().toggleRememberMe();
      }
      Get.find<FavouriteController>().removeFavourite();
      setForceFullyUserEmpty();
      showCustomSnackBar('your_account_remove_successfully'.tr, isError: false);
      _isLoading = false;
      Get.find<LocationController>().navigateToLocationScreen(
        'splash',
        offNamed: true,
      );
    } else {
      _isLoading = false;
      Get.back();
    }
    update();
  }

  void clearUserInfo() {
    _userInfoModel = null;
    update();
  }
}
