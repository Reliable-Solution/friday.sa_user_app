import 'package:get/get.dart';
import 'package:friday_sa/common/enums/data_source_enum.dart';
import 'package:friday_sa/features/category/domain/models/category_model.dart';
import 'package:friday_sa/features/item/domain/models/item_model.dart';
import 'package:friday_sa/features/store/domain/models/store_model.dart';

abstract class CategoryServiceInterface {
  Future<List<CategoryModel>?> getCategoryList(
    bool allCategory, {
    DataSourceEnum? source,
  });
  Future<List<CategoryModel>?> getStoreCategoryList(
    String storeId, {
    DataSourceEnum? source,
  });
  Future<List<CategoryModel>?> getSubCategoryList(String? parentID);
  Future<ItemModel?> getCategoryItemList(
    String? categoryID,
    int offset,
    String type,
  );
  Future<StoreModel?> getCategoryStoreList(
    String? categoryID,
    int offset,
    String type,
  );
  Future<Response> getSearchData(
    String? query,
    String? categoryID,
    bool isStore,
    String type,
  );
  Future<bool> saveUserInterests(List<int?> interests);
}
