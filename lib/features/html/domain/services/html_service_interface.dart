import 'package:get/get.dart';
import 'package:friday_sa/util/html_type.dart';

abstract class HtmlServiceInterface {
  Future<Response> getHtmlText(HtmlType htmlType);
}
