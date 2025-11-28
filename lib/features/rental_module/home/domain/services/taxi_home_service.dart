import 'package:friday_sa/features/rental_module/home/domain/repositories/taxi_home_repository_interface.dart';
import 'package:friday_sa/features/rental_module/home/domain/services/taxi_home_service_interface.dart';

class TaxiHomeService implements TaxiHomeServiceInterface {
  TaxiHomeService({required this.taxiHomeRepositoryInterface});
  final TaxiHomeRepositoryInterface taxiHomeRepositoryInterface;
}
