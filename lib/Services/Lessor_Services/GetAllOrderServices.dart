import 'package:flats_app/API/api.dart';

import '../../models/model_order.dart';

class getAllOrders{
  Future<List<Modal_Order>> getAllReservation({required String token})async{
    final response = await api().get(
        url: 'http://10.0.2.2:8000/api/lessor/reservations',
        token: token
    );
   //print('the response is $response');

    if (response is List) {
      return response.map((e) => Modal_Order.fromJson(e)).toList();
    }

    if (response is Map && response['data'] is List) {
      final List data = response['data'];
      return data.map((e) => Modal_Order.fromJson(e)).toList();
    }

    throw Exception("Unexpected response format: ${response.runtimeType}");


  }
}