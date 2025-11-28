import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:friday_sa/api/api_client.dart';
import 'package:friday_sa/common/models/module_model.dart';
import 'package:friday_sa/features/location/domain/models/zone_data_model.dart';
import 'package:friday_sa/features/auth/domain/models/delivery_man_body.dart';
import 'package:friday_sa/features/auth/domain/models/delivery_man_vehicles_model.dart';
import 'package:friday_sa/features/auth/domain/reposotories/auth_repository_interface.dart';
import 'package:friday_sa/features/auth/domain/reposotories/deliveryman_registration_repository_interface.dart';
import 'package:friday_sa/features/auth/domain/services/deliveryman_registration_service_interface.dart';
import 'package:friday_sa/helper/route_helper.dart';
import 'package:friday_sa/common/widgets/custom_snackbar.dart';

class DeliverymanRegistrationService
    implements DeliverymanRegistrationServiceInterface {
  DeliverymanRegistrationService({
    required this.deliverymanRegistrationRepoInterface,
    required this.authRepositoryInterface,
  });
  final DeliverymanRegistrationRepositoryInterface
  deliverymanRegistrationRepoInterface;
  final AuthRepositoryInterface authRepositoryInterface;

  @override
  Future<List<ZoneDataModel>?> getZoneList() async {
    return await deliverymanRegistrationRepoInterface.getList();
  }

  @override
  Future<List<ModuleModel>?> getModules(int? zoneId) async {
    return await deliverymanRegistrationRepoInterface.getList(
      isZone: false,
      zoneId: zoneId,
    );
  }

  @override
  Future<List<DeliveryManVehicleModel>?> getVehicleList() async {
    return await deliverymanRegistrationRepoInterface.getList(
      isZone: false,
      isVehicle: true,
    );
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
  List<int?>? prepareVehicleIds(List<DeliveryManVehicleModel>? vehicleList) {
    List<int?>? vehicleIds = [];
    vehicleIds.add(0);
    for (var vehicle in vehicleList!) {
      vehicleIds.add(vehicle.id);
    }
    return vehicleIds;
  }

  @override
  Future<void> registerDeliveryMan(
    DeliveryManBody deliveryManBody,
    List<MultipartBody> multiParts,
  ) async {
    bool success = await deliverymanRegistrationRepoInterface
        .registerDeliveryMan(deliveryManBody, multiParts);
    if (success) {
      Get.offAllNamed(RouteHelper.getInitialRoute());
      showCustomSnackBar(
        'delivery_man_registration_successful'.tr,
        isError: false,
      );
    }
  }

  @override
  List<MultipartBody> prepareMultipart(
    XFile? pickedImage,
    List<XFile> pickedIdentities,
  ) {
    List<MultipartBody> multiParts = [];
    multiParts.add(MultipartBody('image', pickedImage));
    for (XFile file in pickedIdentities) {
      multiParts.add(MultipartBody('identity_image[]', file));
    }
    return multiParts;
  }
}
