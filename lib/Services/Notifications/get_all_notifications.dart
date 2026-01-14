import 'package:flats_app/API/api.dart';

import '../../models/model_notification.dart';

class get_all_notifications {
  Future<NotificationsResponseModel> getAllNotifications({
    required String token,
  }) async {
    final response = await api().get(
      url: 'http://10.0.2.2:8000/api/notifications',
      token: token,
    );
    return NotificationsResponseModel.fromJson(response);
  }
}
