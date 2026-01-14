class ModelCurrentChat {
  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String phone;
  final String personalPhoto;
  final int otherUserId;
  final String lastMessageAt;

  ModelCurrentChat({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.phone,
    required this.personalPhoto,
    required this.otherUserId,
    required this.lastMessageAt,
  });

  factory ModelCurrentChat.fromJson(Map<String, dynamic> json) {
    return ModelCurrentChat(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      username: json['username'],
      phone: json['phone'] ?? '',
      personalPhoto: json['personalPhoto'],
      otherUserId: json['other_user_id'],
      lastMessageAt: json['last_message_at'],
    );
  }
}
