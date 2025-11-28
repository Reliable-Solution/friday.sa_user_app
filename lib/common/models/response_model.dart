import 'package:friday_sa/features/auth/domain/models/auth_response_model.dart';
import 'package:friday_sa/features/profile/domain/models/update_profile_response_model.dart';

class ResponseModel {
  ResponseModel(
    this._isSuccess,
    this._message, {
    this.zoneIds,
    this.authResponseModel,
    this.updateProfileResponseModel,
  });
  final bool _isSuccess;
  final String? _message;
  List<int>? zoneIds;
  AuthResponseModel? authResponseModel;
  UpdateProfileResponseModel? updateProfileResponseModel;

  String? get message => _message;
  bool get isSuccess => _isSuccess;
}
