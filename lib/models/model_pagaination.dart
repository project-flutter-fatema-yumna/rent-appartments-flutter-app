import 'model_apartment.dart';

class model_page {
  final int currentPage;
  final List<Model_Apartment> data;
  final String? nextPageUrl;
  final String? previousPageUrl;
  final String? lastPageUrl;

  model_page({
    required this.currentPage,
    required this.data,
    required this.nextPageUrl,
    required this.previousPageUrl,
    required this.lastPageUrl,
  });

  factory model_page.fromJson(Map<String, dynamic> json) {
    return model_page(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List)
          .map((e) => Model_Apartment.fromJson(e))
          .toList(),
      nextPageUrl: json['next_page'],
      previousPageUrl: json['previous_page'],
      lastPageUrl: json['last_page'],
    );
  }
}
