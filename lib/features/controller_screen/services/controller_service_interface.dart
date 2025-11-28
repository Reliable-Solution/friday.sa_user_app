import 'package:friday_sa/features/controller_screen/models/controller_model.dart';

abstract class ControllerServiceInterface {
  Future<List<ControllerData>?> getController(String id);
  Future<ControllerData?> addController(
    String id,
    String chanelId,
    String readKey,
    String writeKey,
  );
  Future<bool> deleteController(int id, String userId);
}
