import 'dart:convert';
import 'package:http/http.dart' as http;

import '../helper/Host.dart';

class WalletRequestService {
  Future<Map<String, dynamic>> sendRequest({
    required String token,
    required double amount,
    String type = 'add',
  }) async {
    final url = Uri.parse('http://${Host.host}:8000/api/wallet/request')
        .replace(queryParameters: {
      'amount': amount.toStringAsFixed(0),
      'type': type,
    });

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body.isEmpty ? {} : jsonDecode(response.body);
    }

    throw Exception('${response.statusCode}|${response.body}');
  }
}
