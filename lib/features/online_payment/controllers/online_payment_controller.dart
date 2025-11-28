import 'package:get/get.dart';
import 'package:friday_sa/features/online_payment/domain/services/online_payment_service_interface.dart';

class OnlinePaymentController extends GetxController implements GetxService {
  OnlinePaymentController({required this.onlinePaymentServiceInterface});
  final OnlinePaymentServiceInterface onlinePaymentServiceInterface;
}
