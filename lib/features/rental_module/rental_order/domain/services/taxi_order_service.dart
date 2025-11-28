import 'package:friday_sa/features/rental_module/rental_order/domain/repository/taxi_order_repository_interface.dart';
import 'package:friday_sa/features/rental_module/rental_order/domain/services/taxi_order_service_interface.dart';

class TaxiOrderService implements TaxiOrderServiceInterface {
  TaxiOrderService({required this.taxiOrderRepositoryInterface});
  final TaxiOrderRepositoryInterface taxiOrderRepositoryInterface;
}
