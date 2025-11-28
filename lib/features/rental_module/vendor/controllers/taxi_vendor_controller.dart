import 'package:get/get.dart';
import 'package:friday_sa/features/rental_module/vendor/domain/services/taxi_vendor_service_interface.dart';

class TaxiVendorController extends GetxController implements GetxService {
  TaxiVendorController({required this.taxiVendorServiceInterface});
  final TaxiVendorServiceInterface taxiVendorServiceInterface;
}
