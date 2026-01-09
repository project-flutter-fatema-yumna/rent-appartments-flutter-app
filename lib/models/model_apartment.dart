class Model_Apartment {
  final int id;
  final String governorate;
  final String city;
  final int floor_number,
      balcony_number,
      parking_number,
      rooms_number,
      number_of_bedrooms,
      number_of_baths;
  final bool furnished;
  final double home_space;
  final double home_rate;
  final double rent;
  final String created_at, updated_at;
  final String phone;
  final String? rent_type;
  final List<ApartmentImage> images;
  final ApartmentOwner? owner;


  Model_Apartment({
    required this.id,
    required this.governorate,
    required this.city,
    required this.floor_number,
    required this.balcony_number,
    required this.parking_number,
    required this.rooms_number,
    required this.number_of_bedrooms,
    required this.number_of_baths,
    required this.furnished,
    required this.home_space,
    required this.home_rate,
    required this.rent,
    required this.created_at,
    required this.updated_at,
    required this.phone,
    required this.rent_type,
    required this.images,
    required this.owner
  });

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static bool _toBool01(dynamic v) {
    if (v is bool) return v;
    final s = v?.toString().toLowerCase();
    return s == '1' || s == 'true';
  }

  factory Model_Apartment.fromJson(Map<String, dynamic> json) {
    return Model_Apartment(
      id: _toInt(json['id']),
      governorate: json['governorate']?.toString() ?? '',
      city: json['city']?.toString() ?? '',

      floor_number: _toInt(json['floor_number']),
      balcony_number: _toInt(json['balcony_number']),
      parking_number: _toInt(json['parking_number']),
      rooms_number: _toInt(json['rooms_number']),
      number_of_bedrooms: _toInt(json['number_of_bedrooms']),
      number_of_baths: _toInt(json['number_of_baths']),

      furnished: _toBool01(json['furnished']),
      home_space: _toDouble(json['home_space']),
      home_rate: _toDouble(json['home_rate']),
      rent: _toDouble(json['rent']),

      created_at: json['created_at']?.toString() ?? '',
      updated_at: json['updated_at']?.toString() ?? '',
      phone: (json['user']?['phone'])?.toString() ?? '',
      rent_type: json['rent_type']?.toString(),

      //rent_type: json['rent_type'] ?? '',
      images: (json['images'] as List? ?? [])
          .map((item) => ApartmentImage.fromJson(item as Map<String, dynamic>))
          .toList(),
      owner: json['user'] != null ? ApartmentOwner.fromJson(json['user']) : null,

    );
  }
}

class ApartmentOwner {
  final int id;
  final String username;
  final String phone;

  ApartmentOwner({required this.id, required this.username,required this.phone});

  factory ApartmentOwner.fromJson(Map<String, dynamic> json) {
    return ApartmentOwner(
      id: int.tryParse(json['id'].toString()) ?? 0,
      username: json['username']?.toString() ?? '',
        phone:json['phone']?.toString()?? '',
    );
  }
}


class ApartmentImage {
  final int id;
  final int apartmentId;
  final String image;
  final String createdAt;
  final String updatedAt;

  ApartmentImage({
    required this.id,
    required this.apartmentId,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  factory ApartmentImage.fromJson(Map<String, dynamic> json) {
    return ApartmentImage(
      id: _toInt(json['id']),
      apartmentId: _toInt(json['apartment_id']),
      image: json['image']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}
