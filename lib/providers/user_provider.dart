import 'package:flats_app/models/user_data.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  UserData? _user;
  UserData get getUserData => _user!;

  get token => null;
  void setUserData(UserData user) {
    _user = user;
    notifyListeners();
  }
}
