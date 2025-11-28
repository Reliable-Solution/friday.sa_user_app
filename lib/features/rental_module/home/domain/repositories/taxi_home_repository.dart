import 'package:shared_preferences/shared_preferences.dart';
import 'package:friday_sa/api/api_client.dart';
import 'package:friday_sa/features/rental_module/home/domain/repositories/taxi_home_repository_interface.dart';

class TaxiHomeRepository implements TaxiHomeRepositoryInterface {
  TaxiHomeRepository({
    required this.sharedPreferences,
    required this.apiClient,
  });
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

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
