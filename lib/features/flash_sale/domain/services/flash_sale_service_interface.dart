import 'package:friday_sa/common/enums/data_source_enum.dart';
import 'package:friday_sa/features/flash_sale/domain/models/flash_sale_model.dart';
import 'package:friday_sa/features/flash_sale/domain/models/product_flash_sale.dart';

abstract class FlashSaleServiceInterface {
  Future<FlashSaleModel?> getFlashSale(DataSourceEnum source);
  Future<ProductFlashSale?> getFlashSaleWithId(int id, int offset);
}
