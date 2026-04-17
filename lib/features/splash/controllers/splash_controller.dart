import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:friday_sa/common/enums/data_source_enum.dart';
import 'package:friday_sa/common/models/response_model.dart';
import 'package:friday_sa/features/auth/controllers/auth_controller.dart';
import 'package:friday_sa/features/banner/controllers/banner_controller.dart';
import 'package:friday_sa/features/category/controllers/category_controller.dart';
import 'package:friday_sa/features/flash_sale/controllers/flash_sale_controller.dart';
import 'package:friday_sa/features/home/controllers/home_controller.dart';
import 'package:friday_sa/features/item/controllers/campaign_controller.dart';
import 'package:friday_sa/features/cart/controllers/cart_controller.dart';
import 'package:friday_sa/features/item/controllers/item_controller.dart';
import 'package:friday_sa/features/notification/domain/models/notification_body_model.dart';
import 'package:friday_sa/features/profile/controllers/profile_controller.dart';

import 'package:friday_sa/features/favourite/controllers/favourite_controller.dart';
import 'package:friday_sa/api/api_client.dart';
import 'package:friday_sa/features/splash/domain/models/landing_model.dart';
import 'package:friday_sa/common/models/config_model.dart';
import 'package:friday_sa/common/models/module_model.dart';
import 'package:get/get.dart';
import 'package:friday_sa/features/address/controllers/address_controller.dart';
import 'package:friday_sa/features/rental_module/rental_cart_screen/controllers/taxi_cart_controller.dart';
import 'package:friday_sa/features/rental_module/rental_favourite/controllers/taxi_favourite_controller.dart';
import 'package:friday_sa/helper/auth_helper.dart';
import 'package:friday_sa/common/widgets/custom_snackbar.dart';
import 'package:friday_sa/features/home/screens/home_screen.dart';
import 'package:friday_sa/features/splash/domain/services/splash_service_interface.dart';
import 'package:friday_sa/helper/route_helper.dart';
import 'package:friday_sa/helper/splash_route_helper.dart';
import 'package:friday_sa/util/app_constants.dart';
import 'package:universal_html/html.dart' as html;

import '../../../helper/splash_route_helper.dart' as SplashRouteHelper;
import '../../language/domain/models/country_model.dart';
import '../../store/controllers/store_controller.dart';

class SplashController extends GetxController implements GetxService {
  SplashController({required this.splashServiceInterface});
  final SplashServiceInterface splashServiceInterface;

  ConfigModel? _configModel;
  ConfigModel? get configModel => _configModel;

  bool _firstTimeConnectionCheck = true;
  bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;

  bool _hasConnection = true;
  bool get hasConnection => _hasConnection;

  ModuleModel? _module;
  ModuleModel? get module => _module;

  ModuleModel? _cacheModule;
  ModuleModel? get cacheModule => _cacheModule;

  List<ModuleModel>? _moduleList;
  List<ModuleModel>? get moduleList => _moduleList;

  int _moduleIndex = 0;
  int get moduleIndex => _moduleIndex;

  Map<String, dynamic>? _data = {};

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _selectedModuleIndex = 0;
  int get selectedModuleIndex => _selectedModuleIndex;

  LandingModel? _landingModel;
  LandingModel? get landingModel => _landingModel;

  bool _savedCookiesData = false;
  bool get savedCookiesData => _savedCookiesData;

  bool _webSuggestedLocation = false;
  bool get webSuggestedLocation => _webSuggestedLocation;

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  bool _showReferBottomSheet = false;
  bool get showReferBottomSheet => _showReferBottomSheet;

  DateTime get currentTime => DateTime.now();

  void selectModuleIndex(int index) {
    _selectedModuleIndex = index;
    update();
  }

  void setCountry(int index) {
    _selectedCountryIndex = index;
    update();
  }

  void changeCountry({String? baseUrl}) {
    Get.find<SharedPreferences>().setInt('country', _selectedCountryIndex);
    Get.find<SharedPreferences>().setString(
      'baseUrl',
      baseUrl ??
          _countryModel?[_selectedCountryIndex].url ??
          AppConstants.baseUrl,
    );
    AppConstants.baseUrl =
        baseUrl ??
        _countryModel?[_selectedCountryIndex].url ??
        AppConstants.baseUrl;
    Get.lazyPut(
      () => ApiClient(
        appBaseUrl: AppConstants.baseUrl,
        sharedPreferences: Get.find(),
      ),
    );
    Get.find<SplashController>().getConfigData(
      source: DataSourceEnum.client,
      fromCountry: true,
    );

    update();
  }

  Future<void> getConfigData({
    NotificationBodyModel? notificationBody,
    bool loadModuleData = false,
    bool loadLandingData = false,
    DataSourceEnum source = DataSourceEnum.local,
    bool fromMainFunction = false,
    bool fromDemoReset = false,
    bool fromCountry = false,
  }) async {
    log("=======>>>> here get zone api call here 4 $source");

    _hasConnection = true;
    _moduleIndex = 0;
    Response response;
    if (source == DataSourceEnum.local && !fromDemoReset) {
      response = await splashServiceInterface.getConfigData(
        source: DataSourceEnum.local,
      );
      log("=======>>>> here get zone api call ${response.body}");
      _handleConfigResponse(
        response,
        loadModuleData,
        loadLandingData,
        fromMainFunction,
        fromDemoReset,
        fromCountry,
        notificationBody,
      );
      getConfigData(
        loadModuleData: loadModuleData,
        loadLandingData: loadLandingData,
        source: DataSourceEnum.client,
      );
    } else {
      response = await splashServiceInterface.getConfigData(
        source: DataSourceEnum.client,
      );
      _handleConfigResponse(
        response,
        loadModuleData,
        loadLandingData,
        fromMainFunction,
        fromDemoReset,
        fromCountry,
        notificationBody,
      );
    }
  }

  Future<void> _handleConfigResponse(
    Response response,
    bool loadModuleData,
    bool loadLandingData,
    bool fromMainFunction,
    bool fromDemoReset,
    bool fromCountry,
    NotificationBodyModel? notificationBody,
  ) async {
    if (response.statusCode == 200) {
      _data = response.body;
      _configModel = ConfigModel.fromJson(response.body);
      if (!fromCountry) {
        if (_configModel!.module != null) {
          setModule(_configModel!.module);
        } else if (GetPlatform.isWeb || (loadModuleData && _module != null)) {
          setModule(
            GetPlatform.isWeb ? splashServiceInterface.getModule() : _module,
          );
        }
        if (loadLandingData) {
          await getLandingPageData();
        }
        if (fromMainFunction) {
          _mainConfigRouting();
        } else if (fromDemoReset) {
          Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: true));
        } else {
          route(body: notificationBody);
        }
      }
      _onRemoveLoader();
    } else {
      if (response.statusText == ApiClient.noInternetMessage) {
        _hasConnection = false;
      }
    }
    update();
  }

  _mainConfigRouting() async {
    if (Get.find<AuthController>().isLoggedIn()) {
      Get.find<AuthController>().updateToken();
      if (Get.find<SplashController>().module != null) {
        await Get.find<FavouriteController>().getFavouriteList();
      }
    }
  }

  void _onRemoveLoader() {
    final preloader = html.document.querySelector('.preloader');
    if (preloader != null) {
      preloader.remove();
    }
  }

  Future<void> getLandingPageData({
    DataSourceEnum source = DataSourceEnum.local,
  }) async {
    LandingModel? landingModel;
    if (source == DataSourceEnum.local) {
      landingModel = await splashServiceInterface.getLandingPageData(
        source: DataSourceEnum.local,
      );
      _prepareLandingModel(landingModel);
      getLandingPageData(source: DataSourceEnum.client);
    } else {
      landingModel = await splashServiceInterface.getLandingPageData(
        source: DataSourceEnum.client,
      );
      _prepareLandingModel(landingModel);
    }
  }

  _prepareLandingModel(LandingModel? landingModel) {
    if (landingModel != null) {
      _landingModel = landingModel;
      hoverStates = List<bool>.generate(
        _landingModel!.availableZoneList!.length,
        (index) => false,
      );
    }
    update();
  }

  Future<void> initSharedData() async {
    if (!GetPlatform.isWeb) {
      _module = null;
      splashServiceInterface.initSharedData();
    } else {
      _module = await splashServiceInterface.initSharedData();
    }
    _cacheModule = splashServiceInterface.getCacheModule();
    log("_cacheModule ${_cacheModule?.toJson()}");
    setModule(_module, notify: false);
  }

  void setCacheConfigModule(ModuleModel? cacheModule) {
    _configModel!.moduleConfig!.module = Module.fromJson(
      _data!['module_config'][cacheModule!.moduleType],
    );
  }

  bool? showIntro() {
    return splashServiceInterface.showIntro();
  }

  void disableIntro() {
    splashServiceInterface.disableIntro();
  }

  void setFirstTimeConnectionCheck(bool isChecked) {
    _firstTimeConnectionCheck = isChecked;
  }

  Future<void> setModule(ModuleModel? module, {bool notify = true}) async {
    _module = module;
    splashServiceInterface.setModule(module);
    if (module != null) {
      if (_configModel != null) {
        _configModel!.moduleConfig!.module = Module.fromJson(
          _data!['module_config'][module.moduleType],
        );
      }
      _cacheModule = await splashServiceInterface.setCacheModule(module);
      if ((AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) &&
          cacheModule != null) {
        Get.find<CartController>().getCartDataOnline();
      }
    }

    if (_cacheModule != null &&
        _cacheModule!.moduleType.toString() == AppConstants.taxi) {
      Get.find<TaxiCartController>().getCarCartList();
    }

    if (AuthHelper.isLoggedIn()) {
      if (Get.find<SplashController>().module != null) {
        Get.find<HomeController>().getCashBackOfferList();
        if (module?.moduleType.toString() == AppConstants.taxi) {
          Get.find<TaxiFavouriteController>().getFavouriteTaxiList();
        } else {
          Get.find<FavouriteController>().getFavouriteList();
        }
      } else if (_cacheModule != null &&
          _cacheModule!.moduleType.toString() == AppConstants.taxi) {
        Get.find<TaxiCartController>().getCarCartList();
      }
    }
    if (notify) {
      update();
    }
  }

  Module getModuleConfig(String? moduleType) {
    Module module = Module.fromJson(_data!['module_config'][moduleType]);
    moduleType == 'food'
        ? module.newVariation = true
        : module.newVariation = false;
    return module;
  }

  Future<void> getModules({
    Map<String, String>? headers,
    DataSourceEnum dataSource = DataSourceEnum.local,
  }) async {
    _moduleIndex = 0;
    List<ModuleModel>? moduleList;
    if (dataSource == DataSourceEnum.local) {
      moduleList = await splashServiceInterface.getModules(
        headers: headers,
        source: DataSourceEnum.local,
      );
      _prepareModuleList(moduleList);
      getModules(headers: headers, dataSource: DataSourceEnum.client);
    } else {
      moduleList = await splashServiceInterface.getModules(
        headers: headers,
        source: DataSourceEnum.client,
      );
      _prepareModuleList(moduleList);
    }
  }

  _prepareModuleList(List<ModuleModel>? moduleList) {
    if (moduleList != null) {
      List<ModuleModel> modules = [];
      for (var module in moduleList) {
        if (module.moduleType != AppConstants.taxi && GetPlatform.isWeb) {
          modules.add(module);
        } else if (!GetPlatform.isWeb) {
          modules.add(module);
        }
      }
      _moduleList = modules;
    }
    update();
  }

  Future<void> showInterestPage() async {
    if (!Get.find<ProfileController>().userInfoModel!.selectedModuleForInterest!
            .contains(Get.find<SplashController>().module!.id) &&
        (Get.find<SplashController>().module!.moduleType == 'food' ||
            Get.find<SplashController>().module!.moduleType == 'grocery' ||
            Get.find<SplashController>().module!.moduleType == 'ecommerce')) {
      await Get.toNamed(RouteHelper.getInterestRoute());
    }
  }

  Future<void> switchModule(int index, bool fromPhone) async {
    if (_module == null || _module!.id != _moduleList![index].id) {
      final hadPreviousModule = _module != null;
      await setModule(_moduleList![index]);

      if (_module!.moduleType.toString() != AppConstants.taxi) {
        Get.find<CartController>().getCartDataOnline();
        if (hadPreviousModule) {
          Get.find<ItemController>().clearItemLists();
          Get.find<BannerController>().clearBanner();
          Get.find<CategoryController>().clearCategoryList();
          Get.find<CampaignController>().itemAndBasicCampaignNull();
          Get.find<FlashSaleController>().setEmptyFlashSale(fromModule: true);
        }

        if (AuthHelper.isLoggedIn()) {
          Get.find<HomeController>().getCashBackOfferList();
          // await showInterestPage();
        }
        HomeScreen.loadData(true, fromModule: true);
      } else {
        if (AuthHelper.isLoggedIn()) {
          Get.find<HomeController>().getCashBackOfferList();
        }
        Get.find<TaxiCartController>().getCarCartList();
      }
    }
  }

  int getCacheModule() {
    return splashServiceInterface.getCacheModule()?.id ?? 0;
  }

  void setModuleIndex(int index) {
    _moduleIndex = index;
    update();
  }

  void removeModule() {
    setModule(null);
    Get.find<BannerController>().getFeaturedBanner();
    getModules();
    if (AuthHelper.isLoggedIn()) {
      Get.find<AddressController>().getAddressList();
    }
    Get.find<StoreController>().getFeaturedStoreList();
  }

  Future<void> removeCacheModule() async {
    _cacheModule = await splashServiceInterface.setCacheModule(null);
  }

  Future<bool> subscribeMail(String email) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await splashServiceInterface.subscribeEmail(
      email,
    );
    if (responseModel.isSuccess) {
      showCustomSnackBar(responseModel.message, isError: false);
    } else {
      showCustomSnackBar(responseModel.message, isError: true);
    }
    _isLoading = false;
    update();
    return responseModel.isSuccess;
  }

  void saveCookiesData(bool data) {
    splashServiceInterface.saveCookiesData(data);
    _savedCookiesData = true;
    update();
  }

  getCookiesData() {
    _savedCookiesData = splashServiceInterface.getSavedCookiesData();
    update();
  }

  void cookiesStatusChange(String? data) {
    splashServiceInterface.cookiesStatusChange(data);
  }

  bool getAcceptCookiesStatus(String data) =>
      splashServiceInterface.getAcceptCookiesStatus(data);

  void saveWebSuggestedLocationStatus(bool data) {
    splashServiceInterface.saveSuggestedLocationStatus(data);
    _webSuggestedLocation = true;
    update();
  }

  void getWebSuggestedLocationStatus() {
    _webSuggestedLocation = splashServiceInterface.getSuggestedLocationStatus();
  }

  void setRefreshing(bool status) {
    _isRefreshing = status;
    update();
  }

  void saveReferBottomSheetStatus(bool data) {
    splashServiceInterface.saveReferBottomSheetStatus(data);
    _showReferBottomSheet = data;
    update();
  }

  void getReferBottomSheetStatus() {
    _showReferBottomSheet = splashServiceInterface.getReferBottomSheetStatus();
  }

  var hoverStates = <bool>[];

  void setHover(int index, bool state) {
    hoverStates[index] = state;
    update();
  }

  List<CountryModel>? _countryModel = [];
  List<CountryModel>? get countryModel => _countryModel;

  int _selectedCountryIndex = -1;
  int get selectedCountryIndex => _selectedCountryIndex;
  bool isCountryLoad = false;

  Future<void> getCountryData() async {
    isCountryLoad = true;
    update();
    await Future.delayed(const Duration(milliseconds: 1000));
    try {
      final res = await splashServiceInterface.getCountryList();
      if (res?.success ?? false) {
        _countryModel = [...res?.data ?? []];
        update();
      }
    } catch (e) {
      debugPrint('Error fetching country data: $e');
    } finally {
      isCountryLoad = false;
      update();
    }
  }

  void route({NotificationBodyModel? body}) {
    SplashRouteHelper.route(body: body);
  }
}
