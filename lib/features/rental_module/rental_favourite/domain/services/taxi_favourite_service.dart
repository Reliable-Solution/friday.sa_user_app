import 'package:friday_sa/features/rental_module/rental_favourite/domain/repositories/taxi_favourite_repository_interface.dart';
import 'package:friday_sa/features/rental_module/rental_favourite/domain/services/taxi_favourite_service_interface.dart';

class TaxiFavouriteService implements TaxiFavouriteServiceInterface {
  TaxiFavouriteService({required this.taxiFavouriteRepositoryInterface});
  final TaxiFavouriteRepositoryInterface taxiFavouriteRepositoryInterface;
}
