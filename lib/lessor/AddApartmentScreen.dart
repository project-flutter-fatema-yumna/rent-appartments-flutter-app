import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../Services/Lessor_Services/add_Apartment.dart';
import 'ListApartmentScreen.dart';

class addApartmentScreen extends StatefulWidget {
  static String id = 'addApartmentScreen';

  @override
  State<addApartmentScreen> createState() => _addApartmentScreenState();
}

class _addApartmentScreenState extends State<addApartmentScreen> {
 final governorate=TextEditingController();
 final city=TextEditingController();
 final homeSpace=TextEditingController();
 final rent=TextEditingController();
 int? numberFloor,
      numberBaths,
      numberRoom,
      numberBedRoom,
      numberParking,
      numberBalcony;
 String? rentType;
bool? isFurnished;

List<XFile> photos=[];

 final _formKey = GlobalKey<FormState>();
 ////images
 final ImagePicker _picker = ImagePicker();
 Future<void> pickFromGallery() async {
   final List<XFile>? picked = await _picker.pickMultiImage(
     imageQuality: 80,
   );

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
                 leading: const Icon(Icons.camera_alt,color: Colors.blue,),
                 title: const Text('Camera'),
                 onTap: () async {
                   Navigator.pop(context);
                   await pickFromCamera();
                 },
               ),
               ListTile(
                 leading: const Icon(Icons.photo_library,color: Colors.green,),
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

 Map<String,String> buildApartmentFields(){
   return {
     "governorate": governorate.text.trim(),
     "city": city.text.trim(),
     "home_space": homeSpace.text.trim(),
     "rent": rent.text.trim(),
     ///

     "floor_number": numberFloor.toString(),
     "balcony_number": numberBalcony.toString(),
     "parking_number": numberParking.toString(),
     "rooms_number": numberRoom.toString(),
     "number_of_bedrooms": numberBedRoom.toString(),
     "number_of_baths": numberBaths.toString(),

     "furnished":isFurnished==true?"1":"0",
     "rent_type": rentType.toString(),
   };
 }

 List<File> getImageFiles() {
   return photos.map((x) => File(x.path)).toList();
 }

 Future<void> publishApartment() async {
   try {
     final fields = buildApartmentFields();
     final images = getImageFiles();

     final response =await addApartment().storeApartment(
       token: '9|c3hNZQ6edWTejdujij2NCDd5cxuva6seMemvBknc79b62022',
       data: fields,
       images: images,
     );
     print('ADD APARTMENT RESPONSE: $response');
///screen not found
     if (!mounted) return;
     clearForm();
     showSuccessSheet();
   } catch (e) {
     if (!mounted) return;
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Error: $e')),
     );
   }
 }

 void clearForm(){
   _formKey.currentState?.reset();
   governorate.clear();
   city.clear();
   homeSpace.clear();
   rent.clear();

   numberFloor=null;
   numberBaths=null;
   numberRoom=null;
   numberBedRoom=null;
   numberParking=null;
   numberBalcony=null;
   rentType=null;
   isFurnished=null;

   photos.clear();

   setState(() {
   });
 }

 List<int> numbers = List.generate(11, (index) => index);
 List<String> typs=['daily','monthly','yearly'];
 bool isPublishing = false;

 @override
 void dispose() {
  governorate.dispose();
  city.dispose();
  rent.dispose();
  homeSpace.dispose();
  super.dispose();
 }

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            children: [
              Icon(Icons.add_home_work_outlined,size: 100,color: Colors.blue,),
              SizedBox(height: 4),
              Text(
                'Add your apartment',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6),
              Text(
                'Fill the details below to publish your listing',
                style: TextStyle(color: Colors.black54,fontSize: 16),
              ),
              SizedBox(height: 20),
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
                        prefixIcon: Icon(Icons.meeting_room_outlined),
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
                  prefixIcon: Icon(Icons.attach_money,color: Colors.green.shade500,),
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
                    child:DropdownButtonFormField2<bool>(
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
                        DropdownMenuItem(value: true, child: Text('Yes')),
                        DropdownMenuItem(value: false, child: Text('No')),
                      ],
                    ),
        
                  ),
                ],
              ),
              SizedBox(height: 30),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(
                    'Apartment Photos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              SizedBox(height: 10),
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
                      const Icon(Icons.add_a_photo_outlined, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          photos.isEmpty ? 'Add photos (min 3)' : 'Add more photos',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.black45),
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
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
                  onTap:(){
                  return showSubmitSheet();},
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
                    child: Center(child: Text('Publish',style: TextStyle(color: Colors.white,fontSize: 20),)),
                  ),
                ),
              ),
              SizedBox(height: 30,)
            ],
          ),
        ),
      ),
    );
  }

 void showSubmitSheet() {
   if (!_formKey.currentState!.validate()) {
     return;
   }
   if (photos.length < 3) {
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(
         content: Text('Please add at least 3 photos'),
       ),
     );
     return;
   }
   showModalBottomSheet(
     context: context,
     isScrollControlled: true,
     shape: const RoundedRectangleBorder(
       borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
     ),
     builder: (ctx) {
       return Padding(
         padding: EdgeInsets.only(
           left: 20,
           right: 20,
           top: 20,
           bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
         ),
         child: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             Container(
               width: 40,
               height: 5,
               decoration: BoxDecoration(
                 color: Colors.grey.shade400,
                 borderRadius: BorderRadius.circular(10),
               ),
             ),
             const SizedBox(height: 20),
             Container(
               width: 80,
               height: 80,
               decoration: BoxDecoration(
                 shape: BoxShape.circle,
                 color: Colors.grey.withOpacity(0.15),
               ),
               child: Center(
                 child: Container(
                   width: 40,
                   height: 40,
                   decoration: const BoxDecoration(
                     shape: BoxShape.circle,
                     color: Colors.blue,
                   ),
                   child: const Icon(Icons.info, color: Colors.white, size: 20),
                 ),
               ),
             ),

             const SizedBox(height: 14),
             const Text(
               'Are you sure about posting the apartment listing?',
               textAlign: TextAlign.center,
               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
             ),

             const SizedBox(height: 20),

             Row(
               children: [
                 Expanded(
                   child: OutlinedButton(
                     onPressed: () {
                       Navigator.pop(ctx);
                     },
                     child: const Text('Edit'),
                   ),
                 ),
                 const SizedBox(width: 10),
                 Expanded(
                   child: ElevatedButton(
                     onPressed: () async {
                       Navigator.pop(ctx);
                       await publishApartment();
                       // close confirm sheet
                      /* await publishApartment(); //
                       if (!mounted) return;*/
                      // showSuccessSheet();
                     },
                     child: const Text('Ok'),
                   ),
                 ),
               ],
             ),
           ],
         ),
       );
     },
   );
 }

 void showSuccessSheet() {
   showModalBottomSheet(
     context: context,
     isScrollControlled: true,
     shape: const RoundedRectangleBorder(
       borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
     ),
     builder: (ctx) {
       return Padding(
         padding: EdgeInsets.only(
           left: 20,
           right: 20,
           top: 20,
           bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
         ),
         child: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             Container(
               width: 40,
               height: 5,
               decoration: BoxDecoration(
                 color: Colors.grey.shade400,
                 borderRadius: BorderRadius.circular(10),
               ),
             ),
             const SizedBox(height: 20),

             Container(
               width: 80,
               height: 80,
               decoration: BoxDecoration(
                 shape: BoxShape.circle,
                 color: Colors.grey.withOpacity(0.15),
               ),
               child: Center(
                 child: Container(
                   width: 40,
                   height: 40,
                   decoration: const BoxDecoration(
                     shape: BoxShape.circle,
                     color: Colors.blue,
                   ),
                   child: const Icon(Icons.check, color: Colors.white, size: 20),
                 ),
               ),
             ),

             const SizedBox(height: 14),
             const Text(
               'Congratulations!',
               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
             ),
             const SizedBox(height: 6),
             const Text(
               'Your apartment is published',
               style: TextStyle(color: Colors.black54,fontSize: 16),
             ),

             const SizedBox(height: 20),

             SizedBox(
               width: double.infinity,
               height: 48,
               child: ElevatedButton(
                 onPressed: () {
                   Navigator.pop(ctx);
                   DefaultTabController.of(context).animateTo(1);                 },
                 child: const Text('Done'),
               ),
             ),

             const SizedBox(height: 10),
           ],
         ),
       );
     },
   );
 }
}
