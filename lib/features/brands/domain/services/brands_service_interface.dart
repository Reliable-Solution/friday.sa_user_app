import 'package:friday_sa/common/enums/data_source_enum.dart';
import 'package:friday_sa/features/brands/domain/models/brands_model.dart';
import 'package:friday_sa/features/item/domain/models/item_model.dart';

abstract class BrandsServiceInterface {
  Future<List<BrandModel>?> getBrandList(DataSourceEnum source);
  Future<ItemModel?> getBrandItemList({required int brandId, int? offset});
}
