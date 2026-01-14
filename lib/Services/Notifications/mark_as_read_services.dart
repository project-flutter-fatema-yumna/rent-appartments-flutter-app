import 'package:flats_app/API/api.dart';

class mark_as_read {
  Future<void> markAsRead({
    required String notificationId,
    required String token,
  }) async {
    await api().post(url: 'http://10.0.2.2:8000/api/notifications/${notificationId}/read',token: token );
  }
}
