import 'package:flats_app/API/api.dart';

import '../../helper/Host.dart';

class getChatSevices {
  Future<dynamic> getMessage({
    required String token,
    required int srcId,
  }) async {
    final response = await api().get(
      url: 'http://${Host.host}:8000/api/user/getChat/${srcId}',
      token: token,
    );
    return response;
  }
}
