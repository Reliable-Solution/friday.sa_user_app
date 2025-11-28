import 'package:friday_sa/common/models/transaction_model.dart';
import 'package:friday_sa/features/wallet/domain/models/fund_bonus_model.dart';

abstract class WalletServiceInterface {
  Future<TransactionModel?> getWalletTransactionList(
    String offset,
    String sortingType,
  );
  Future<dynamic> addFundToWallet(num amount, String paymentMethod);
  Future<List<FundBonusModel>?> getWalletBonusList();
  Future<void> setWalletAccessToken(String token);
  String getWalletAccessToken();
}
