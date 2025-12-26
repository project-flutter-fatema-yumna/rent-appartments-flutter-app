import 'package:image_picker/image_picker.dart';

class UserData {
  String phone;
  String password;
  String passwordConfirmation;
  String firstName;
  String lastName;
  String? dateOfBirth;
  String role;
  XFile? identityPhoto;
  XFile? personalPhoto;
  //البيانات الإضافية
  int? id;
  String userName;
  String? status;

  UserData({
    this.phone = '',
    this.password = '',
    this.passwordConfirmation = '',
    this.firstName = '',
    this.lastName = '',
    this.dateOfBirth,
    this.role = '',
    this.identityPhoto,
    this.personalPhoto,
    this.id,
    this.userName = '',
    this.status,
  });
}
