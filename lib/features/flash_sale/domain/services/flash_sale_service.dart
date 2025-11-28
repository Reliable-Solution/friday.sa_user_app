import 'package:friday_sa/common/enums/data_source_enum.dart';
import 'package:friday_sa/features/flash_sale/domain/models/flash_sale_model.dart';
import 'package:friday_sa/features/flash_sale/domain/models/product_flash_sale.dart';
import 'package:friday_sa/features/flash_sale/domain/repositories/flash_sale_repository_interface.dart';
import 'package:friday_sa/features/flash_sale/domain/services/flash_sale_service_interface.dart';

class FlashSaleService implements FlashSaleServiceInterface {
  FlashSaleService({required this.flashSaleRepositoryInterface});
  final FlashSaleRepositoryInterface flashSaleRepositoryInterface;

  @override
  Future<FlashSaleModel?> getFlashSale(DataSourceEnum source) async {
    return await flashSaleRepositoryInterface.getFlashSale(source: source);
  }

  @override
  Future<ProductFlashSale?> getFlashSaleWithId(int id, int offset) async {
    return await flashSaleRepositoryInterface.getFlashSaleWithId(id, offset);
  }
}
