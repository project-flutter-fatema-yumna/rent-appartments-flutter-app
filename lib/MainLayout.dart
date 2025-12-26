
import 'package:flats_app/Screens/Reservations.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'Screens/chatScreen.dart';
import 'Screens/favoriteScreen.dart';
import 'Screens/homeScreen.dart';
import 'Screens/profileScreen.dart';

class MainlayoutScreen extends StatefulWidget {
  static String id ='MainlayoutScreen';
  @override
  State<MainlayoutScreen> createState() => _MainlayoutScreenState();
}

class _MainlayoutScreenState extends State<MainlayoutScreen> {
  int numberScreen = 0;
  final List<Widget> screens = [
    Homescreen(),
    ReservationsScreen(),
    FavoriteScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          screens[numberScreen],
          Positioned(
            bottom: 20,
            left: 15,
            right: 15,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: Colors.blue,
                )
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: GNav(
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.blue,
                  activeColor: Colors.white,
                  tabBackgroundColor: Colors. blue.shade200,
                  padding: EdgeInsets.all(8),
                  gap: 8,
                  selectedIndex: numberScreen,
                  onTabChange: (index) {
                    print('the index is :$index');
                    if (index == numberScreen) {
                      return;
                    }
                    setState(() {
                      numberScreen = index;
                    });
                  },
                  tabs: [
                    GButton(icon: Icons.home, text: 'Home'),
                    GButton(icon: Icons.list_alt, text: 'Reservations'),
                    GButton(icon: Icons.favorite, text: 'Favorite'),
                    GButton(icon: Icons.chat, text: 'Chat'),
                    GButton(icon: Icons.person, text: 'profile'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
