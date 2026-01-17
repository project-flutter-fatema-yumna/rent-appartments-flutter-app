import 'package:flats_app/Services/Lessor_Services/Get_All_Apartment_for_lessor.dart';
import 'package:flats_app/global_data.dart';
import 'package:flats_app/models/model_apartment.dart';
import 'package:flats_app/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import '../Services/Lessor_Services/Delete_Apartment_Lessor/deleteApartmentServices.dart';
import 'EditeApartment_lessor.dart';
import 'apartmentDetails.dart';
import 'catogary/CardApartment.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:easy_localization/easy_localization.dart';


class List_Apatment extends StatefulWidget {
  static String id = 'List_Apatment';

  @override
  State<List_Apatment> createState() => _List_ApatmentState();
}

class _List_ApatmentState extends State<List_Apatment> {
  late Future<List<Model_Apartment>> apartments;
  List<Model_Apartment> flats = [];
  final String token = userToken;
  @override
  void initState() {
    super.initState();
    apartments = get_all_apartment_for_lessor().getApatment_Lessor(
      token: token,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'your_apartments_title'.tr(),
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                'your_apartments_subtitle'.tr(),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 14),
              Expanded(
                child: FutureBuilder(
                  future: apartments,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: SpinKitThreeBounce(color: Colors.blue, size: 20),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text('no_apartments_yet'.tr()),
                      );
                    }

                    if (flats.isEmpty) {
                      flats = snapshot.data!;
                    }
                    return ListView.separated(
                      itemCount: flats.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return ApartmentCardUI(
                          model_apartment: flats[index],
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Theme.of(context).cardColor,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              builder: (_) => ApartmentDetailsSheet(
                                apartment: flats[index],
                              ),
                            );
                          },
                          //Edit////////////////////////////////////////////////////////////////////////
                          onEdit: () {
                            Navigator.pushNamed(
                              context,
                              EditeapartmentLessor.id,
                              arguments: flats[index],
                            );
                          },
                          //Delete///////////////////////////////////////////////////
                          onDelete: () async {
                            final apt = flats[index];
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor: Theme.of(context).cardColor,
                                title: Text('delete_apartment_title'.tr()),
                                content:  Text(
                                  'delete_apartment_message'.tr(),),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text(
                                      'cancel'.tr(),
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),

                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).primaryColor,
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: Text(
                                      'delete'.tr(),
                                      style: const TextStyle(color: Colors.white),
                                    ),

                                  ),
                                ],
                              ),
                            );
                            if (ok != true) return;
                            try {
                              await deleteApatment().deleteApartmentSevic(
                                apartmentId: apt.id,
                                token: token,
                              );

                              if (!mounted) return;

                              setState(() {
                                flats.removeWhere((a) => a.id == apt.id);
                              });

                              mySnackBar(
                                context,
                                'apartment_deleted'.tr(),
                                color: Theme.of(context).primaryColor,
                              );

                            }  catch (e) {
                          mySnackBar(
                            context,
                            'delete_failed'.tr(),
                            color: Theme.of(context).primaryColor,
                          );
                        }

                      },
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
