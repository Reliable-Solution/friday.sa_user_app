import 'package:friday_sa/features/rental_module/vendor/domain/repositories/taxi_vendor_repository_interface.dart';
import 'package:friday_sa/features/rental_module/vendor/domain/services/taxi_vendor_service_interface.dart';

class TaxiVendorService implements TaxiVendorServiceInterface {
  TaxiVendorService({required this.taxiVendorRepositoryInterface});
  final TaxiVendorRepositoryInterface taxiVendorRepositoryInterface;
}
