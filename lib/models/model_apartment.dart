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
  final String created_at, updated_at;
  final List<ApartmentImage> images;
  //final double rent;

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
    required this.created_at,
    required this.updated_at,
    required this.images,
    //required this.rent
  });
  factory Model_Apartment.fromJson(Map<String, dynamic> json) {
    return Model_Apartment(
      id: json['id'],
      governorate: json['governorate'],
      city: json['city'],
      floor_number: json['floor_number'],
      balcony_number: json['balcony_number'],
      parking_number: json['parking_number'],
      rooms_number: json['rooms_number'],
      number_of_bedrooms: json['number_of_bedrooms'],
      number_of_baths: json['number_of_baths'],
      furnished: json['furnished'].toString()=='1',
      home_space: json['home_space'].toDouble(),
      home_rate: json['home_rate'].toDouble(),
      created_at: json['created_at'],
      updated_at: json['updated_at'],
      images: (json['images'] as List)
          .map((item) => ApartmentImage.fromJson(item))
          .toList(),
      //rent: json['rent']
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
  factory ApartmentImage.fromJson(Map<String, dynamic> JsonData) {
    return ApartmentImage(
      id: JsonData['id'],
      apartmentId: JsonData['apartment_id'],
      image: JsonData['image'],
      createdAt: JsonData['created_at'],
      updatedAt: JsonData['updated_at'],

    );
  }

}
