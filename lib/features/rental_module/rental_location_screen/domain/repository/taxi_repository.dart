import 'package:shared_preferences/shared_preferences.dart';
import 'package:friday_sa/api/api_client.dart';
import 'package:friday_sa/features/rental_module/rental_location_screen/domain/repository/taxi_repository_interface.dart';

class TaxiRepository implements TaxiRepositoryInterface {
  TaxiRepository({required this.sharedPreferences, required this.apiClient});
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
}
