import 'package:shared_preferences/shared_preferences.dart';
import 'package:friday_sa/api/api_client.dart';
import 'package:friday_sa/features/rental_module/rental_favourite/domain/repositories/taxi_favourite_repository_interface.dart';

class TaxiFavouriteRepository implements TaxiFavouriteRepositoryInterface {
  TaxiFavouriteRepository({
    required this.sharedPreferences,
    required this.apiClient,
  });
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  @override
  Future get(String? id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  Future add(value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) {
    // TODO: implement getList
    throw UnimplementedError();
  }
}
