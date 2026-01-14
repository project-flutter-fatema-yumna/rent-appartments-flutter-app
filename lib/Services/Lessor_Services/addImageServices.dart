import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flats_app/API/api.dart';

class addImageServices{
  Future<dynamic> addImage({required String apartmentId,required File image,required String token})async{
    final url='http://10.0.2.2:8000/api/apartment/addImage/$apartmentId';
    final request=http.MultipartRequest('POST',Uri.parse(url));

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    request.files.add(
      await http.MultipartFile.fromPath('images[]', image.path),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(body);
    } else {
      throw Exception('Error ${response.statusCode}: $body');
    }

  }
}