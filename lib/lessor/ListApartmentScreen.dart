import 'package:flats_app/MyColors.dart';
import 'package:flats_app/Services/Get_All_Apartment_for_lessor.dart';
import 'package:flats_app/models/model_apartment.dart';
import 'package:flutter/material.dart';
import 'apartmentDetails.dart';
import 'catogary/CardApartment.dart';

class List_Apatment extends StatefulWidget {
  static String id='List_Apatment';

  @override
  State<List_Apatment> createState() => _List_ApatmentState();
}

class _List_ApatmentState extends State<List_Apatment> {
  late Future<List<Model_Apartment>> apartments;
  List<Model_Apartment> flats=[];

  @override
  void initState() {
    super.initState();
    apartments = get_all_apartment_for_lessor().getApatment_Lessor(token: '9|c3hNZQ6edWTejdujij2NCDd5cxuva6seMemvBknc79b62022');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:myColors.colorWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Your Apartments",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                "Manage your listings and see details",
                style: TextStyle(color: Colors.grey.shade600,fontSize: 18),
              ),
              const SizedBox(height: 14),
              Expanded(
                child : FutureBuilder(
                    future: apartments,
                    builder: (context,snapshot) {
                  if(snapshot.connectionState==ConnectionState.waiting){
                    return Center(child: CircularProgressIndicator(),);
                  }
                  if(snapshot.hasError){
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No orders yet"));
                  }
                  if(flats.isEmpty){
                    flats = snapshot.data!;
                  }
                  return  ListView.separated(
                    itemCount: flats.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return ApartmentCardUI(
                       model_apartment:flats[index],
                        onTap: ()
                        {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                              ),
                              builder: (_) => ApartmentDetailsSheet(apartment: flats[index]),
                            );
                            },
                        onEdit: () {},
                        onDelete: () {},
                      );
                    },
                  );
                },
                )
              ),
              SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }
}
