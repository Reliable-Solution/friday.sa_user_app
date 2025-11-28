import 'package:friday_sa/api/api_client.dart';
import 'package:friday_sa/features/rental_module/vendor/domain/repositories/taxi_vendor_repository_interface.dart';

class TaxiVendorRepository implements TaxiVendorRepositoryInterface {
  TaxiVendorRepository({required this.apiClient});
  final ApiClient apiClient;

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
  Future get(String? id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) {
    // TODO: implement getList
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
