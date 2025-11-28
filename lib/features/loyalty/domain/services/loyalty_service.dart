import 'package:get/get_connect/http/src/response/response.dart';
import 'package:friday_sa/common/models/transaction_model.dart';
import 'package:friday_sa/features/loyalty/domain/repositories/loyalty_repository_interface.dart';
import 'package:friday_sa/features/loyalty/domain/services/loyalty_service_interface.dart';

class LoyaltyService implements LoyaltyServiceInterface {
  LoyaltyService({required this.loyaltyRepositoryInterface});
  final LoyaltyRepositoryInterface loyaltyRepositoryInterface;

  @override
  Future<TransactionModel?> getLoyaltyTransactionList(String offset) async {
    return await loyaltyRepositoryInterface.getList(offset: int.parse(offset));
  }

  @override
  Future<Response> pointToWallet({int? point}) async {
    return loyaltyRepositoryInterface.pointToWallet(point: point);
  }
}
