import 'package:friday_sa/features/rental_module/domain/repository/taxi_repository_interface.dart';
import 'package:friday_sa/features/rental_module/domain/services/taxi_location_service_interface.dart';

class TaxiLocationService implements TaxiLocationServiceInterface {
  TaxiLocationService({required this.taxiRepositoryInterface});
  TaxiRepositoryInterface taxiRepositoryInterface;
}
