import 'package:flats_app/API/api.dart';
import 'package:flats_app/models/model_current_chat.dart';

import '../../helper/Host.dart';

class GetCurrentChatsService {
  Future<List<ModelCurrentChat>> getCurrentChats({
    required String token,
  }) async {
    final result = await api().get(
      url: 'http://${Host.host}:8000/api/lessor/getCurrentChats',
      token: token,
    );
    if (result is List) {
      return result
          .map((item) => ModelCurrentChat.fromJson(item))
          .toList();
    } else {
      throw Exception('Unexpected response format');
    }
  }
}
