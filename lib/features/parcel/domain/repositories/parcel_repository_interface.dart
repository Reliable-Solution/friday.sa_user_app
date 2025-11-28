import 'package:get/get_connect/http/src/response/response.dart';
import 'package:friday_sa/common/enums/data_source_enum.dart';
import 'package:friday_sa/interfaces/repository_interface.dart';

abstract class ParcelRepositoryInterface<T> implements RepositoryInterface {
  @override
  Future get(String? id, {bool isVideoDetails = true, DataSourceEnum source});
  @override
  Future getList({int? offset, bool parcelCategory = true});
  Future<Response> getPlaceDetails(String? placeID);
}
