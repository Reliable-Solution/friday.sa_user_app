import 'package:get/get.dart';
import 'package:friday_sa/common/enums/data_source_enum.dart';
import 'package:friday_sa/common/models/config_model.dart';
import 'package:friday_sa/common/models/response_model.dart';
import 'package:friday_sa/features/language/domain/models/country_model.dart';
import 'package:friday_sa/features/splash/domain/models/landing_model.dart';
import 'package:friday_sa/common/models/module_model.dart';
import 'package:friday_sa/features/splash/domain/repositories/splash_repository_interface.dart';
import 'package:friday_sa/features/splash/domain/services/splash_service_interface.dart';

class SplashService implements SplashServiceInterface {
  SplashService({required this.splashRepositoryInterface});
  final SplashRepositoryInterface splashRepositoryInterface;

  @override
  Future<Response> getConfigData({required DataSourceEnum source}) async {
    Response response = await splashRepositoryInterface.getConfigData(
      source: source,
    );
    return response;
  }

  @override
  Future<CountryResModel?> getCountryList() async {
    return splashRepositoryInterface.getCountryList();
  }

  @override
  ConfigModel? prepareConfigData(Response response) {
    ConfigModel? configModel;
    if (response.statusCode == 200) {
      configModel = ConfigModel.fromJson(response.body);
    }
    return configModel;
  }

  @override
  Future<LandingModel?> getLandingPageData({
    required DataSourceEnum source,
  }) async {
    return await splashRepositoryInterface.getLandingPageData(source: source);
  }

  @override
  Future<ModuleModel?> initSharedData() async {
    return splashRepositoryInterface.initSharedData();
  }

  @override
  void disableIntro() {
    splashRepositoryInterface.disableIntro();
  }

  @override
  bool? showIntro() {
    return splashRepositoryInterface.showIntro();
  }

  @override
  Future<void> setStoreCategory(int storeCategoryID) async {
    return splashRepositoryInterface.setStoreCategory(storeCategoryID);
  }

  @override
  Future<List<ModuleModel>?> getModules({
    Map<String, String>? headers,
    required DataSourceEnum source,
  }) async {
    return await splashRepositoryInterface.getModules(
      headers: headers,
      source: source,
    );
  }

  @override
  Future<void> setModule(ModuleModel? module) async {
    return splashRepositoryInterface.setModule(module);
  }

  @override
  Future<ModuleModel?> setCacheModule(ModuleModel? module) async {
    return splashRepositoryInterface.setCacheModule(module);
  }

  @override
  ModuleModel? getCacheModule() {
    return splashRepositoryInterface.getCacheModule();
  }

  @override
  ModuleModel? getModule() {
    return splashRepositoryInterface.getModule();
  }

  @override
  Future<ResponseModel> subscribeEmail(String email) async {
    return await splashRepositoryInterface.subscribeEmail(email);
  }

  @override
  bool getSavedCookiesData() {
    return splashRepositoryInterface.getSavedCookiesData();
  }

  @override
  Future<void> saveCookiesData(bool data) async {
    return splashRepositoryInterface.saveCookiesData(data);
  }

  @override
  void cookiesStatusChange(String? data) {
    splashRepositoryInterface.cookiesStatusChange(data);
  }

  @override
  bool getAcceptCookiesStatus(String data) {
    return splashRepositoryInterface.getAcceptCookiesStatus(data);
  }

  @override
  bool getSuggestedLocationStatus() {
    return splashRepositoryInterface.getSuggestedLocationStatus();
  }

  @override
  Future<void> saveSuggestedLocationStatus(bool data) async {
    return splashRepositoryInterface.saveSuggestedLocationStatus(data);
  }

  @override
  bool getReferBottomSheetStatus() {
    return splashRepositoryInterface.getReferBottomSheetStatus();
  }

  @override
  Future<void> saveReferBottomSheetStatus(bool data) async {
    return splashRepositoryInterface.saveReferBottomSheetStatus(data);
  }
}
