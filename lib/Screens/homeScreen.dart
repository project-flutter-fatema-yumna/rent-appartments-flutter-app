import 'dart:io';
import 'package:flats_app/Screens/filtered_apartments_screen.dart';
import 'package:flats_app/Screens/seeAllScreen.dart';
import 'package:flats_app/Services/Get_Paginate_Apartment.dart';
import 'package:flats_app/models/filter_criteria.dart';
import 'package:flats_app/models/model_apartment.dart';
import 'package:flats_app/providers/user_provider.dart';
import 'package:flats_app/widgets/cardHome.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../MyColors.dart';
import '../widgets/secondCardHome.dart';

class Homescreen extends StatefulWidget {
  static String id = 'Homescreen';
  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  Future<List<Model_Apartment>>? apartmentsFuture;
  
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void fetchApartments() async {
    String? token = await getToken();
    if (token == null) {
      return;
    }
    setState(() {
      apartmentsFuture = get_apartment().getAllApartment(token: token);
    });
  }

  @override
  void initState() {
    super.initState();
    context.read<UserProvider>().setUserFromPrefs();
    fetchApartments();
  }

  Future<FilterCriteria?> openFilter(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ApartmentFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    if (user == null) {
      return CircularProgressIndicator();
    }
    return Scaffold(
      backgroundColor: myColors.colorWhite,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //User info row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: user.personalPhoto != null
                            ? FileImage(File(user.personalPhoto!.path))
                            : const AssetImage('assets/person2.jfif'),
                      ),
                      SizedBox(width: 15),
                      Text(
                        user?.userName ?? 'Guest',
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.notifications_none),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Align(
                alignment: Alignment.centerLeft,
                child: Stack(
                  children: [
                    TextField(
                      onTap: () async {
                        final filters = await openFilter(context);
                        if (filters != null) {
                          Navigator.pushNamed(
                            context,
                            FilteredApartmentsScreen.id,
                            arguments: filters,
                          );
                        }
                      },
                      readOnly: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Filter apartments',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 3,
                      child: IconButton(
                        onPressed: () => openFilter(context),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        padding: EdgeInsets.all(12),
                        icon: Icon(Icons.tune),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Recommended Property',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 300,
                child: apartmentsFuture == null
                    ? const Center(child: CircularProgressIndicator())
                    : FutureBuilder<List<Model_Apartment>>(
                        future: apartmentsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text('Error'));
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(child: Text('No apartment'));
                          }
                          List<Model_Apartment> apartments = snapshot.data!;
                          //.where((apt)=>(apt.home_rate??0)>4).toList();
                          return ListView.builder(
                            itemCount: apartments.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              if (index < 5) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: CardHome(
                                    model_apartment: apartments[index],
                                  ),
                                );
                              }
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.navigate_next,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Flats',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, See_all_screen.id);
                      },
                      child: Text(
                        'See All',
                        style: TextStyle(color: Colors.blueGrey, fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
              FutureBuilder<List<Model_Apartment>>(
                future: apartmentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('ERROR: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No apartment'));
                  }

                  final flats = snapshot.data!;
                  return ListView.builder(
                    itemCount: flats.length,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Second_card_home(model_apartment: flats[index]);
                    },
                  );
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class ApartmentFilterSheet extends StatefulWidget {
  const ApartmentFilterSheet({super.key});

  @override
  State<ApartmentFilterSheet> createState() => _ApartmentFilterSheetState();
}

class _ApartmentFilterSheetState extends State<ApartmentFilterSheet> {
  FilterCriteria filters = FilterCriteria();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Filter Apartments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: _dropdown(
                        label: 'Governorate',
                        value: filters.governorate,
                        items: const ['Damascus', 'Rural Damascus', 'Homs'],
                        onChanged: (v) =>
                            setState(() => filters.governorate = v),
                      ),
                    ),
                    _dropdown(
                      label: 'City',
                      value: filters.city,
                      items: const ['Mazzeh', 'Jaramana', 'Zahera'],
                      onChanged: (v) => setState(() => filters.city = v),
                    ),
                    const SizedBox(height: 12),
                    _title('Furnished'),
                    Wrap(
                      spacing: 8,
                      children: [
                        _chip('Yes', filters.furnished == true, () {
                          setState(
                            () => filters.furnished == true
                                ? filters.furnished = null
                                : filters.furnished = true,
                          );
                        }),
                        _chip('No', filters.furnished == false, () {
                          setState(
                            () => filters.furnished == false
                                ? filters.furnished = null
                                : filters.furnished = false,
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _slider(
                      'Rooms',
                      (filters.rooms ?? -1).toDouble(),
                      10,
                      (v) => setState(() => filters.rooms = v.round()),
                    ),
                    _slider(
                      'Bedrooms',
                      (filters.bedrooms ?? -1).toDouble(),
                      10,
                      (v) => setState(() => filters.bedrooms = v.round()),
                    ),
                    _slider(
                      'Bathrooms',
                      (filters.baths ?? -1).toDouble(),
                      6,
                      (v) => setState(() => filters.baths = v.round()),
                    ),
                    _slider(
                      'Floor Number',
                      (filters.floor ?? -1).toDouble(),
                      20,
                      (v) => setState(() => filters.floor = v.round()),
                    ),
                    _slider(
                      'Balconies',
                      (filters.balcony ?? -1).toDouble(),
                      6,
                      (v) => setState(() => filters.balcony = v.round()),
                    ),
                    _slider(
                      'Parking Spots',
                      (filters.parking ?? -1).toDouble(),
                      5,
                      (v) => setState(() => filters.parking = v.round()),
                    ),
                    _slider(
                      'Area (m²)',
                      filters.space ?? -1,
                      300,
                      (v) => setState(() => filters.space = v),
                    ),
                    _slider(
                      'Maximum Rent',
                      filters.rent ?? -1,
                      5_000_000,
                      (v) => setState(() => filters.rent = v),
                    ),
                    _slider(
                      'Rate',
                      filters.rate ?? -1,
                      5,
                      (v) => setState(() => filters.rate = v),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue),
                    ),
                    onPressed: () {
                      setState(() {
                        filters.governorate = filters.city = filters.furnished =
                            filters.rooms = filters.bedrooms = filters.baths =
                                filters.floor = filters.balcony = filters.parking =
                                    filters.space = filters.rent = filters.rate = null;
                      });
                    },
                    child: const Text(
                      'Reset',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () {
                      if (filters.isFiltered()) {
                        Navigator.pop(context, null);
                      } else {
                        Navigator.pop(context, filters);
                      }
                    },
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _title(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
  );

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          floatingLabelStyle: TextStyle(color: Colors.blue),
          labelText: label,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue, width: 1.5),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _chip(String text, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(text),
      selected: selected,
      selectedColor: Colors.blue,
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
      checkmarkColor: Colors.white,
      onSelected: (_) => onTap(),
    );
  }

  Widget _slider(
    String label,
    double value,
    int max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value == -1 ? 'Any' : value.toInt()}'),
        Slider(
          value: value == -1 ? 0 : value,
          max: max.toDouble(),
          divisions: max,
          activeColor: Colors.blue,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
