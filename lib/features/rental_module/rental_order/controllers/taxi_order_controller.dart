import 'package:get/get.dart';
import 'package:friday_sa/features/rental_module/rental_order/domain/services/taxi_order_service_interface.dart';

class TaxiOrderController extends GetxController implements GetxService {
  TaxiOrderController({required this.taxiOrderServiceInterface});
  final TaxiOrderServiceInterface taxiOrderServiceInterface;

  final bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> getTripList(
    int offset, {
    bool isUpdate = false,
    bool isRunning = true,
    bool fromHome = false,
  }) async {}

  Future<bool> getTripDetails(
    int id, {
    bool willUpdate = true,
    String? phone,
  }) async {
    return false;
  }
}
