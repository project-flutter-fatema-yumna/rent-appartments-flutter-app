
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class api{
  Future<dynamic> get({required String url,String? token}) async{
    http.Response response =await http.get(Uri.parse(url),headers: {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    //print("URL: $url");
    //print("STATUS: ${response.statusCode}");
    //print("BODY: ${response.body}");
    if(response.statusCode==200){
      return jsonDecode(response.body);
    }
    else{
      throw Exception(
        'there is a problem with status Code ${response.statusCode}',
      );
    }
  }


  ///post
  Future<dynamic> post({
    required String url,
    required Map<String, dynamic> body,
    String? token,
  }) async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    print("URL: $url");
      print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Error ${response.statusCode}: ${response.body}',
      );
    }
  }
///post for reserve apartment
  Future<dynamic> postFormData({
    required String url,
    required Map<String, String> body,
    String? token,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(url));

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    print("TOKEN => $token");


    request.headers['Accept'] = 'application/json';

    request.fields.addAll(body);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print("URL: $url");
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = null;
      }

      String msg = 'Request failed';

      if (decoded is Map) {
        if (decoded['message'] != null) msg = decoded['message'].toString();

        if (decoded['errors'] is Map) {
          final errors = decoded['errors'] as Map;
          if (errors.isNotEmpty) {
            final firstKey = errors.keys.first;
            final firstVal = errors[firstKey];
            if (firstVal is List && firstVal.isNotEmpty) {
              msg = firstVal.first.toString();
            }
          }
        }
      } else if (response.body.isNotEmpty) {
        msg = response.body;
      }

      throw Exception('${response.statusCode}|${response.body}');
    }

  }



//for store apartment
  Future<dynamic> postApartment({
    required String url,
    required Map<String, String> fields,
    required List<File> images,
    String? token,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(url));
    // headers
    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    // text fields
    request.fields.addAll(fields);
    // images
    for (File image in images) {
      request.files.add(
        await http.MultipartFile.fromPath('images[]', image.path),
      );
    }
    // send
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    //print('STATUS: ${response.statusCode}');
    //print('BODY: $responseBody');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(responseBody);
    } else {
      throw Exception('Error ${response.statusCode}: $responseBody');
    }
  }

  Future<dynamic> patch({required String url, String? token})async{
    final headers={
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final response =await http.patch(Uri.parse(url),headers: headers);
    print("URL: $url");
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if(response.statusCode==200 || response.statusCode==201){
     return  response.body.isEmpty?{}: jsonDecode(response.body);
    }else{
      throw Exception("Error ${response.statusCode}");
    }
  }


  ///Del
  Future<dynamic> delete({required String url,String? token})async{
    final headers={
      "Accept":'application/json',
      if(token!=null) 'Authorization': 'Bearer $token',
    };
    final response =await http.delete(Uri.parse(url),headers: headers);

    print("DELETE status: ${response.statusCode}");
    print("DELETE body: ${response.body}");
    if(response.statusCode==200 || response.statusCode==201){
      if(response.body.isEmpty)
        return null;
      try{
        return jsonDecode(response.body);
      }catch(_){
        return response.body;
      }
    }else{
      throw Exception("Error ${response.statusCode}");
    }
  }
  ////put
  Future<dynamic> put({required String url ,String? token})async
  {
    final headers={
      "Accept":'application/json',
      if(token!=null) 'Authorization': 'Bearer $token',
    };
    final response =await http.put(Uri.parse(url),headers: headers);
    print("PUT status: ${response.statusCode}");
    print("PUT body: ${response.body}");
    if(response.statusCode==200 || response.statusCode==201){
      return jsonDecode(response.body);
    }
    else{
      throw Exception("Error ${response.statusCode}");
    }
  }

  
}