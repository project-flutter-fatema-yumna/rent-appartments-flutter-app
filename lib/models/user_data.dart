import 'package:image_picker/image_picker.dart';

class UserData {
  String phone;
  String password;
  String passwordConfirmation;
  String firstName;
  String lastName;
  String? dateOfBirth;
  String role;

  XFile? personalPhoto;
  XFile? identityPhoto;
  //البيانات الإضافية
  int? id;
  String userName;
  String? status;
  String? personalPhotoUrl;
  String? identityPhotoUrl;

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

  static Future<UserData> fromJson(Map<String, dynamic> json) async {
    UserData user = UserData(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      userName: json['username'] ?? '',
      phone: json['phone'] ?? '',
      dateOfBirth: json['date_of_birth'],
      role: json['role'] ?? '',
      status: json['state'],
    );

    user.personalPhotoUrl = json['personalPhoto'] != null
        ? 'http://10.0.2.2:8000/storage/${json['personalPhoto']}'
        : null;

    user.identityPhotoUrl = json['idenitityPhoto'] != null
        ? 'http://10.0.2.2:8000/storage/${json['idenitityPhoto']}'
        : null;
    return user;
  }
}
