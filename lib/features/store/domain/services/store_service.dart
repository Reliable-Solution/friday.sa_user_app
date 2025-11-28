import 'package:get/get.dart';
import 'package:friday_sa/common/enums/data_source_enum.dart';
import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/features/store/domain/models/cart_suggested_item_model.dart';
import 'package:friday_sa/features/item/domain/models/item_model.dart';
import 'package:friday_sa/common/models/module_model.dart';
import 'package:friday_sa/features/store/domain/models/recommended_product_model.dart';
import 'package:friday_sa/features/store/domain/models/store_banner_model.dart';
import 'package:friday_sa/features/store/domain/models/store_model.dart';
import 'package:friday_sa/features/location/domain/models/zone_response_model.dart';
import 'package:friday_sa/features/store/domain/repositories/store_repository_interface.dart';
import 'package:friday_sa/features/store/domain/services/store_service_interface.dart';
import 'package:friday_sa/helper/address_helper.dart';
import 'package:friday_sa/util/app_constants.dart';

class StoreService implements StoreServiceInterface {
  StoreService({required this.storeRepositoryInterface});
  final StoreRepositoryInterface storeRepositoryInterface;

  @override
  Future<StoreModel?> getStoreList(
    int offset,
    String filterBy,
    String storeType, {
    required DataSourceEnum source,
  }) async {
    return await storeRepositoryInterface.getList(
      offset: offset,
      isStoreList: true,
      filterBy: filterBy,
      type: storeType,
      source: source,
    );
  }

  @override
  Future<List<Store>?> getPopularStoreList(
    String type, {
    required DataSourceEnum source,
  }) async {
    return await storeRepositoryInterface.getList(
      isPopularStoreList: true,
      type: type,
      source: source,
    );
  }

  @override
  Future<List<Store>?> getLatestStoreList(
    String type, {
    required DataSourceEnum source,
  }) async {
    return await storeRepositoryInterface.getList(
      isLatestStoreList: true,
      type: type,
      source: source,
    );
  }

  @override
  Future<List<Store>?> getTopOfferStoreList({
    required DataSourceEnum source,
    String? filterBy,
    String? sortBy,
  }) async {
    return await storeRepositoryInterface.getList(
      isTopOfferStoreList: true,
      source: source,
      filterBy: filterBy,
      type: sortBy,
    );
  }

  @override
  Future<List<Store>?> getFeaturedStoreList({
    required DataSourceEnum source,
  }) async {
    return await storeRepositoryInterface.getList(
      isFeaturedStoreList: true,
      source: source,
    );
  }

  @override
  Future<List<Store>?> getVisitAgainStoreList({
    required DataSourceEnum source,
  }) async {
    return await storeRepositoryInterface.getList(
      isVisitAgainStoreList: true,
      source: source,
    );
  }

  @override
  Future<Store?> getStoreDetails(
    String storeID,
    bool fromCart,
    String slug,
    String languageCode,
    ModuleModel? module,
    int? cacheModuleId,
    int? moduleId,
  ) async {
    return await storeRepositoryInterface.getStoreDetails(
      storeID,
      fromCart,
      slug,
      languageCode,
      module,
      cacheModuleId,
      moduleId,
    );
  }

  @override
  Future<ItemModel?> getStoreItemList(
    int? storeID,
    int offset,
    int? categoryID,
    String type,
  ) async {
    return await storeRepositoryInterface.getStoreItemList(
      storeID,
      offset,
      categoryID,
      type,
    );
  }

  @override
  Future<ItemModel?> getStoreSearchItemList(
    String searchText,
    String? storeID,
    int offset,
    String type,
    int? categoryID,
  ) async {
    return await storeRepositoryInterface.getStoreSearchItemList(
      searchText,
      storeID,
      offset,
      type,
      categoryID,
    );
  }

  @override
  Future<RecommendedItemModel?> getStoreRecommendedItemList(
    int? storeId,
  ) async {
    return await storeRepositoryInterface.getList(
      isStoreRecommendedItemList: true,
      storeId: storeId,
    );
  }

  @override
  Future<CartSuggestItemModel?> getCartStoreSuggestedItemList(
    int? storeId,
    String languageCode,
    ModuleModel? module,
    int? cacheModuleId,
    int? moduleId,
  ) async {
    return await storeRepositoryInterface.getCartStoreSuggestedItemList(
      storeId,
      languageCode,
      module,
      cacheModuleId,
      moduleId,
    );
  }

  @override
  Future<List<StoreBannerModel>?> getStoreBannerList(int? storeId) async {
    return await storeRepositoryInterface.getList(
      isStoreBannerList: true,
      storeId: storeId,
    );
  }

  @override
  Future<List<Store>?> getRecommendedStoreList({
    required DataSourceEnum source,
  }) async {
    return await storeRepositoryInterface.getList(
      isRecommendedStoreList: true,
      source: source,
    );
  }

  @override
  List<Modules> moduleList() {
    List<Modules> moduleList = [];
    for (ZoneData zone
        in AddressHelper.getUserAddressFromSharedPref()!.zoneData ?? []) {
      for (Modules module in zone.modules ?? []) {
        moduleList.add(module);
      }
    }
    return moduleList;
  }

  @override
  String filterRestaurantLinkUrl(String slug, Store store) {
    List<String> routes = Get.currentRoute.split('?');
    String replace = '';

    if (AppConstants.useReactWebsite) {
      if (slug.isNotEmpty) {
        replace =
            '${routes[0]}/$slug?module_id=${store.moduleId}&module_type=${Get.find<SplashController>().module!.moduleType}&store_zone_id=${store.zoneId}&distance=${store.distance}';
      } else {
        replace =
            '${routes[0]}/${store.id}?module_id=${store.moduleId}&module_type=${Get.find<SplashController>().module!.moduleType}&store_zone_id=${store.zoneId}&distance=${store.distance}';
      }
    } else {
      if (slug.isNotEmpty) {
        replace = '${routes[0]}?slug=$slug';
      } else {
        replace = '${routes[0]}?slug=${store.id}';
      }
    }
    return replace;
  }
}
