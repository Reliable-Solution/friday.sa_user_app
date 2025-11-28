import 'package:friday_sa/interfaces/repository_interface.dart';

abstract class WalletRepositoryInterface extends RepositoryInterface {
  Future<dynamic> addFundToWallet(num amount, String paymentMethod);
  Future<void> setWalletAccessToken(String token);
  String getWalletAccessToken();
  @override
  Future getList({int? offset, String? sortingType, bool isBonusList = false});
}
