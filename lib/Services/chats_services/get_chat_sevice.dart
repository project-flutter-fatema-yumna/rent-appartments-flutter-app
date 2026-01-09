import 'package:flats_app/API/api.dart';

class getChatSevices {
  Future<dynamic> getMessage({
    required String token,
    required int srcId,
  }) async {
    final response = await api().get(
      url: 'http://10.0.2.2:8000/api/user/getChat/${srcId}',
      token: token,
    );
    return response;
  }
}
