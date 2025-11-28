import 'package:friday_sa/features/controller_screen/models/controller_model.dart';
import 'package:friday_sa/interfaces/repository_interface.dart';

abstract class ControllerRepositoryInterface extends RepositoryInterface {
  Future<List<ControllerData>?> getController(String id);
  Future<ControllerData?> addController(
    String id,
    String channelId,
    String readKey,
    String writeKey,
  );
  Future<bool> deleteController(int? id, String userId);
}
