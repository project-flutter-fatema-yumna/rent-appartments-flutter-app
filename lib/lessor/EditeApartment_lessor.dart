import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flats_app/MyColors.dart';
import 'package:flats_app/Services/Lessor_Services/Delete_Apartment_Lessor/deleteImage.dart';
import 'package:flats_app/models/model_apartment.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditeapartmentLessor extends StatefulWidget {
  static String id = "EditeapartmentLessor";

  @override
  State<EditeapartmentLessor> createState() => _EditeapartmentLessorState();
}

class _EditeapartmentLessorState extends State<EditeapartmentLessor> {
  late Model_Apartment model_apartment;
  int numberImage = 0;

  final governorate = TextEditingController();
  final city = TextEditingController();
  final homeSpace = TextEditingController();
  final rent = TextEditingController();
  int? numberFloor,
      numberBaths,
      numberRoom,
      numberBedRoom,
      numberParking,
      numberBalcony;
  String? rentType;
  bool? isFurnished;

  List<XFile> photos = [];
  final _formKey = GlobalKey<FormState>();

  final ImagePicker _picker = ImagePicker();
  Future<void> pickFromGallery() async {
    final List<XFile>? picked = await _picker.pickMultiImage(imageQuality: 80);

    if (picked == null || picked.isEmpty) return;

    setState(() {
      photos.addAll(picked);
    });
  }

  Future<void> pickFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() {
      photos.add(image);
    });
  }

  void showPickSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.blue),
                  title: const Text('Camera'),
                  onTap: () async {
                    Navigator.pop(context);
                    await pickFromCamera();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.green),
                  title: const Text('Gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    await pickFromGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<String, String> buildApartmentFields() {
    return {
      "governorate": governorate.text.trim(),
      "city": city.text.trim(),
      "home_space": homeSpace.text.trim(),
      "rent": rent.text.trim(),

      "floor_number": numberFloor.toString(),
      "balcony_number": numberBalcony.toString(),
      "parking_number": numberParking.toString(),
      "rooms_number": numberRoom.toString(),
      "number_of_bedrooms": numberBedRoom.toString(),
      "number_of_baths": numberBaths.toString(),

      "furnished": isFurnished == true ? "1" : "0",
      "rent_type": rentType.toString(),
    };
  }

  List<File> getImageFiles() {
    return photos.map((x) => File(x.path)).toList();
  }

  void clearForm() {
    _formKey.currentState?.reset();
    governorate.clear();
    city.clear();
    homeSpace.clear();
    rent.clear();

    numberFloor = null;
    numberBaths = null;
    numberRoom = null;
    numberBedRoom = null;
    numberParking = null;
    numberBalcony = null;
    rentType = null;
    isFurnished = null;

    photos.clear();

    setState(() {});
  }

  List<int> numbers = List.generate(11, (index) => index);
  List<String> typs = ['daily', 'monthly', 'yearly'];

  @override
  void dispose() {
    governorate.dispose();
    city.dispose();
    rent.dispose();
    homeSpace.dispose();
    super.dispose();
  }

  Widget imageActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.85),
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.blue, size: 25),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    model_apartment =
        ModalRoute.of(context)!.settings.arguments as Model_Apartment;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edite Apartment', style: TextStyle(color: Colors.white)),
        elevation: 5,
        centerTitle: true,
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: myColors.colorWhite,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Column(
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 350,
                        child: PageView.builder(
                          onPageChanged: (index) {
                            setState(() {
                              numberImage = index;
                            });
                          },
                          itemCount: model_apartment.images.length,
                          itemBuilder: (context, index) {
                            final path = model_apartment.images[index].image
                                .trim();
                            final url = 'http://10.0.2.2:8000/storage/$path';
                            return Image.network(
                              url,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (context, error, stack) {
                                print("IMG ERROR: $error\nURL: $url");
                                return const Center(
                                  child: Icon(Icons.broken_image, size: 40),
                                );
                              },
                            );
                            /*CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        placeholder: (c, _) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (c, _, __) => const Icon(Icons.broken_image),
                      );*/
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 30,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            model_apartment.images.length,
                            (index) {
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
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 30,
                        right: 12,
                        child: imageActionButton(
                          icon: Icons.add_a_photo_outlined,
                          onTap: () {},
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: imageActionButton(
                          icon: Icons.close,
                          onTap: () {

                          },
                        ),
                      ),
                    ],
                  ),
                  Transform.translate(
                    offset: Offset(0, -20),
                    child: Container(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: governorate,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.account_balance),
                              filled: true,
                              fillColor: Colors.white,
                              labelText: 'governorate Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              // labelText: 'City',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Governorate is required';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15),
                          TextFormField(
                            controller: city,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.location_on),
                              filled: true,
                              fillColor: Colors.white,
                              labelText: 'city Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              // labelText: 'City',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'City is required';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15),
                          TextFormField(
                            controller: homeSpace,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.square_foot),
                              filled: true,
                              fillColor: Colors.white,
                              labelText: 'home space',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              // labelText: 'City',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Home space is required';
                              }
                              final space = double.tryParse(value);
                              if (space == null || space <= 0) {
                                return 'Enter a valid space';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField2<int>(
                                  value: numberFloor,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    labelText: 'Floor',
                                    prefixIcon: Icon(Icons.meeting_room),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 200,
                                    width: 70,
                                    offset: Offset(105, 20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  items: numbers.map((num) {
                                    return DropdownMenuItem<int>(
                                      value: num,
                                      child: Text(num.toString()),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      numberFloor = value;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField2<int>(
                                  value: numberBaths,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    labelText: 'Baths',
                                    prefixIcon: Icon(Icons.bathtub),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 200,
                                    width: 70,
                                    offset: Offset(105, 20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  items: numbers.map((num) {
                                    return DropdownMenuItem<int>(
                                      value: num,
                                      child: Text(num.toString()),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      numberBaths = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField2<int>(
                                  value: numberRoom,
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Select rooms';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() => numberRoom = value);
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    labelText: 'Rooms',
                                    prefixIcon: Icon(
                                      Icons.meeting_room_outlined,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 200,
                                    width: 70,
                                    offset: Offset(105, 20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  items: numbers.map((num) {
                                    return DropdownMenuItem<int>(
                                      value: num,
                                      child: Text(num.toString()),
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField2<int>(
                                  value: numberBedRoom,
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Select BedRooms';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() => numberBedRoom = value);
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    labelText: 'BedRooms',
                                    prefixIcon: Icon(Icons.bed_rounded),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 200,
                                    width: 70,
                                    offset: Offset(105, 20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  items: numbers.map((num) {
                                    return DropdownMenuItem<int>(
                                      value: num,
                                      child: Text(num.toString()),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField2<int>(
                                  value: numberParking,
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Select Parking';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() => numberParking = value);
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    labelText: 'Parking',
                                    prefixIcon: Icon(Icons.car_crash),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 200,
                                    width: 70,
                                    offset: Offset(105, 20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  items: numbers.map((num) {
                                    return DropdownMenuItem<int>(
                                      value: num,
                                      child: Text(num.toString()),
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField2<int>(
                                  value: numberBalcony,
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Select Balcony';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() => numberBalcony = value);
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    labelText: 'Balcony',
                                    prefixIcon: Icon(Icons.balcony),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 200,
                                    width: 70,
                                    offset: Offset(105, 20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  items: numbers.map((num) {
                                    return DropdownMenuItem<int>(
                                      value: num,
                                      child: Text(num.toString()),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          TextFormField(
                            controller: rent,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.attach_money,
                                color: Colors.green.shade500,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              labelText: 'Rent',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              // labelText: 'City',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Rent is required';
                              }
                              final rentValue = double.tryParse(value);
                              if (rentValue == null || rentValue <= 0) {
                                return 'Enter a valid rent';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                ///month//year//day....
                                child: DropdownButtonFormField2<String>(
                                  value: rentType,
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Select rooms';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() => rentType = value);
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    labelText: 'Rent Type',
                                    prefixIcon: Icon(Icons.calendar_month),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 200,
                                    width: 100,
                                    offset: Offset(105, 20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  items: typs.map((type) {
                                    return DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(type.toString()),
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField2<bool>(
                                  value: isFurnished,
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Select is Furnished';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() => isFurnished = value);
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    labelText: 'Furnished',
                                    prefixIcon: Icon(Icons.chair),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 200,
                                    width: 70,
                                    offset: Offset(105, 20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: true,
                                      child: Text('Yes'),
                                    ),
                                    DropdownMenuItem(
                                      value: false,
                                      child: Text('No'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          InkWell(
                            onTap: showPickSourceSheet,
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.add_a_photo_outlined,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      photos.isEmpty
                                          ? 'Add photos (min 3)'
                                          : 'Add more photos',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.black45,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          if (photos.isNotEmpty)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: photos.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 8,
                                    crossAxisSpacing: 8,
                                  ),
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        File(photos[index].path),
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            photos.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          SizedBox(height: 20),
                          SafeArea(
                            child: InkWell(
                              onTap: () {},
                              child: Container(
                                height: 50,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'Publish',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
