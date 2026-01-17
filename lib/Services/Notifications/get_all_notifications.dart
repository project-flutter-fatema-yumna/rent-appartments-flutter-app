import 'package:flats_app/API/api.dart';

import '../../helper/Host.dart';
import '../../models/model_notification.dart';

class get_all_notifications {
  Future<NotificationsResponseModel> getAllNotifications({
    required String token,
  }) async {
    final response = await api().get(
      url: 'http://${Host.host}:8000/api/notifications',
      token: token,
    );
    return NotificationsResponseModel.fromJson(response);
  }
}
