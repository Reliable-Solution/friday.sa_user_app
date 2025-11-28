import 'package:friday_sa/common/enums/data_source_enum.dart';
import 'package:friday_sa/common/models/module_model.dart';
import 'package:friday_sa/features/language/domain/models/country_model.dart';
import 'package:friday_sa/interfaces/repository_interface.dart';

abstract class SplashRepositoryInterface extends RepositoryInterface {
  Future<dynamic> getConfigData({required DataSourceEnum source});
  Future<dynamic> getLandingPageData({required DataSourceEnum source});
  Future<ModuleModel?> initSharedData();
  void disableIntro();
  bool? showIntro();
  Future<void> setStoreCategory(int storeCategoryID);
  Future<dynamic> getModules({
    Map<String, String>? headers,
    required DataSourceEnum source,
  });
  Future<void> setModule(ModuleModel? module);
  Future<ModuleModel?> setCacheModule(ModuleModel? module);
  ModuleModel? getCacheModule();
  ModuleModel? getModule();
  Future<dynamic> subscribeEmail(String email);
  bool getSavedCookiesData();
  Future<void> saveCookiesData(bool data);
  void cookiesStatusChange(String? data);
  bool getAcceptCookiesStatus(String data);
  bool getSuggestedLocationStatus();
  Future<void> saveSuggestedLocationStatus(bool data);
  bool getReferBottomSheetStatus();
  Future<void> saveReferBottomSheetStatus(bool data);
  Future<CountryResModel?> getCountryList();
}
