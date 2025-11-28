import 'package:friday_sa/common/enums/data_source_enum.dart';
import 'package:friday_sa/interfaces/repository_interface.dart';

abstract class CategoryRepositoryInterface implements RepositoryInterface {
  @override
  Future getList({
    int? offset,
    bool categoryList = false,
    bool subCategoryList = false,
    bool categoryItemList = false,
    bool categoryStoreList = false,
    bool? allCategory,
    String? storeId,
    String? id,
    String? type,
    DataSourceEnum? source,
  });
  Future<dynamic> getSearchData(
    String? query,
    String? categoryID,
    bool isStore,
    String type,
  );
  Future<dynamic> saveUserInterests(List<int?> interests);
}
