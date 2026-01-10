import 'dart:io';

import 'package:flats_app/models/user_data.dart';
import 'package:flutter/material.dart';

Widget personalImage(UserData user, double radius) {
  print('file:------${user.personalPhoto}');
  print('url:------${user.personalPhotoUrl}');
  if (user.personalPhoto != null) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: FileImage(File(user.personalPhoto!.path)),
    );
  }

  if (user.personalPhotoUrl != null) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(user.personalPhotoUrl!),
    );
  }

  return CircleAvatar(radius: radius, child: Icon(Icons.person));
}
