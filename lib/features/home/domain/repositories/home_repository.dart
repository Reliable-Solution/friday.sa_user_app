import 'package:get/get_connect/http/src/response/response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:friday_sa/api/api_client.dart';
import 'package:friday_sa/features/home/domain/models/cashback_model.dart';
import 'package:friday_sa/util/app_constants.dart';
import 'home_repository_interface.dart';

class HomeRepository implements HomeRepositoryInterface {
  HomeRepository({required this.sharedPreferences, required this.apiClient});
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) async {
    List<CashBackModel>? cashBackModelList;
    Response response = await apiClient.getData(
      AppConstants.cashBackOfferListUri,
    );
    if (response.statusCode == 200) {
      cashBackModelList = [];
      response.body.forEach((data) {
        cashBackModelList!.add(CashBackModel.fromJson(data));
      });
    }
    return cashBackModelList;
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

  @override
  Future<CashBackModel?> getCashBackData(num amount) async {
    //num cashbackAmount = 0;
    CashBackModel? cashBackModel;
    Response response = await apiClient.getData(
      '${AppConstants.getCashBackAmountUri}?amount=$amount',
    );
    if (response.statusCode == 200) {
      //cashbackAmount = response.body['cashback_amount'] != null ? num.parse(response.body['cashback_amount'].toString()) : 0;
      cashBackModel = CashBackModel.fromJson(response.body);
    }
    return cashBackModel;
  }

  @override
  Future<bool> saveRegistrationSuccessful(bool status) async {
    return sharedPreferences.setBool(AppConstants.dmRegisterSuccess, status);
  }

  @override
  Future<bool> saveIsRestaurantRegistration(bool status) async {
    return sharedPreferences.setBool(AppConstants.isRestaurantRegister, status);
  }

  @override
  bool getRegistrationSuccessful() {
    return sharedPreferences.getBool(AppConstants.dmRegisterSuccess) ?? false;
  }

  @override
  bool getIsRestaurantRegistration() {
    return sharedPreferences.getBool(AppConstants.isRestaurantRegister) ??
        false;
  }
}
