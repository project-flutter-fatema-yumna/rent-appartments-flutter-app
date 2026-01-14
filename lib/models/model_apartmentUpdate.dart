class model_apartmentUpdate {
  final String message;
  final ApartmentAfterUpdate apartment;

  model_apartmentUpdate({
    required this.message,
    required this.apartment,
  });

  factory model_apartmentUpdate.fromJson(Map<String, dynamic> json) {
    return model_apartmentUpdate(
      message: (json['message'] ?? '').toString(),
      apartment: ApartmentAfterUpdate.fromJson(
        (json['apartment after update'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }
}

class ApartmentAfterUpdate {
  final int id;
  final String governorate;
  final String city;
  final int floorNumber;
  final int balconyNumber;
  final int parkingNumber;
  final int roomsNumber;
  final int bedrooms;
  final int baths;
  final int furnished;
  final double homeSpace;
  final double homeRate;
  final double rent;
  final String rentType;
  final String createdAt;
  final String updatedAt;

  ApartmentAfterUpdate({
    required this.id,
    required this.governorate,
    required this.city,
    required this.floorNumber,
    required this.balconyNumber,
    required this.parkingNumber,
    required this.roomsNumber,
    required this.bedrooms,
    required this.baths,
    required this.furnished,
    required this.homeSpace,
    required this.homeRate,
    required this.rent,
    required this.rentType,
    required this.createdAt,
    required this.updatedAt,
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

  factory ApartmentAfterUpdate.fromJson(Map<String, dynamic> json) {
    return ApartmentAfterUpdate(
      id: _toInt(json['id']),
      governorate: (json['governorate'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      floorNumber: _toInt(json['floor_number']),
      balconyNumber: _toInt(json['balcony_number']),
      parkingNumber: _toInt(json['parking_number']),
      roomsNumber: _toInt(json['rooms_number']),
      bedrooms: _toInt(json['number_of_bedrooms']),
      baths: _toInt(json['number_of_baths']),
      furnished: _toInt(json['furnished']),
      homeSpace: _toDouble(json['home_space']),
      homeRate: _toDouble(json['home_rate']),
      rent: _toDouble(json['rent']),
      rentType: (json['rent_type'] ?? '').toString(),
      createdAt: (json['created_at'] ?? '').toString(),
      updatedAt: (json['updated_at'] ?? '').toString(),
    );
  }
}
