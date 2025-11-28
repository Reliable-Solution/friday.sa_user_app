import 'dart:convert';

import 'package:get/get.dart';
import 'package:friday_sa/api/local_client.dart';
import 'package:friday_sa/common/enums/data_source_enum.dart';
import 'package:friday_sa/features/category/domain/models/category_model.dart';
import 'package:friday_sa/features/item/domain/models/item_model.dart';
import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/features/store/domain/models/store_model.dart';
import 'package:friday_sa/features/language/controllers/language_controller.dart';
import 'package:friday_sa/api/api_client.dart';
import 'package:friday_sa/util/app_constants.dart';

import '../repositories/category_repository_interface.dart';

class CategoryRepository implements CategoryRepositoryInterface {
  CategoryRepository({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future getList({
    int? offset,
    bool categoryList = false,
    bool storeCategoryList = false,
    bool subCategoryList = false,
    bool categoryItemList = false,
    bool categoryStoreList = false,
    bool? allCategory,
    String? id,
    String? type,
    String? storeId,
    DataSourceEnum? source,
  }) async {
    if (categoryList) {
      return _getCategoryList(allCategory!, source ?? DataSourceEnum.client);
    } else if (subCategoryList) {
      return _getSubCategoryList(id);
    } else if (categoryItemList) {
      return _getCategoryItemList(id, offset!, type!);
    } else if (categoryStoreList) {
      return _getCategoryStoreList(id, offset!, type!);
    } else if (storeCategoryList) {
      return _getStoreCategoryList(storeId!, source ?? DataSourceEnum.client);
    }
  }

  Future<List<CategoryModel>?> _getCategoryList(
    bool allCategory,
    DataSourceEnum source,
  ) async {
    List<CategoryModel>? categoryList;
    Map<String, String>? header = allCategory
        ? {
            'Content-Type': 'application/json; charset=UTF-8',
            AppConstants.localizationKey:
                Get.find<LocalizationController>().locale.languageCode,
          }
        : null;

    Map<String, String>? cacheHeader = header ?? apiClient.getHeader();

    String cacheId =
        AppConstants.categoryUri +
        Get.find<SplashController>().module!.id!.toString();

    switch (source) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData(
          AppConstants.categoryUri,
          headers: header,
        );
        if (response.statusCode == 200) {
          categoryList = [];
          response.body.forEach((category) {
            categoryList!.add(CategoryModel.fromJson(category));
          });
          LocalClient.organize(
            DataSourceEnum.client,
            cacheId,
            jsonEncode(response.body),
            cacheHeader,
          );
        }

      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(
          DataSourceEnum.local,
          cacheId,
          null,
          null,
        );
        if (cacheResponseData != null) {
          categoryList = [];
          jsonDecode(cacheResponseData).forEach((category) {
            categoryList!.add(CategoryModel.fromJson(category));
          });
        }
    }

    return categoryList;
  }

  Future<List<CategoryModel>?> _getStoreCategoryList(
    String storeId,
    DataSourceEnum source,
  ) async {
    List<CategoryModel>? categoryList;
    Map<String, String>? header = {
      'Content-Type': 'application/json; charset=UTF-8',
      AppConstants.localizationKey:
          Get.find<LocalizationController>().locale.languageCode,
    };

    Map<String, String>? cacheHeader = header;

    String cacheId =
        AppConstants.storeCategoryUri +
        Get.find<SplashController>().module!.id!.toString();

    switch (source) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData(
          '${AppConstants.storeCategoryUri}?store_id=$storeId',
          headers: header,
        );
        if (response.statusCode == 200) {
          categoryList = [];
          response.body.forEach((category) {
            categoryList!.add(CategoryModel.fromJson(category));
          });
          LocalClient.organize(
            DataSourceEnum.client,
            cacheId,
            jsonEncode(response.body),
            cacheHeader,
          );
        }

      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(
          DataSourceEnum.local,
          cacheId,
          null,
          null,
        );
        if (cacheResponseData != null) {
          categoryList = [];
          jsonDecode(cacheResponseData).forEach((category) {
            categoryList!.add(CategoryModel.fromJson(category));
          });
        }
    }

    return categoryList;
  }

  Future<List<CategoryModel>?> _getSubCategoryList(String? parentID) async {
    List<CategoryModel>? subCategoryList;
    Response response = await apiClient.getData(
      '${AppConstants.subCategoryUri}$parentID',
    );
    if (response.statusCode == 200) {
      subCategoryList = [];
      response.body.forEach(
        (category) => subCategoryList!.add(CategoryModel.fromJson(category)),
      );
    }
    return subCategoryList;
  }

  Future<ItemModel?> _getCategoryItemList(
    String? categoryID,
    int offset,
    String type,
  ) async {
    ItemModel? categoryItem;
    Response response = await apiClient.getData(
      '${AppConstants.categoryItemUri}$categoryID?limit=10&offset=$offset&type=$type',
    );
    if (response.statusCode == 200) {
      categoryItem = ItemModel.fromJson(response.body);
    }
    return categoryItem;
  }

  Future<StoreModel?> _getCategoryStoreList(
    String? categoryID,
    int offset,
    String type,
  ) async {
    StoreModel? categoryStore;
    Response response = await apiClient.getData(
      '${AppConstants.categoryStoreUri}$categoryID?limit=10&offset=$offset&type=$type',
    );
    if (response.statusCode == 200) {
      categoryStore = StoreModel.fromJson(response.body);
    }
    return categoryStore;
  }

  @override
  Future<Response> getSearchData(
    String? query,
    String? categoryID,
    bool isStore,
    String type,
  ) async {
    return apiClient.getData(
      '${AppConstants.searchUri}${isStore ? 'stores' : 'items'}/search?name=$query&category_id=$categoryID&type=$type&offset=1&limit=50',
    );
  }

  @override
  Future<bool> saveUserInterests(List<int?> interests) async {
    Response response = await apiClient.postData(AppConstants.interestUri, {
      "interest": interests,
    });
    return (response.statusCode == 200);
  }

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
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
}
