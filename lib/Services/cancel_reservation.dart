import 'package:http/http.dart' as http;

Future<void> cancelReservation({
  required int reservationId,
  required String token,
}) async {
  final url = Uri.parse(
    'http://10.0.2.2:8000/api/reservations/$reservationId/cancel',
  );

  final response = await http.patch(
    url,
    headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to cancel reservation');
  }
}

