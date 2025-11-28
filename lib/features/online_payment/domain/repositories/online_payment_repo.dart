import 'package:friday_sa/api/api_client.dart';
import 'package:friday_sa/features/online_payment/domain/repositories/online_payment_repo_interface.dart';

class OnlinePaymentRepo implements OnlinePaymentRepoInterface {
  OnlinePaymentRepo({required this.apiClient});
  final ApiClient apiClient;

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
  Future getList({int? offset}) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
}
