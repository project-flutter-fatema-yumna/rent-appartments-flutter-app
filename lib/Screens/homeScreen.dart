import 'package:flats_app/Screens/seeAllScreen.dart';
import 'package:flats_app/Services/Get_Paginate_Apartment.dart';
import 'package:flats_app/models/model_apartment.dart';
import 'package:flats_app/widgets/cardHome.dart';
import 'package:flutter/material.dart';
import '../MyColors.dart';
import '../widgets/secondCardHome.dart';

class Homescreen extends StatefulWidget {
  static String id = 'Homescreen';
  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
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
        body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
            child: SingleChildScrollView(
                child: Column(
                  children: [
                  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/person2.jfif'),
                      radius: 25,
                    ),
                    // Text('User name',style: TextStyle(color: Colors.blueGrey,fontSize: 20),),
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
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Find something',
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
                        top: 3,
                        right: 3,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(Icons.search, color: Colors.white),
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
                  child: FutureBuilder<List<Model_Apartment>>(
                  future: apartmentsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
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

                    final rated = apartments.where((apt) => (apt.home_rate ?? 0) >= 4.0).toList();

                    if (rated.isEmpty) {
                      return Center(
                          child:Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.roofing_outlined,color: Colors.blue,size: 100,),
                              Text('There are no apartments rated 5.0',style: TextStyle(color: Colors.blue),),

                    ],
                          ));
                    }
                    return ListView.builder(
                      itemCount: rated.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: CardHome(model_apartment: apartments[index]),
                          );
                        }
                      /*  return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
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
                        );*/
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
                        'The Flats',
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, See_all_screen.id,);
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
                    }),
                    SizedBox(height: 20),
                  ],
                ),
            ),
        ),
    );
  }
}