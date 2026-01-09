import 'package:flutter/cupertino.dart';
import 'package:flats_app/Services/Notifications/get_all_notifications.dart';
import 'package:flats_app/models/model_notification.dart';
import '../Services/Notifications/mark_as_read_services.dart';

class notification_provider extends ChangeNotifier {
  final allNotification = get_all_notifications();
  final markReadService = mark_as_read();

  bool isLoading = false;

  List<NotificationItemModel> unReadList = [];
  List<NotificationItemModel> readList = [];

  int get UnRead => unReadList.length;

  void Function(List<NotificationItemModel> newOnes)? onNewNotifications;

  List<NotificationItemModel> _prevUnread = [];

  Future<void> getNumberMesseageUnRead({required String token}) async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await allNotification.getAllNotifications(token: token);

      final oldIds = _prevUnread.map((e) => e.id).toSet();

      unReadList = data.unread;
      readList = data.read;

      final newOnes =
      unReadList.where((n) => !oldIds.contains(n.id)).toList();

      _prevUnread = List.from(unReadList);

      if (newOnes.isNotEmpty && onNewNotifications != null) {
        onNewNotifications!(newOnes);
      }
    } catch (e) {
      print("fetchUnreadCount error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> markNotificationAsRead({
    required String token,
    required String notificationId,
  }) async {
    try {
      await markReadService.markAsRead(
        notificationId: notificationId,
        token: token,
      );

      MoveUnreadTORead(notificationId);
    } catch (e) {
      print("markNotificationAsRead error: $e");
    }
  }

  void MoveUnreadTORead(String notificationId) {
    final index = unReadList.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;

    final item = unReadList.removeAt(index);
    readList.insert(0, item);

    _prevUnread = List.from(unReadList);

    notifyListeners();
  }
}
