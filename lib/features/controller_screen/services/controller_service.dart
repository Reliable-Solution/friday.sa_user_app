import 'package:friday_sa/features/controller_screen/models/controller_model.dart';
import 'package:friday_sa/features/controller_screen/repositories/controller_repository_interface.dart';
import 'package:friday_sa/features/controller_screen/services/controller_service_interface.dart';

class ControllerService implements ControllerServiceInterface {
  ControllerService({required this.controllerRepositoryInterface});
  final ControllerRepositoryInterface controllerRepositoryInterface;

  @override
  Future<List<ControllerData>?> getController(String id) async {
    return controllerRepositoryInterface.getController(id);
  }

  @override
  Future<ControllerData?> addController(
    String id,
    String channelId,
    String readKey,
    String writeKey,
  ) async {
    return controllerRepositoryInterface.addController(
      id,
      channelId,
      readKey,
      writeKey,
    );
  }

  @override
  Future<bool> deleteController(int id, String userId) async {
    return controllerRepositoryInterface.deleteController(id, userId);
  }
}
