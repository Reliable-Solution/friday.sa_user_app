import 'package:get/get_connect.dart';
import 'package:friday_sa/common/models/transaction_model.dart';
import 'package:friday_sa/api/api_client.dart';
import 'package:friday_sa/features/loyalty/domain/repositories/loyalty_repository_interface.dart';
import 'package:friday_sa/util/app_constants.dart';

class LoyaltyRepository implements LoyaltyRepositoryInterface {
  LoyaltyRepository({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<Response> pointToWallet({int? point}) async {
    return apiClient.postData(AppConstants.loyaltyPointTransferUri, {
      "point": point,
    });
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) async {
    return _getLoyaltyTransactionList(offset);
  }

  Future<TransactionModel?> _getLoyaltyTransactionList(int? offset) async {
    TransactionModel? transactionModel;
    Response response = await apiClient.getData(
      '${AppConstants.loyaltyTransactionUri}?offset=$offset&limit=10',
    );
    if (response.statusCode == 200) {
      transactionModel = TransactionModel.fromJson(response.body);
    }
    return transactionModel;
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
}
