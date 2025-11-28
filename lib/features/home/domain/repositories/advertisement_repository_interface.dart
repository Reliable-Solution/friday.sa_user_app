import 'package:friday_sa/common/enums/data_source_enum.dart';
import 'package:friday_sa/features/home/domain/models/advertisement_model.dart';
import 'package:friday_sa/interfaces/repository_interface.dart';

abstract class AdvertisementRepositoryInterface extends RepositoryInterface {
  @override
  Future<List<AdvertisementModel>?> getList({
    int? offset,
    DataSourceEnum source = DataSourceEnum.client,
  });
}
