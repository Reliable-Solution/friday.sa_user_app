import 'dart:async';
import 'package:get/get.dart';
import 'package:friday_sa/features/home/domain/models/cashback_model.dart';
import 'package:friday_sa/features/home/domain/services/home_service_interface.dart';

class HomeController extends GetxController implements GetxService {
  HomeController({required this.homeServiceInterface});
  final HomeServiceInterface homeServiceInterface;

  List<CashBackModel>? _cashBackOfferList;
  List<CashBackModel>? get cashBackOfferList => _cashBackOfferList;

  CashBackModel? _cashBackData;
  CashBackModel? get cashBackData => _cashBackData;

  bool _showFavButton = true;
  bool get showFavButton => _showFavButton;

  // bool _canShoeReferrerBottomSheet = false;
  // bool get canShoeReferrerBottomSheet => _canShoeReferrerBottomSheet;

  // void toggleReferrerBottomSheet({bool? status}) {
  //   if(Get.find<ProfileController>().userInfoModel!.isValidForDiscount! && status == null) {
  //     _canShoeReferrerBottomSheet = true;
  //   } else {
  //     _canShoeReferrerBottomSheet = status ?? false;
  //   }
  // }

  Future<void> getCashBackOfferList() async {
    _cashBackOfferList = null;
    _cashBackOfferList = await homeServiceInterface.getCashBackOfferList();
    update();
  }

  void forcefullyNullCashBackOffers() {
    _cashBackOfferList = null;
    update();
  }

  /*  Future<num> getCashBackAmount(num amount) async {
    _cashBackAmount = await homeServiceInterface.getCashBackAmount(amount);
    return _cashBackAmount;
  }*/

  Future<void> getCashBackData(num amount) async {
    CashBackModel? cashBackModel = await homeServiceInterface.getCashBackData(
      amount,
    );
    if (cashBackModel != null) {
      _cashBackData = cashBackModel;
    }
    update();
  }

  void changeFavVisibility() {
    _showFavButton = !_showFavButton;
    update();
  }

  Future<bool> saveRegistrationSuccessfulSharedPref(bool status) async {
    return homeServiceInterface.saveRegistrationSuccessful(status);
  }

  Future<bool> saveIsStoreRegistrationSharedPref(bool status) async {
    return homeServiceInterface.saveIsRestaurantRegistration(status);
  }

  bool getRegistrationSuccessfulSharedPref() {
    return homeServiceInterface.getRegistrationSuccessful();
  }

  bool getIsStoreRegistrationSharedPref() {
    return homeServiceInterface.getIsRestaurantRegistration();
  }
}
