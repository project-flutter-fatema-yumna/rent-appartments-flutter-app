import 'package:flats_app/models/user_data.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
class UserProvider with ChangeNotifier {
  UserData? _user;

  UserData? get user => _user;

  void setUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    _user = UserData(
      phone: prefs.getString('phone') ?? '',
      firstName: prefs.getString('firstName') ?? '',
      lastName: prefs.getString('lastName') ?? '',
      userName: prefs.getString('userName') ?? '',
      dateOfBirth: prefs.getString('dob'),
      role: prefs.getString('role') ?? '',
    );

    final personalPath = prefs.getString('personalPhotoPath');
    if (personalPath != null) {
      _user!.personalPhoto = XFile(personalPath);
    }
    final identityPath = prefs.getString('identityPhotoPath');
    if (identityPath != null) {
      _user!.identityPhoto = XFile(identityPath);
    }
    notifyListeners();
  }

  void clear() {
    _user = null;
    notifyListeners();
  }
}
