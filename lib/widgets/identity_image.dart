import 'dart:io';

import 'package:flats_app/models/user_data.dart';
import 'package:flutter/material.dart';

Widget identityImage(UserData user) {
  ImageProvider? image;
  if (user.identityPhoto != null) {
    image = FileImage(File(user.identityPhoto!.path));
  } else if (user.identityPhotoUrl != null) {
    image = NetworkImage(user.identityPhotoUrl!);
  }
  print('file:------${user.identityPhoto}');
  print('url:------${user.identityPhotoUrl}');
  return Container(
    height: 180,
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black, width: 1.5),
      image: image != null
          ? DecorationImage(image: image, fit: BoxFit.cover)
          : null,
    ),
    child: image == null
        ? const Center(child: Icon(Icons.image, size: 50))
        : null,
  );
}
