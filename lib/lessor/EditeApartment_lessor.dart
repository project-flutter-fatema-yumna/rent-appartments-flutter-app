import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flats_app/Services/Lessor_Services/addImageServices.dart';
import 'package:flats_app/global_data.dart';
import 'package:flats_app/models/model_apartmentUpdate.dart';
import 'package:flats_app/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flats_app/models/model_apartment.dart';

import '../Services/Lessor_Services/Delete_Apartment_Lessor/deleteImage.dart';
import '../Services/Lessor_Services/UpdateApartment_lessor.dart';
import '../Services/getAllCityes_services.dart';
import 'package:easy_localization/easy_localization.dart';

import '../helper/Host.dart';

class EditeapartmentLessor extends StatefulWidget {
  static String id = "EditeapartmentLessor";
  const EditeapartmentLessor({super.key});

  @override
  State<EditeapartmentLessor> createState() => _EditeapartmentLessorState();
}

class _EditeapartmentLessorState extends State<EditeapartmentLessor> {
  late Model_Apartment model_apartment;
  bool uploadingImage = false;
  final String token = userToken;

  final _formKey = GlobalKey<FormState>();

  final homeSpace = TextEditingController();
  final rent = TextEditingController();

  String? governorate;
  String? city;

  int? numberFloor,
      numberBaths,
      numberRoom,
      numberBedRoom,
      numberParking,
      numberBalcony;

  String? rentType;
  bool? isFurnished;

  final List<int> numbers = List.generate(11, (i) => i);
  final List<String> typs = ['daily', 'monthly', 'yearly'];
  final List<String> governorates = [
    'Damascus',
    'Rif Dimashq (Rural Damascus)',
    'Aleppo',
    'Homs',
    'Hama',
    'Latakia',
    'Tartus',
    'Idlib',
    'Deir ez-Zor',
    'Raqqa',
    'Hasakah',
    'Daraa',
    'As-Suwayda',
    'Quneitra',
  ];
  List<String> cities = [];
  bool loadingCities = false;

  int numberImage = 0;
  final ImagePicker _picker = ImagePicker();
  final List<XFile> newPhotos = [];

  bool saving = false;
  bool _initialized = false;

  @override
  void dispose() {
    homeSpace.dispose();
    rent.dispose();
    super.dispose();
  }

  //camera
  Future<XFile?> pickFromCamera() async {
    return await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
  }

  Future<List<XFile>> pickFromGallery() async {
    return await _picker.pickMultiImage(imageQuality: 80);
  }

  void showPickSourceSheet() {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).cardColor,
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text('camera'.tr()),
                onTap: uploadingImage
                    ? null
                    : () async {
                  Navigator.pop(context);

                  final img = await pickFromCamera();
                  if (img == null) return;
                  await uploadPickedImages([img]);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text('gallery'.tr()),
                onTap: uploadingImage
                    ? null
                    : () async {
                  Navigator.pop(context);

                  final picked = await pickFromGallery();
                  if (picked.isEmpty) return;

                  await uploadPickedImages(picked);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> deleteCurrentOldImage() async {
    if (model_apartment.images.isEmpty) return;

    if (numberImage < model_apartment.images.length) {
      final img = model_apartment.images[numberImage];
      try {
        await deleteImage().deletedImageMethod(imageId: img.id, token: token);

        setState(() {
          model_apartment.images.removeAt(numberImage);
          if (numberImage > 0) numberImage--;
        });
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(content: Text('failed_to_delete_image'.tr())),
        );
      }
    } else {
      final newIndex = numberImage - model_apartment.images.length;
      if (newIndex >= 0 && newIndex < newPhotos.length) {
        setState(() {
          newPhotos.removeAt(newIndex);
          if (numberImage > 0) numberImage--;
        });
      }
    }
  }

  Future<void> uploadPickedImages(List<XFile> picked) async {
    if (picked.isEmpty) return;

    setState(() => uploadingImage = true);

    try {
      for (final x in picked) {
        await addImageServices().addImage(
          apartmentId: model_apartment.id.toString(),
          image: File(x.path),
          token: token,
        );

        setState(() {
          newPhotos.add(x);
          numberImage = (model_apartment.images.length + newPhotos.length) - 1;
        });
      }

      if (!mounted) return;
      mySnackBar(
        context,
        'images_added'.tr(),
        color: Theme.of(context).primaryColor,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text('upload_failed'.tr())),
      );
    } finally {
      if (mounted) setState(() => uploadingImage = false);
    }
  }

  void initFromModelOnce() {
    if (_initialized) return;
    _initialized = true;

    governorate = model_apartment.governorate;
    city = model_apartment.city;

    homeSpace.text = (model_apartment.home_space ?? '').toString();
    rent.text = (model_apartment.rent ?? '').toString();

    numberFloor = model_apartment.floor_number;
    numberBaths = model_apartment.number_of_baths;
    numberRoom = model_apartment.rooms_number;
    numberBedRoom = model_apartment.number_of_bedrooms;
    numberParking = model_apartment.parking_number;
    numberBalcony = model_apartment.balcony_number;

    rentType = model_apartment.rent_type;
    isFurnished = (model_apartment.furnished == 1);
  }

  Future<void> Save() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('please_check_fields'.tr()),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (governorate == null || city == null) {
      mySnackBar(context, 'select_governorate_and_city'.tr());
      return;
    }
    if (rentType == null || isFurnished == null) {
      mySnackBar(context, 'select_rent_type_and_furnished'.tr());
      return;
    }

    final homeSpaceNum = double.tryParse(homeSpace.text.trim());
    final rentNum = double.tryParse(rent.text.trim());

    if (homeSpaceNum == null || rentNum == null) {
      mySnackBar(context, 'home_space_rent_must_be_numbers'.tr());
      return;
    }

    final data = <String, dynamic>{
      "governorate": governorate,
      "city": city,
      "floor_number": numberFloor ?? model_apartment.floor_number,
      "balcony_number": numberBalcony ?? model_apartment.balcony_number,
      "parking_number": numberParking ?? model_apartment.parking_number,
      "rooms_number": numberRoom ?? model_apartment.rooms_number,
      "number_of_bedrooms": numberBedRoom ?? model_apartment.number_of_bedrooms,
      "number_of_baths": numberBaths ?? model_apartment.number_of_baths,
      "furnished": (isFurnished! ? 1 : 0),
      "home_space": homeSpaceNum,
      "rent": rentNum,
      "rent_type": rentType,
    };

    setState(() => saving = true);

    try {
      final res = await UpdateApartmentService().updateApartment(
        apartmentId: model_apartment.id,
        token: token,
        data: data,
      );

      final updated = model_apartmentUpdate.fromJson(res);

      if (!mounted) return;

      setState(() => saving = false);

      showModalBottomSheet(
        backgroundColor: Theme.of(context).cardColor,
        context: context,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        builder: (_) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 6),
              const Icon(Icons.check_circle, size: 52, color: Colors.green),
              const SizedBox(height: 10),
              Text(
                updated.message.isEmpty
                    ? 'saved_successfully'.tr()
                    : updated.message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${'updated_rent_prefix'.tr()} ${updated.apartment.rent} | ${'updated_city_prefix'.tr()} ${updated.apartment.city}',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text('error_generic'.tr(args: [e.toString()]))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    model_apartment =
    ModalRoute.of(context)!.settings.arguments as Model_Apartment;
    initFromModelOnce();

    final oldCount = model_apartment.images.length;
    final newCount = newPhotos.length;
    final totalCount = oldCount + newCount;

    if (totalCount == 0) numberImage = 0;
    if (numberImage >= totalCount && totalCount > 0) {
      numberImage = totalCount - 1;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'edit_apartment_title'.tr(),
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 32),
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: saving ? null : Save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: saving
                  ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : Text(
                'save_changes_button'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
            children: [
              //images
              Container(
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: [
                      if (totalCount == 0)
                        Container(
                          color: Theme.of(context).primaryColor,
                          child: Center(
                            child: Icon(
                              Icons.photo_outlined,
                              size: 70,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        )
                      else
                        PageView.builder(
                          onPageChanged: (i) => setState(() => numberImage = i),
                          itemCount: totalCount,
                          itemBuilder: (_, i) {
                            if (i < oldCount) {
                              final path = model_apartment.images[i].image;
                              final url = 'http://${Host.host}:8000/storage/$path';
                              return Image.network(
                                url,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: Icon(Icons.broken_image),
                                  ),
                                ),
                              );
                            }
                            // new images
                            final localIndex = i - oldCount;
                            return Image.file(
                              File(newPhotos[localIndex].path),
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      // top left badge
                      Positioned(
                        left: 12,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            totalCount == 0
                                ? 'no_photos_label'.tr()
                                : '${numberImage + 1}/$totalCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Material(
                          color: Colors.white.withOpacity(0.9),
                          shape: const CircleBorder(),
                          elevation: 3,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: uploadingImage ? null : showPickSourceSheet,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Icon(
                                Icons.add_a_photo_outlined,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Material(
                          color: Colors.white.withOpacity(0.9),
                          shape: const CircleBorder(),
                          elevation: 3,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: totalCount == 0
                                ? null
                                : deleteCurrentOldImage,
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // dots indicators
                      if (totalCount > 1)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 14,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(totalCount, (i) {
                              final active = i == numberImage;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                width: active ? 10 : 7,
                                height: active ? 10 : 7,
                                decoration: BoxDecoration(
                                  color: active
                                      ? Theme.of(context).primaryColor
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              );
                            }),
                          ),
                        ),

                      if (uploadingImage)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.25),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              ///location
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'location_section_title'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField2<String>(
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                      isExpanded: true,
                      value: (governorate != null &&
                          governorates.contains(governorate))
                          ? governorate
                          : null,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        labelText: 'governorate_label'.tr(),
                        prefixIcon: const Icon(Icons.account_balance),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 1.4,
                          ),
                        ),
                      ),
                      items: governorates
                          .map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                      )
                          .toList(),
                      onChanged: (value) async {
                        setState(() {
                          governorate = value;
                          cities = [];
                          city = null;
                          cities.clear();
                          loadingCities = true;
                        });
                        final result = await get_all_cityes().getCityes(
                          governorate: value!,
                          token: token,
                        );
                        setState(() {
                          cities = result;
                          loadingCities = false;
                        });
                      },
                      validator: (v) =>
                      v == null ? 'governorate_required'.tr() : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      initialValue: null,
                      controller: TextEditingController(text: city ?? ''),
                      readOnly: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        labelText: 'city_current_label'.tr(),
                        prefixIcon: const Icon(Icons.location_city),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField2<String>(
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                      isExpanded: true,
                      value: city,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        labelText: 'select_city_label'.tr(),
                        prefixIcon: const Icon(Icons.location_on),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 1.4,
                          ),
                        ),
                      ),
                      items: cities
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                      )
                          .toList(),
                      onChanged: cities.isEmpty
                          ? null
                          : (v) => setState(() => city = v),
                      validator: (v) =>
                      v == null ? 'city_required'.tr() : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              //main details
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'main_details_section_title'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: homeSpace,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        labelText: 'home_space_label'.tr(),
                        prefixIcon: const Icon(Icons.square_foot),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 1.4,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'home_space_required'.tr();
                        }
                        final n = double.tryParse(v);
                        if (n == null || n <= 0) {
                          return 'enter_valid_number'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField2<int>(
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .scaffoldBackgroundColor,
                              ),
                            ),
                            isExpanded: true,
                            value: numberFloor,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Theme.of(context).cardColor,
                              labelText: 'floor'.tr(),
                              prefixIcon: const Icon(Icons.apartment),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            items: numbers
                                .map(
                                  (n) => DropdownMenuItem(
                                value: n,
                                child: Text('$n'),
                              ),
                            )
                                .toList(),
                            onChanged: (v) => setState(() => numberFloor = v),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField2<int>(
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .scaffoldBackgroundColor,
                              ),
                            ),
                            isExpanded: true,
                            value: numberBaths,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Theme.of(context).cardColor,
                              labelText: 'baths'.tr(),
                              prefixIcon: const Icon(Icons.bathtub_outlined),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            items: numbers
                                .map(
                                  (n) => DropdownMenuItem(
                                value: n,
                                child: Text('$n'),
                              ),
                            )
                                .toList(),
                            onChanged: (v) => setState(() => numberBaths = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField2<int>(
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .scaffoldBackgroundColor,
                              ),
                            ),
                            isExpanded: true,
                            value: numberRoom,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Theme.of(context).cardColor,
                              labelText: 'rooms_label'.tr(),
                              prefixIcon:
                              const Icon(Icons.meeting_room_outlined),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            items: numbers
                                .map(
                                  (n) => DropdownMenuItem(
                                value: n,
                                child: Text('$n'),
                              ),
                            )
                                .toList(),
                            onChanged: (v) => setState(() => numberRoom = v),
                            validator: (v) =>
                            v == null ? 'select_rooms'.tr() : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField2<int>(
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .scaffoldBackgroundColor,
                              ),
                            ),
                            isExpanded: true,
                            value: numberBedRoom,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Theme.of(context).cardColor,
                              labelText: 'bedrooms_label'.tr(),
                              prefixIcon: const Icon(Icons.bed_outlined),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            items: numbers
                                .map(
                                  (n) => DropdownMenuItem(
                                value: n,
                                child: Text('$n'),
                              ),
                            )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => numberBedRoom = v),
                            validator: (v) =>
                            v == null ? 'select_bedrooms'.tr() : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField2<int>(
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .scaffoldBackgroundColor,
                              ),
                            ),
                            isExpanded: true,
                            value: numberParking,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Theme.of(context).cardColor,
                              labelText: 'parking_label'.tr(),
                              prefixIcon: const Icon(Icons.car_crash),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            items: numbers
                                .map(
                                  (n) => DropdownMenuItem(
                                value: n,
                                child: Text('$n'),
                              ),
                            )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => numberParking = v),
                            validator: (v) =>
                            v == null ? 'select_parking'.tr() : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField2<int>(
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .scaffoldBackgroundColor,
                              ),
                            ),
                            isExpanded: true,
                            value: numberBalcony,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Theme.of(context).cardColor,
                              labelText: 'balcony_label'.tr(),
                              prefixIcon: const Icon(Icons.balcony_outlined),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            items: numbers
                                .map(
                                  (n) => DropdownMenuItem(
                                value: n,
                                child: Text('$n'),
                              ),
                            )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => numberBalcony = v),
                            validator: (v) =>
                            v == null ? 'select_balcony'.tr() : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              //Rent
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'rent_section_title'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: rent,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        labelText: 'rent_label'.tr(),
                        prefixIcon: Icon(
                          Icons.attach_money,
                          color: Colors.green.shade600,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                          BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 1.4,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'rent_required'.tr();
                        }
                        final n = double.tryParse(v);
                        if (n == null || n <= 0) {
                          return 'enter_valid_rent'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField2<String>(
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .scaffoldBackgroundColor,
                              ),
                            ),
                            isExpanded: true,
                            value: rentType,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Theme.of(context).cardColor,
                              labelText: 'rent_type_label'.tr(),
                              prefixIcon:
                              const Icon(Icons.calendar_month_outlined),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            items: typs
                                .map(
                                  (t) => DropdownMenuItem(
                                value: t,
                                child: Text(t),
                              ),
                            )
                                .toList(),
                            onChanged: (v) => setState(() => rentType = v),
                            validator: (v) =>
                            v == null ? 'rent_type_required'.tr() : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField2<bool>(
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .scaffoldBackgroundColor,
                              ),
                            ),
                            isExpanded: true,
                            value: isFurnished,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Theme.of(context).cardColor,
                              labelText: 'furnished_label'.tr(),
                              prefixIcon:
                              const Icon(Icons.chair_outlined),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: true,
                                child: Text('yes'.tr()),
                              ),
                              DropdownMenuItem(
                                value: false,
                                child: Text('no'.tr()),
                              ),
                            ],
                            onChanged: (v) => setState(() => isFurnished = v),
                            validator: (v) =>
                            v == null ? 'required_field'.tr() : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              //new photos
              if (newPhotos.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'new_photos_section_title'.tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: newPhotos.length,
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        itemBuilder: (_, i) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(newPhotos[i].path),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => newPhotos.removeAt(i)),
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
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
