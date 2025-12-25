import 'dart:convert';
import 'package:flats_app/models/filter_criteria.dart';
import 'package:flats_app/models/model_apartment.dart';
import 'package:flats_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

Future<List<Model_Apartment>> getFilteredApartments(
  FilterCriteria filters,
  BuildContext context,
) async {
  try {
    final uri = Uri.parse('http://10.0.2.2:8000/api/apartment/filter').replace(
      queryParameters: filters.toJson().map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${context.read<UserProvider>().token?? 'test_token'}',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List apartmentsJson = json['apartments'];
      return apartmentsJson.map((e) => Model_Apartment.fromJson(e)).toList();
    } else {
      print(response.statusCode);
      throw Exception('Failed to load apartments');
    }
  } catch (e) {
    rethrow;
  }
}
