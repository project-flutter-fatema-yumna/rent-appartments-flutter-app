import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart'; // 👈 أضف هاد السطر

import '../Services/ApartmentsPaginationService.dart';
import '../Services/Get_Paginate_Apartment.dart';
import '../helper/Host.dart';
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
  final ScrollController scroll = ScrollController();
  List<Model_Apartment> flats = [];
  String? nextPageUrl;

  bool firstLoading = true;
  bool loadingMore = false;

  String? token;

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _initToken() async {
    token = await getToken();
  }

  Future<void> loadFirstPage() async {
    await _initToken();
    if (token == null || token!.isEmpty) {
      setState(() => firstLoading = false);
      return;
    }

    setState(() => firstLoading = true);

    try {
      final page = await ApartmentsPaginationService().getFirstPage(
        token: token!,
      );

      setState(() {
        flats = page.data;
        nextPageUrl = page.nextPageUrl;
      });
    } finally {
      setState(() => firstLoading = false);
    }
  }

  String fixUrl(String url) => url.replaceFirst('127.0.0.1', '${Host.host}');

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
    } finally {
      setState(() => loadingMore = false);
    }
  }

  @override
  void initState() {
    super.initState();

    loadFirstPage();

    scroll.addListener(() {
      if (scroll.position.pixels >= scroll.position.maxScrollExtent - 250) {
        loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'flats_title'.tr(),
          style: const TextStyle(color: Colors.white),
        ),
        elevation: 5,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: firstLoading
          ? const Center(child:SpinKitThreeBounce(color: Colors.blue, size: 20))
          : flats.isEmpty
          ? Center(
        child: Text(
          'no_apartments'.tr(),
        ),
      )
          : SingleChildScrollView(
        controller: scroll,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              GridView.builder(
                itemCount: flats.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 246,
                ),
                itemBuilder: (context, index) {
                  return CardSeeAll(model_apartment: flats[index]);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: loadingMore
                      ? const CircularProgressIndicator()
                      : const SizedBox(),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }
}
