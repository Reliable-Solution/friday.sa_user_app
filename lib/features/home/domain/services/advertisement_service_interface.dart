import 'package:friday_sa/common/enums/data_source_enum.dart';
import 'package:friday_sa/features/home/domain/models/advertisement_model.dart';

abstract class AdvertisementServiceInterface {
  Future<List<AdvertisementModel>?> getAdvertisementList(DataSourceEnum source);
}
