import 'package:friday_sa/features/home/domain/models/cashback_model.dart';
import 'package:friday_sa/features/home/domain/repositories/home_repository_interface.dart';
import 'package:friday_sa/features/home/domain/services/home_service_interface.dart';

class HomeService implements HomeServiceInterface {
  HomeService({required this.homeRepositoryInterface});
  final HomeRepositoryInterface homeRepositoryInterface;

  @override
  Future<List<CashBackModel>> getCashBackOfferList() async {
    return await homeRepositoryInterface.getList();
  }

  @override
  Future<CashBackModel?> getCashBackData(num amount) async {
    return homeRepositoryInterface.getCashBackData(amount);
  }

  @override
  Future<bool> saveRegistrationSuccessful(bool status) async {
    return homeRepositoryInterface.saveRegistrationSuccessful(status);
  }

  @override
  Future<bool> saveIsRestaurantRegistration(bool status) async {
    return homeRepositoryInterface.saveIsRestaurantRegistration(status);
  }

  @override
  bool getRegistrationSuccessful() {
    return homeRepositoryInterface.getRegistrationSuccessful();
  }

  @override
  bool getIsRestaurantRegistration() {
    return homeRepositoryInterface.getIsRestaurantRegistration();
  }
}
