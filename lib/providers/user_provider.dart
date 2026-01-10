import 'package:flats_app/models/user_data.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  UserData? _user;

  UserData? get user => _user;

  Future<void> setUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    _user = UserData(
      phone: prefs.getString('phone') ?? '',
      firstName: prefs.getString('firstName') ?? '',
      lastName: prefs.getString('lastName') ?? '',
      userName: prefs.getString('userName') ?? '',
      dateOfBirth: prefs.getString('dob'),
      role: prefs.getString('role') ?? '',
    );

    _user!.personalPhotoUrl = prefs.getString('personalPhotoUrl');
    _user!.identityPhotoUrl = prefs.getString('identityPhotoUrl');
print("photos from provider");
    print(_user!.personalPhotoUrl);
    print(_user!.identityPhotoUrl);
    print('////////////////');
    notifyListeners();
  }

  void clear() {
    _user = null;
    notifyListeners();
  }
}
