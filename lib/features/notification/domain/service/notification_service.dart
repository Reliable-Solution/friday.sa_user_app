import 'package:friday_sa/features/notification/domain/models/notification_model.dart';
import 'package:friday_sa/features/notification/domain/repository/notification_repository_interface.dart';
import 'package:friday_sa/features/notification/domain/service/notification_service_interface.dart';

class NotificationService implements NotificationServiceInterface {
  NotificationService({required this.notificationRepositoryInterface});
  final NotificationRepositoryInterface notificationRepositoryInterface;

  @override
  Future<List<NotificationModel>?> getNotificationList() async {
    return await notificationRepositoryInterface.getList();
  }

  @override
  void saveSeenNotificationCount(int count) {
    notificationRepositoryInterface.saveSeenNotificationCount(count);
  }

  @override
  int? getSeenNotificationCount() {
    return notificationRepositoryInterface.getSeenNotificationCount();
  }

  @override
  List<int> getNotificationIdList() {
    return notificationRepositoryInterface.getNotificationIdList();
  }

  @override
  void addSeenNotificationIdList(List<int> notificationList) {
    notificationRepositoryInterface.addSeenNotificationIdList(notificationList);
  }
}
