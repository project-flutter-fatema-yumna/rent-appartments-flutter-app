import 'package:flats_app/API/api.dart';

import '../../helper/Host.dart';

class postChatSevices {
  Future<dynamic> postMessage({
    required String token,
    required int desId,
    required String content,
  }) async {
    final response = await api().postFormData(
      url: 'http://${Host.host}:8000/api/user/sendMessage/${desId}',
      body: {"content": content},
      token: token,
    );
    return response;
  }
}
