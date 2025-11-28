import 'package:friday_sa/common/enums/data_source_enum.dart';
import 'package:friday_sa/interfaces/repository_interface.dart';

abstract class CampaignRepositoryInterface implements RepositoryInterface {
  @override
  Future getList({
    int? offset,
    bool isBasicCampaign = false,
    bool isItemCampaign = false,
    DataSourceEnum source,
  });
}
