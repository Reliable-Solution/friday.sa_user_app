import 'dart:developer';

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
import 'package:friday_sa/features/store/controllers/store_controller.dart';
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

import '../../language/domain/models/country_model.dart';

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
      _moduleList = [];
      for (var module in moduleList) {
        // log('moduleList====>>>> ${moduleList.length} === ${module.toJson()}');
        if (module.moduleType != AppConstants.taxi && GetPlatform.isWeb) {
          _moduleList!.add(module);
        } else if (!GetPlatform.isWeb) {
          _moduleList!.add(module);
        }
      }
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
      await setModule(_moduleList![index]);

      if (_module!.moduleType.toString() != AppConstants.taxi) {
        Get.find<CartController>().getCartDataOnline();
        Get.find<ItemController>().clearItemLists();
        Get.find<BannerController>().clearBanner();
        Get.find<CategoryController>().clearCategoryList();
        Get.find<CampaignController>().itemAndBasicCampaignNull();
        Get.find<FlashSaleController>().setEmptyFlashSale(fromModule: true);

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
    Get.find<HomeController>().forcefullyNullCashBackOffers();
    if (AuthHelper.isLoggedIn()) {
      Get.find<AddressController>().getAddressList();
    }
    Get.find<StoreController>().getFeaturedStoreList();
    Get.find<CampaignController>().itemAndBasicCampaignNull();
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
    final res = await splashServiceInterface.getCountryList();
    if (res?.success ?? false) {
      _countryModel = [...res?.data ?? []];
      update();
    }
    isCountryLoad = false;
    update();
  }
}

// {business_name: Friday.sa, logo: 2025-05-24-6831b386a813d.png, logo_full_url: https://friday.sa/storage/business/2025-05-24-6831b386a813d.png, address: H.Q - Prince Faisal Ibn Mishaal Ibn Saud Rd, Alnaseem, Buraydah 52372, phone: 541502318, email: Contact@Topfixhub.com, country: SA, default_location: {lat: 26.354336501213215, lng: 43.93604815006256}, currency_symbol: ر.س.‏, currency_symbol_direction: right, app_minimum_version_android: 0, app_url_android: null, app_url_ios: null, app_minimum_version_ios: 0, app_minimum_version_android_store: 0, app_url_android_store: null, app_minimum_version_ios_store: 0, app_url_ios_store: null, app_minimum_version_android_deliveryman: 0, app_url_android_deliveryman: null, app_minimum_version_ios_deliveryman: 0, app_url_ios_deliveryman: null, customer_verification: false, prescription_order_status: true, schedule_order: true, order_delivery_verification: false, cash_on_delivery: true, digital_payment: true, digital_payment_info: {digital_payment: true, plugin_payment_gateways: false, default_payment_gateways: true}, per_km_shipping_charge: 0, minimum_shipping_charge: 4, demo: false, maintenance_mode: false, order_confirmation_model: store, show_dm_earning: true, canceled_by_deliveryman: false, canceled_by_store: true, timeformat: 12, language: [{key: en, value: English}, {key: ar, value: Arabic - العربية}], sys_language: [{key: en, value: English, direction: ltr, default: false}, {key: ar, value: Arabic - العربية, direction: rtl, default: true}], social_login: [{login_medium: google, status: false}, {login_medium: facebook, status: false}], apple_login: [{login_medium: apple, status: false, client_id: , client_id_app: , redirect_url_flutter: , redirect_url_react: }], toggle_veg_non_veg: true, toggle_dm_registration: false, toggle_store_registration: true, refund_active_status: false, schedule_order_slot_duration: 30, digit_after_decimal_point: 2, module_config: {module_type: [grocery, food, pharmacy, ecommerce, parcel, rental], grocery: {order_status: {accepted: false}, order_place_to_schedule_interval: true, add_on: false, stock: true, veg_non_veg: false, unit: true, order_attachment: false, always_open: false, all_zone_service: false, item_available_time: false, show_restaurant_text: false, is_parcel: false, organic: true, cutlery: false, common_condition: false, nutrition: true, allergy: true, basic: false, halal: true, brand: false, generic_name: false, description: In this type, You can set delivery slot start after x minutes from current time, No available time for items and has stock for items., is_rental: false}, food: {order_status: {accepted: true}, order_place_to_schedule_interval: false, add_on: true, stock: false, veg_non_veg: true, unit: false, order_attachment: false, always_open: false, all_zone_service: false, item_available_time: true, show_restaurant_text: true, is_parcel: false, organic: false, cutlery: true, common_condition: false, nutrition: true, allergy: true, basic: false, halal: true, brand: false, generic_name: false, description: In this type, you can set item available time, no stock management for items and has option to add add-on., is_rental: false}, pharmacy: {order_status: {accepted: false}, order_place_to_schedule_interval: false, add_on: false, stock: true, veg_non_veg: false, unit: true, order_attachment: true, always_open: false, all_zone_service: false, item_available_time: false, show_restaurant_text: false, is_parcel: false, organic: false, cutlery: false, common_condition: true, nutrition: false, allergy: false, basic: true, halal: false, brand: false, generic_name: true, description: In this type, Customer can upload prescription when place order, No available time for items and has stock for items., is_rental: false}, ecommerce: {order_status: {accepted: false}, order_place_to_schedule_interval: false, add_on: false, stock: true, veg_non_veg: false, unit: true, order_attachment: false, always_open: true, all_zone_service: true, item_available_time: false, show_restaurant_text: false, is_parcel: false, organic: false, cutlery: false, common_condition: false, nutrition: false, allergy: false, basic: false, halal: false, brand: true, generic_name: false, description: In this type, No opening and closing time for store, no available time for items and has stock for items., is_rental: false}, parcel: {order_status: {accepted: false}, order_place_to_schedule_interval: false, add_on: false, stock: false, veg_non_veg: false, unit: false, order_attachment: false, always_open: true, all_zone_service: false, item_available_time: false, show_restaurant_text: false, is_parcel: true, organic: false, cutlery: false, common_condition: false, nutrition: false, allergy: false, basic: false, halal: false, brand: false, generic_name: false, description: , is_rental: false}, rental: {order_status: {accepted: false}, order_place_to_schedule_interval: false, add_on: false, stock: false, veg_non_veg: false, unit: false, order_attachment: false, always_open: false, all_zone_service: false, item_available_time: false, show_restaurant_text: false, is_parcel: false, organic: false, cutlery: false, common_condition: false, nutrition: false, allergy: false, basic: false, halal: false, brand: false, generic _name: false, description: , is_rental: true}}, module: null, parcel_per_km_shipping_charge: 0, parcel_minimum_shipping_charge: 0, social_media: [], footer_text: TopFix Hub@ 2025, All Right Reserved. CR No. 1131057128-VAT No. 30215917480003, cookies_text: Demo cookie text, fav_icon: 2025-05-24-6831b386a9ad4.png, fav_icon_full_url: https://friday.sa/storage/business/2025-05-24-6831b386a9ad4.png, landing_page_links: {app_url_android_status: 1, app_url_android: https://play.google.com/store/, app_url_ios_status: 1, app_url_ios: https://www.apple.com/app-store/, web_app_url_status: 1, web_app_url: https://stackfood.friday.sa/}, dm_tips_status: 0, loyalty_point_exchange_rate: 1, loyalty_point_item_purchase_point: 1, loyalty_point_status: 0, customer_wallet_status: 0, ref_earning_status: 0, ref_earning_exchange_rate: 1, refund_policy: 1, cancelation_policy: 0, shipping_policy: 0, loyalty_point_minimum_point: 1500, tax_included: 0, home_delivery_status: 1, takeaway_status: 1, active_payment_method_list: [{gateway: elm, gateway_title: Elm Payment, gateway_image: null, gateway_image_full_url: null}, {gateway: clickpay, gateway_title: Clickpay, gateway_image: null, gateway_image_full_url: null}], additional_charge_status: 0, additional_charge_name: رسوم الخدمة, additional_charge: 1, partial_payment_status: 0, partial_payment_method: cod, dm_picture_upload_status: 1, add_fund_status: 0, offline_payment_status: 0, websocket_status: 0, websocket_url: , websocket_port: 6001, websocket_key: test, guest_checkout_status: 0, disbursement_type: manual, restaurant_disbursement_waiting_time: 0, dm_disbursement_waiting_time: 0, min_amount_to_pay_store: 1, min_amount_to_pay_dm: 1, new_customer_discount_status: 0, new_customer_discount_amount: 0, new_customer_discount_amount_type: percentage, new_customer_discount_amount_validity: 0, new_customer_discount_validity_type: day, store_review_reply: 1, admin_commission: 0, subscription_business_model: 1, commission_business_model: 1, subscription_deadline_warning_days: 7, subscription_deadline_warning_message: Your subscription ending soon. Please renew to continue access., subscription_free_trial_days: 30, subscription_free_trial_type: day, subscription_free_trial_status: 1, country_picker_status: 1, external_system: false, drivemond_app_url_android: , drivemond_app_url_ios: , firebase_otp_verification: 0, centralize_login: {manual_login_status: 1, otp_login_status: 0, social_login_status: 0, google_login_status: 0, facebook_login_status: 0, apple_login_status: 0, email_verification_status: 1, phone_verification_status: 0}, vehicle_distance_min: 0, vehicle_hourly_min: 0,
