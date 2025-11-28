import 'package:friday_sa/interfaces/repository_interface.dart';
import 'package:friday_sa/util/html_type.dart';

abstract class HtmlRepositoryInterface extends RepositoryInterface {
  Future<dynamic> getHtmlText(HtmlType htmlType);
}
