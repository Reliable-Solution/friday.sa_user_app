import 'package:friday_sa/features/onboard/domain/models/onboarding_model.dart';
import 'package:get/get.dart';
import 'package:friday_sa/features/onboard/domain/service/onboard_service_interface.dart';

class OnBoardingController extends GetxController implements GetxService {
  OnBoardingController({required this.onboardServiceInterface});
  final OnboardServiceInterface onboardServiceInterface;

  List<OnBoardingModel> _onBoardingList = [];
  List<OnBoardingModel> get onBoardingList => _onBoardingList;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void changeSelectIndex(int index) {
    _selectedIndex = index;
    update();
  }

  Future<void> getOnBoardingList() async {
    Response response = await onboardServiceInterface.getOnBoardingList();
    if (response.statusCode == 200) {
      _onBoardingList = [];
      _onBoardingList.addAll(response.body);
      _onBoardingList.add(OnBoardingModel('', '', ''));
    }
    update();
  }
}
