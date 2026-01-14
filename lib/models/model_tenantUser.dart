class Model_tenant {
  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String phone;
  final String? personalPhoto;

  Model_tenant({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.phone,
    this.personalPhoto,
  });

  factory Model_tenant.fromJson(Map<String, dynamic> json) {
    return Model_tenant(
      id: json["id"],
      firstName: json["first_name"] ?? "",
      lastName: json["last_name"] ?? "",
      username: json["username"] ?? "",
      phone: json["phone"] ?? "",
      personalPhoto: json["personalPhoto"],
    );
  }

  String get fullName => "${firstName.trim()} ${lastName.trim()}".trim();
}
