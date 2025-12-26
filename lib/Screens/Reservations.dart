import 'package:flutter/material.dart';

class ReservationsScreen extends StatelessWidget {
  static String id = 'ReservationsScreen';
  const ReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Your Reservations',
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
                Tab(child: Text('Current', style: TextStyle(fontSize: 18))),
                Tab(child: Text('Previous', style: TextStyle(fontSize: 18))),
                Tab(child: Text('Canceled', style: TextStyle(fontSize: 18))),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Center(child: Text('Current reservations')),
                  Center(child: Text('Previous reservations')),
                  Center(child: Text('Canceled reservations')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
