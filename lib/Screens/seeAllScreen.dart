import 'package:flats_app/MyColors.dart';
import 'package:flutter/material.dart';

import '../Services/Get_Paginate_Apartment.dart';
import '../models/model_apartment.dart';
import '../widgets/cardHome.dart';
import '../widgets/cardSeeAllScreen.dart';

class See_all_screen extends StatefulWidget {
  static String id = 'See_all_screen';
  const See_all_screen({super.key});

  @override
  State<See_all_screen> createState() => _See_all_screenState();
}

class _See_all_screenState extends State<See_all_screen> {
  late Future<List<Model_Apartment>> apartmentsFuture;

  @override
  void initState() {
    super.initState();
    apartmentsFuture = get_apartment().getAllApartment(token:'8|AGei4tZYe7LlDuWzJWwzzTiYRYn1Zp7RPbEx2BgKd30a0133');

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: myColors.colorWhite,
      appBar: AppBar(
        title: Text('Flats', style: TextStyle(color: Colors.white)),
        elevation: 5,
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search, color: Colors.white),
          ),
        ],
        iconTheme: IconThemeData(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: FutureBuilder<List<Model_Apartment>>(
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

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GridView.builder(
                      itemCount: flats.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        mainAxisExtent: 246,
                      ),
                      itemBuilder: (context, index) {
                        return CardSeeAll(model_apartment: flats[index],);
                      },
                    ),
                    Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              spreadRadius: 1,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.keyboard_arrow_down_outlined,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
