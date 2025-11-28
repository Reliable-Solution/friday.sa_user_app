import 'package:get/get.dart';
import 'package:friday_sa/features/rental_module/domain/services/taxi_location_service_interface.dart';

class TaxiLocationController extends GetxController implements GetxService {
  TaxiLocationController({required this.taxiLocationServiceInterface});
  final TaxiLocationServiceInterface taxiLocationServiceInterface;
}
