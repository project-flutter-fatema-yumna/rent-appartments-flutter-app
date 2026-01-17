import 'package:http/http.dart' as http;

import '../helper/Host.dart';

Future<void> cancelReservation({
  required int reservationId,
  required String token,
}) async {
  final url = Uri.parse(
    'http://${Host.host}:8000/api/reservations/$reservationId/cancel',
  );

  final response = await http.patch(
    url,
    headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to cancel reservation');
  }
}

