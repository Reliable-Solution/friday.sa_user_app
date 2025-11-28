import 'package:get/get_connect.dart';
import 'package:image_picker/image_picker.dart';
import 'package:friday_sa/features/auth/domain/models/store_body_model.dart';
import 'package:friday_sa/features/business/domain/models/package_model.dart';
import 'package:friday_sa/interfaces/repository_interface.dart';

abstract class StoreRegistrationRepositoryInterface
    extends RepositoryInterface {
  Future<Response> registerStore(
    StoreBodyModel store,
    XFile? logo,
    XFile? cover,
  );
  Future<bool> checkInZone(String? lat, String? lng, int zoneId);
  Future<PackageModel?> getPackageList({int? moduleId});
}
