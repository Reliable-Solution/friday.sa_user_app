import 'package:friday_sa/interfaces/repository_interface.dart';

abstract class PaymentRepositoryInterface extends RepositoryInterface {
  Future<bool> saveOfflineInfo(String data);
  Future<bool> updateOfflineInfo(String data);
}
