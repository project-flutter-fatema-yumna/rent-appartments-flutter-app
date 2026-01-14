import 'dart:io';
import 'package:flats_app/Screens/filtered_apartments_screen.dart';
import 'package:flats_app/Screens/notifications_screen.dart';
import 'package:flats_app/Screens/seeAllScreen.dart';
import 'package:flats_app/Services/Get_Paginate_Apartment.dart';
import 'package:flats_app/Services/get_cities.dart';
import 'package:flats_app/Services/get_favoutite_apartments.dart';
import 'package:flats_app/Screens/walletTenantScreens/homCardTenant.dart';
import 'package:flats_app/models/filter_criteria.dart';
import 'package:flats_app/models/model_apartment.dart';
import 'package:flats_app/providers/favorite_provider.dart';
import 'package:flats_app/providers/user_provider.dart';
import 'package:flats_app/widgets/cardHome.dart';
import 'package:flats_app/widgets/personal_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_colors.dart';
import '../Services/ApartmentsPaginationService.dart';
import '../providers/notification_provider.dart';
import '../widgets/secondCardHome.dart';

class Homescreen extends StatefulWidget {
  static String id = 'Homescreen';
  const Homescreen({super.key});
  @override
  State<Homescreen> createState() => HomescreenState();
}

class HomescreenState extends State<Homescreen> {
  Future<List<Model_Apartment>>? apartmentsFuture;
  final ScrollController _scrollController = ScrollController();

  List<Model_Apartment> flats = [];
  String? nextPageUrl;

  bool firstLoading = true;
  bool loadingMore = false;

  String? token;

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString('token');
  }
  //fast for pagaination
  Future<void> _initToken() async {
    token = await getToken();
  }
  Future<void> loadingFirstPage() async{
    await _initToken();
    if(token==null) { setState(() => firstLoading = false);
    return;}
    setState(() => firstLoading = true);

    try {
      final page = await ApartmentsPaginationService().getFirstPage(token: token!);
      setState(() {
        flats = page.data;
        nextPageUrl = page.nextPageUrl;
      });
    } catch (e) {
    } finally {
      setState(() => firstLoading = false);
    }

  }

  String fixUrl(String url) =>
      url.replaceFirst('127.0.0.1', '10.0.2.2');

  Future<void> loadMore() async {
    if (loadingMore) return;
    if (nextPageUrl == null) return;
    if (token == null) {
      await _initToken();
      if (token == null) return;
    }

    setState(() => loadingMore = true);

    try {
      final page = await ApartmentsPaginationService().getByUrl(
        token: token!,
        url: fixUrl(nextPageUrl!),
      );

      setState(() {
        flats.addAll(page.data);
        nextPageUrl = page.nextPageUrl;
      });
    } catch (e) {
    } finally {
      setState(() => loadingMore = false);
    }
  }


  /* void fetchApartments() async {
    String? token = await getToken();
    if (token == null) return;

    setState(() {
      apartmentsFuture = get_apartment().getAllApartment(token: token);
      print("token: $token");

    });
<<<<<<< HEAD

    try {
      final favorites = await fetchFavorites();

      if (favorites != null) {
        List<int> ids = favorites.map((e) => e.id).toList();

        if (mounted) {
          Provider.of<FavoriteProvider>(
            context,
            listen: false,
          ).loadInitialFavorites(ids);
        }
      }
    } catch (e) {
      print("Error loading initial favorites: $e");
    }
  }
=======
  }*/


  @override
  void initState() {
    super.initState();
    context.read<UserProvider>().setUserFromPrefs();

    loadingFirstPage();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 250) {
        loadMore();
      }
    });
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
      return SpinKitThreeBounce(color: Colors.blue,size: 20,);
    }
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //User info row
                  Row(
                    children: [
                      personalImage(user, 25),
                      SizedBox(width: 15),
                      Text(
                        user?.userName ?? 'Guest',
                        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: 20),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25)
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                Navigator.pushNamed(context, TenantWalletScreen.id);
                              },
                              icon:  Icon(Icons.add_card, color:Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25)
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    Navigator.pushNamed(context, notificationScreen.id);
                                  },
                                  icon:  Icon(Icons.notifications, color:Colors.grey),
                                ),
                              ),
                              Positioned(
                                right: 2,
                                top: 2,
                                child: Consumer<notification_provider>(
                                  builder: (context, p, child) {
                                    final List=p.unReadList;
                                    if (List.isEmpty) return const SizedBox.shrink();

                                    return Container(
                                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                      padding: const EdgeInsets.symmetric(horizontal: 5),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        "${List.length}",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
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
                        fillColor: Theme.of(context).cardColor,
                        hintText: 'Filter apartments',
                        hintStyle: Theme.of(context).textTheme.bodyLarge,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(color: Theme.of(context).cardColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(color: Theme.of(context).cardColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(color: Theme.of(context).cardColor),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 3,
                      child: IconButton(
                        onPressed: () => openFilter(context),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        padding: EdgeInsets.all(12),
                        icon: Icon(Icons.tune),
                        color: Theme.of(context).cardColor,
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
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: 20),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 300,
                child: SizedBox(
                  height: 300,
                  child: firstLoading
                      ? const Center(child: SpinKitThreeBounce(color: Colors.blue,size: 20,))
                      : flats.isEmpty
                      ? const Center(child: Text('No apartment'))
                      : Builder(
                    builder: (context) {
                      final rated = flats
                          .where((apt) => (apt.home_rate ?? 0) >= 4.0)
                          .toList();
                      if (rated.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.roofing_outlined,
                                  color: Colors.blue, size: 100),
                              Text(
                                'There are no apartments rated 5.0',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: rated.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: CardHome(model_apartment: rated[index]),
                          );
                        },
                      );
                    },
                  ),
                ),

              ),
              Padding(
                padding: const EdgeInsets.only(top: 10,left: 10,right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Flats',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: 20),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, See_all_screen.id);
                      },
                      child: Text(
                        'See All',
                        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
              firstLoading
                  ? const Center(child:SpinKitThreeBounce(color: Colors.blue,size: 20,))
                  : flats.isEmpty
                  ? const Center(child: Text('No apartment'))
                  : ListView.builder(
                itemCount: flats.length + 1,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  if (index < flats.length) {
                    return Second_card_home(model_apartment: flats[index]);
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: loadingMore
                          ? const SpinKitThreeBounce(color: Colors.blue,size: 20,)
                          : const SizedBox(),
                    ),
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
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class ApartmentFilterSheet extends StatefulWidget {
  const ApartmentFilterSheet({super.key});

  @override
  State<ApartmentFilterSheet> createState() => _ApartmentFilterSheetState();
}

class _ApartmentFilterSheetState extends State<ApartmentFilterSheet> {
  FilterCriteria filters = FilterCriteria();
  List<String> governorates = [
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).textTheme.bodyLarge!.color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Filter Apartments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
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
                        items: governorates,
                        onChanged: (v) async {
                          setState(() {
                            filters.governorate = v;
                            filters.city = null;
                            cities = [];
                          });

                          if (v != null) {
                            final result =
                                await getCitiesAccourdingToGovernorate(v);
                            setState(() {
                              cities = result;
                            });
                          }
                        },
                      ),
                    ),
                    _dropdown(
                      label: 'City',
                      value: filters.city,
                      items: cities,
                      onChanged: cities.isEmpty
                          ? null
                          : (v) => setState(() => filters.city = v),
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
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    onPressed: () {
                      setState(() {
                        filters.governorate = filters.city = filters.furnished =
                            filters.rooms = filters.bedrooms = filters.baths =
                                filters.floor = filters.balcony = filters.parking =
                                    filters.space = filters.rent = filters.rate = null;
                      });
                    },
                    child: Text(
                      'Reset',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      if (filters.isFiltered()) {
                        Navigator.pop(context, null);
                      } else {
                        Navigator.pop(context, filters);
                      }
                    },
                    child: Text(
                      'Apply Filters',
                      style: TextStyle(color: Theme.of(context).cardColor)
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
    child: Text(t, style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge!.color,
      )),
  );

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        dropdownColor: Theme.of(context).cardColor,
        value: value,
        decoration: InputDecoration(
          floatingLabelStyle: TextStyle(color: Theme.of(context).primaryColor),
          labelText: label,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e, style: Theme.of(context).textTheme.bodyLarge,),))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _chip(String text, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      side: BorderSide(color: Theme.of(context).textTheme.bodyLarge!.color!),
      label: Text(text),
      selected: selected,
      selectedColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color),
      checkmarkColor: Theme.of(context).textTheme.bodyLarge!.color!,
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
          inactiveColor: Theme.of(context).scaffoldBackgroundColor,
          
          value: value == -1 ? 0 : value,
          max: max.toDouble(),
          divisions: max,
          activeColor: Theme.of(context).primaryColor,
          onChanged: onChanged,
        ),
      ],
    );

  }

}
