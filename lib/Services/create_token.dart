import 'dart:convert';

import 'package:http/http.dart' as http;

Future<String> createToken(String phone) async {
  final response = await http.post(
    Uri.parse('http://10.0.2.2:8000/api/user/token'),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    body: jsonEncode({'phone': phone}),
  );
  final jsonData = jsonDecode(response.body);
  print(response.statusCode);
  if (response.statusCode == 200||response.statusCode==201) {
    return jsonData['token'];
  } else {
    throw Exception(jsonData['message'] ?? 'Failed to create token');
  }
}
