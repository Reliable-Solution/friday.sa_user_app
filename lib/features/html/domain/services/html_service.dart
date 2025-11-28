import 'package:get/get.dart';
import 'package:friday_sa/features/html/domain/repositories/html_repository_interface.dart';
import 'package:friday_sa/features/html/domain/services/html_service_interface.dart';
import 'package:friday_sa/util/html_type.dart';

class HtmlService implements HtmlServiceInterface {
  HtmlService({required this.htmlRepositoryInterface});
  final HtmlRepositoryInterface htmlRepositoryInterface;

  @override
  Future<Response> getHtmlText(HtmlType htmlType) async {
    return await htmlRepositoryInterface.getHtmlText(htmlType);
  }
}
