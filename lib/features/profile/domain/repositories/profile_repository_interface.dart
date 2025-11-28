import 'package:image_picker/image_picker.dart';
import 'package:friday_sa/common/models/response_model.dart';
import 'package:friday_sa/features/profile/domain/models/update_user_model.dart';
import 'package:friday_sa/features/profile/domain/models/userinfo_model.dart';
import 'package:friday_sa/interfaces/repository_interface.dart';

abstract class ProfileRepositoryInterface extends RepositoryInterface {
  //Future<dynamic> updateProfile(UserInfoModel userInfoModel, XFile? data, String token);
  Future<ResponseModel> updateProfile(
    UpdateUserModel userInfoModel,
    XFile? data,
    String token,
  );
  Future<dynamic> changePassword(UserInfoModel userInfoModel);
}
