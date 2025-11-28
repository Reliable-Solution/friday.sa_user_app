import 'package:get/get.dart';
import 'package:friday_sa/common/models/response_model.dart';
import 'package:friday_sa/api/api_client.dart';
import 'package:friday_sa/features/favourite/domain/repositories/favourite_repository_interface.dart';
import 'package:friday_sa/util/app_constants.dart';

class FavouriteRepository
    implements FavouriteRepositoryInterface<ResponseModel> {
  FavouriteRepository({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<Response> getList({int? offset}) async {
    return apiClient.getData(AppConstants.wishListGetUri);
  }

  @override
  Future<ResponseModel> add(dynamic a, {bool isStore = false, int? id}) async {
    ResponseModel responseModel;
    Response response = await apiClient.postData(
      '${AppConstants.addWishListUri}${isStore ? 'store_id=' : 'item_id='}$id',
      null,
      handleError: false,
    );
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  @override
  Future<ResponseModel> delete(int? id, {bool isStore = false}) async {
    ResponseModel responseModel;
    Response response = await apiClient.deleteData(
      '${AppConstants.removeWishListUri}${isStore ? 'store_id=' : 'item_id='}$id',
      handleError: false,
    );
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
}
