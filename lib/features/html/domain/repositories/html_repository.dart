import 'package:friday_sa/features/language/controllers/language_controller.dart';
import 'package:friday_sa/api/api_client.dart';
import 'package:friday_sa/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:friday_sa/util/html_type.dart';
import 'package:friday_sa/features/html/domain/repositories/html_repository_interface.dart';

class HtmlRepository implements HtmlRepositoryInterface {
  HtmlRepository({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<Response> getHtmlText(HtmlType htmlType) async {
    return apiClient.getData(
      htmlType == HtmlType.termsAndCondition
          ? AppConstants.termsAndConditionUri
          : htmlType == HtmlType.privacyPolicy
          ? AppConstants.privacyPolicyUri
          : htmlType == HtmlType.aboutUs
          ? AppConstants.aboutUsUri
          : htmlType == HtmlType.shippingPolicy
          ? AppConstants.shippingPolicyUri
          : htmlType == HtmlType.cancellation
          ? AppConstants.cancellationUri
          : AppConstants.refundUri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        AppConstants.localizationKey:
            Get.find<LocalizationController>().locale.languageCode,
      },
    );
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
}
