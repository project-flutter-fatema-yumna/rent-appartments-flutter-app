import 'package:easy_localization/easy_localization.dart';
import 'package:flats_app/Services/get_favoutite_apartments.dart';
import 'package:flutter/material.dart';
import 'package:flats_app/models/model_apartment.dart';
import 'package:flats_app/widgets/secondCardHome.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});
  static String id = 'FavoriteScreen';

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  bool _isLoading = true;
  List<Model_Apartment> apartments = [];
  String? _errorMsg;

  @override
  void initState() {
    _loadApartments();
    super.initState();
  }

  Future<void> _loadApartments() async {
    try {
      final result = await fetchFavorites();
      setState(() {
        apartments = result;
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'something_wrong'.tr();
        print('$e');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'my_favorites'.tr(),
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
        ),
      );
    }

    if (_errorMsg != null) {
      return Center(child: Text(_errorMsg!));
    }

    if (apartments.isEmpty) {
      return Center(
        child: Text(
          'no_apartments'.tr(),
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyLarge!.color!,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: apartments.length,
      itemBuilder: (context, index) {
        return Second_card_home(
          model_apartment: apartments[index],
          onToggleSuccess: () {
            setState(() {
              apartments.removeAt(index);
            });
          },
        );
      },
    );
  }
}
