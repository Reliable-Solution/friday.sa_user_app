import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:friday_sa/common/models/module_model.dart';
import 'package:friday_sa/features/auth/domain/reposotories/store_registration_repository_interface.dart';
import 'package:friday_sa/features/business/domain/models/package_model.dart';
import 'package:friday_sa/features/location/domain/models/zone_data_model.dart';
import 'package:friday_sa/features/auth/domain/models/store_body_model.dart';
import 'package:friday_sa/features/auth/domain/reposotories/deliveryman_registration_repository_interface.dart';
import 'package:friday_sa/features/auth/domain/services/store_registration_service_interface.dart';

class StoreRegistrationService implements StoreRegistrationServiceInterface {
  StoreRegistrationService({
    required this.deliverymanRegistrationRepositoryInterface,
    required this.storeRegistrationRepoInterface,
  });
  final StoreRegistrationRepositoryInterface storeRegistrationRepoInterface;
  final DeliverymanRegistrationRepositoryInterface
  deliverymanRegistrationRepositoryInterface;

  @override
  Future<List<ZoneDataModel>?> getZoneList() async {
    return await deliverymanRegistrationRepositoryInterface.getList();
  }

  @override
  int? prepareSelectedZoneIndex(
    List<int>? zoneIds,
    List<ZoneDataModel>? zoneList,
  ) {
    int? selectedZoneIndex = 0;
    for (int index = 0; index < zoneList!.length; index++) {
      if (zoneIds!.contains(zoneList[index].id)) {
        selectedZoneIndex = index;
        break;
      }
    }
    return selectedZoneIndex;
  }

  @override
  Future<List<ModuleModel>?> getModules(int? zoneId) async {
    return await deliverymanRegistrationRepositoryInterface.getList(
      isZone: false,
      zoneId: zoneId,
    );
  }

  @override
  Future<Response> registerStore(
    StoreBodyModel store,
    XFile? logo,
    XFile? cover,
  ) async {
    return storeRegistrationRepoInterface.registerStore(store, logo, cover);
  }

  @override
  Future<bool> checkInZone(String? lat, String? lng, int zoneId) async {
    return storeRegistrationRepoInterface.checkInZone(lat, lng, zoneId);
  }

  @override
  Future<PackageModel?> getPackageList({int? moduleId}) async {
    return storeRegistrationRepoInterface.getPackageList(moduleId: moduleId);
  }
}
