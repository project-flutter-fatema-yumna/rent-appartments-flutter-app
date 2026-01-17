import 'dart:convert';
import 'package:flats_app/models/model_order.dart';
import 'package:http/http.dart' as http;

import '../helper/Host.dart';

Future<List<Modal_Order>> getMyReservations({
  String? status,
  required String token,
}) async {
   String baseUrl = 'http://${Host.host}:8000/api/tenant/reservations';
  Uri url = Uri.parse(baseUrl);

  if (status != null && status.isNotEmpty) {
    url = Uri.parse('$baseUrl?status=$status');
  }

  final response = await http.get(
    url,
    headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
  );
  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);
    return Modal_Order.listFromJson(decoded['data']);
  } else {
    throw Exception('Failed to load reservations (${response.statusCode})');
  }
}
