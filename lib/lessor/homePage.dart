import 'package:flats_app/MyColors.dart';
import 'package:flutter/material.dart';

import 'AddApartmentScreen.dart';
import 'ListApartmentScreen.dart';
import 'OrdersScreen.dart';

class Homepage extends StatelessWidget {
  static String id='Homepage';
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: myColors.colorWhite,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'User name',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,

        ),
        body: Column(
          children: [
            TabBar(
              labelColor: Colors.blue,
              indicatorColor: Colors.blue,
              indicatorAnimation: TabIndicatorAnimation.linear,
              indicatorWeight: 3,
              tabs: [
                Tab(child: Text('Add', style: TextStyle(fontSize: 18))),
                Tab(child: Text('Show', style: TextStyle(fontSize: 18))),
                Tab(child: Text('Orders', style: TextStyle(fontSize: 18))),

              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  addApartmentScreen(),
                  List_Apatment(),
                  OrdersScreen()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
