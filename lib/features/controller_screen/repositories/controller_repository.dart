import 'package:friday_sa/api/api_client.dart';
import 'package:friday_sa/features/controller_screen/models/controller_model.dart';
import 'package:friday_sa/features/controller_screen/repositories/controller_repository_interface.dart';
import 'package:friday_sa/util/app_constants.dart';
import 'package:get/get.dart';

class ControllerRepository implements ControllerRepositoryInterface {
  ControllerRepository({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<List<ControllerData>?> getController(String id) async {
    List<ControllerData>? documentList;
    Response response = await apiClient.getData(
      "${AppConstants.controllers}?user_id=$id&user_type=customer",
      handleError: false,
    );
    if (response.statusCode == 200) {
      documentList = [];
      ControllerModel data = ControllerModel.fromJson(response.body);
      documentList = data.data;
    }
    return documentList;
  }

  @override
  Future<ControllerData?> addController(
    String id,
    String channelId,
    String readKey,
    String writeKey,
  ) async {
    ControllerData? documentList;
    Response response = await apiClient.postData(AppConstants.controllers, {
      "user_id": id,
      "user_type": "customer",
      "chanel_id": channelId,
      "read_api_key": readKey,
      "write_api_key": writeKey,
    }, handleError: false);
    if (response.statusCode == 200) {
      ControllerData data = ControllerData.fromJson(response.body['data']);
      documentList = data;
    }
    return documentList;
  }

  @override
  Future<bool> deleteController(int? id, String userId) async {
    Response response = await apiClient.deleteData(
      "${AppConstants.controllers}/$id",
      body: {"user_id": userId, "user_type": "customer"},
    );
    return (response.statusCode == 200);
  }

  @override
  Future<bool> delete(int? id) async {
    Response response = await apiClient.deleteData(
      AppConstants.deleteDoc + id.toString(),
    );
    return (response.statusCode == 200);
  }

  @override
  Future get(value) async {
    throw UnimplementedError();
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
}
