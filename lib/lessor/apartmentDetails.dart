import 'package:flutter/material.dart';
import 'package:flats_app/models/model_apartment.dart';

class ApartmentDetailsSheet extends StatefulWidget {
  static const String id = 'ApartmentDetailsSheet';

  final Model_Apartment apartment;

  const ApartmentDetailsSheet({
    required this.apartment,
  });

  @override
  State<ApartmentDetailsSheet> createState() => _ApartmentDetailsSheetState();

  static Widget _info(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
      ],
    );
  }

  static Widget _line(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
        ],
      ),
    );
  }
}

class _ApartmentDetailsSheetState extends State<ApartmentDetailsSheet> {
  int numberImage = 0;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            /*  Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      width: double.infinity,
                      height: 300,
                      child: PageView.builder(
                        onPageChanged: (index) {
                          setState(() => numberImage = index);
                        },
                        itemCount: widget.apartment.images.length,
                        itemBuilder: (context, index) {
                          final path = widget.apartment.images[index].image.trim();
                          final url = 'http://10.0.2.2:8000/storage/$path';

                          return Image.network(
                            url,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stack) {
                              print("IMG ERROR: $error\nURL: $url");
                              return const Center(child: Icon(Icons.broken_image, size: 40));
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(widget.apartment.images.length, (
                          index,
                          ) {
                        return Padding(
                          padding: const EdgeInsets.all(2),
                          child: Container(
                            width: numberImage == index ? 12 : 8,
                            height: numberImage == index ? 12 : 8,
                            decoration: BoxDecoration(
                              color: numberImage == index
                                  ? Colors.blue
                                  : Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),*/

              SizedBox(height: 10,),
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),

              Text(
                "${widget.apartment.governorate} - ${widget.apartment.city}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),

              Text(
                "\$ ${widget.apartment.rent} - ${widget.apartment.rent_type}",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ApartmentDetailsSheet._info("Rooms", widget.apartment.rooms_number.toString()),
                  ApartmentDetailsSheet._info("Beds", widget.apartment.number_of_bedrooms.toString()),
                  ApartmentDetailsSheet._info("Baths", widget.apartment.number_of_baths.toString()),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ApartmentDetailsSheet._info("Floor", widget.apartment.floor_number.toString()),
                  ApartmentDetailsSheet._info("Balcony", widget.apartment.balcony_number.toString()),
                  ApartmentDetailsSheet._info("Parking", widget.apartment.parking_number.toString()),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(),

              ApartmentDetailsSheet._line("Space", "${widget.apartment.home_space} m²"),
              const SizedBox(height: 6),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Furnished",
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        widget.apartment.furnished == 1 ? Icons.check : Icons.close,
                        color: widget.apartment.furnished == 1 ? Colors.green : Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.apartment.furnished == 1 ? "Yes" : "No",
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text("Close"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
