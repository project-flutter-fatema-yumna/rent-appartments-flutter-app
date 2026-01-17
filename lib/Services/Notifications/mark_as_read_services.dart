import 'package:flats_app/API/api.dart';

import '../../helper/Host.dart';

class mark_as_read {
  Future<void> markAsRead({
    required String notificationId,
    required String token,
  }) async {
    await api().post(url: 'http://${Host.host}:8000/api/notifications/${notificationId}/read',token: token );
  }
}
