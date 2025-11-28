import 'package:get/get.dart';
import 'package:friday_sa/features/rental_module/rental_favourite/domain/services/taxi_favourite_service_interface.dart';

class TaxiFavouriteController extends GetxController implements GetxService {
  TaxiFavouriteController({required this.taxiFavouriteServiceInterface});
  final TaxiFavouriteServiceInterface taxiFavouriteServiceInterface;

  Future<void> getFavouriteTaxiList() async {}
}
