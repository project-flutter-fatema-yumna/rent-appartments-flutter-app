import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helper/Host.dart';

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

Future<String?> editReservation({
  required int reservationId,
  required String startDate,
  required String endDate,
}) async {
  final token = await getToken();

  final body = {'start_date': startDate, 'end_date': endDate};

  final response = await http.post(
    Uri.parse('http://${Host.host}:8000/api/reservations/$reservationId/edit'),
    headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    body: body,
  );
  print(response.statusCode);

  final data = jsonDecode(response.body);

  if (response.statusCode == 422) {
    print(response.body);
    return 'You do not have enough balance for this \nedit request';
  } else if (response.statusCode != 200 && response.statusCode != 201) {
    return data['message'] ?? 'Something went wrong';
  }
  return null;
}
