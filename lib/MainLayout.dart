
import 'package:flats_app/Screens/Reservations.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'Screens/chatScreen.dart';
import 'Screens/favoriteScreen.dart';
import 'Screens/homeScreen.dart';
import 'Screens/profileScreen.dart';

class MainlayoutScreen extends StatefulWidget {
  static String id ='MainlayoutScreen';
  final VoidCallback toggleTheme;

  const MainlayoutScreen({super.key, required this.toggleTheme});

  @override
  State<MainlayoutScreen> createState() => _MainlayoutScreenState();
}

class _MainlayoutScreenState extends State<MainlayoutScreen> {
  int numberScreen = 0;
  final GlobalKey<HomescreenState> homeKey = GlobalKey<HomescreenState>();
  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();
    screens = [
      Homescreen(key: homeKey,),
      FavoriteScreen(),
      ReservationsScreen(),
      ChatScreen(),
      ProfileScreen(toggleTheme: widget.toggleTheme),
    ];
  }

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
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                )
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: GNav(
                  backgroundColor: Theme.of(context).cardColor,
                  color: Theme.of(context).primaryColor,
                  activeColor: Colors.white,
                  tabBackgroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.all(8),
                  gap: 8,
                  selectedIndex: numberScreen,
                  onTabChange: (index) {
                    if (index == numberScreen) return;
                    if (index == 0) {
                      homeKey.currentState?.fetchApartments();
                    }
                    setState(() {
                      numberScreen = index;
                    });
                  },
                  tabs: [
                    GButton(icon: Icons.home, text: 'Home'),
                    GButton(icon: Icons.favorite, text: 'Favorite'),
                    GButton(icon: Icons.list_alt, text: 'Reservations'),
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
