class FilterCriteria {
  String? governorate;
  String? city;
  bool? furnished;
  int? rooms;
  int? bedrooms;
  int? baths;
  int? floor;
  int? balcony;
  int? parking;
  double? space;
  double? rent;
  double? rate;

  Map<String, dynamic> toJson() {
    final data = {
      'governorate': governorate,
      'city': city,
      'floor_number': floor,
      'balcony_number': balcony,
      'parking_number': parking,
      'rooms_number': rooms,
      'number_of_bedrooms': bedrooms,
      'number_of_baths': baths,
      'furnished': furnished == null ? null : (furnished! ? 1 : 0),
      'home_space': space,
      'rent': rent,
      'home_rate': rate,
    };

    data.removeWhere((key, value) => value == null || value == -1);
    return data;
  }

  bool isFiltered() {
    return (governorate == null &&
        city == null &&
        floor == null &&
        balcony == null &&
        parking == null &&
        rooms == null &&
        bedrooms == null &&
        baths == null &&
        furnished == null &&
        rent == null &&
        rate == null);
  }
}
