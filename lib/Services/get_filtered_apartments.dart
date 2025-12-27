import 'dart:convert';
import 'package:flats_app/models/filter_criteria.dart';
import 'package:flats_app/models/model_apartment.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization':
            'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List apartmentsJson = json['apartments'];
      return apartmentsJson.map((e) => Model_Apartment.fromJson(e)).toList();
    } else {
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to load apartments');
    }
  } catch (e) {
    rethrow;
  }
}
