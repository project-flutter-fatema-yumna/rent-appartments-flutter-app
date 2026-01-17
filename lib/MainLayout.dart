import 'dart:async';

import 'package:flats_app/Screens/Reservations.dart';
import 'package:flats_app/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/favoriteScreen.dart';
import 'Screens/homeScreen.dart';
import 'Screens/profileScreen.dart';
import 'chat/homeChatScreen.dart';
import 'package:easy_localization/easy_localization.dart';


class MainlayoutScreen extends StatefulWidget {
  static String id = 'MainlayoutScreen';
  final VoidCallback toggleTheme;

  const MainlayoutScreen({super.key, required this.toggleTheme});

  @override
  State<MainlayoutScreen> createState() => _MainlayoutScreenState();
}

class _MainlayoutScreenState extends State<MainlayoutScreen> {
  Timer? _timer;

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
      Chat_Screen(),
      ProfileScreen(toggleTheme: widget.toggleTheme),
    ];

    Future.microtask(() async {
      final provi = context.read<notification_provider>();

      provi.onNewNotifications = (newOnes) {
        for (final n in newOnes) {
          showSimpleNotification(
            Text(
              n.data.message.isEmpty
                  ? "new_notification".tr()
                  : n.data.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              n.type.split('\\').last,
              style: const TextStyle(fontSize: 12),
            ),
            background: Theme.of(context).primaryColor,
            autoDismiss: true,
            slideDismissDirection: DismissDirection.up,
          );
        }
      };

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        await provi.getNumberMesseageUnRead(token: token);

        _timer = Timer.periodic(const Duration(seconds: 30), (_) async {
          if (!mounted) return;
          await provi.getNumberMesseageUnRead(token: token);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
                      homeKey.currentState?.loadingFirstPage();
                    }
                    setState(() {
                      numberScreen = index;
                    });
                  },
                  tabs: [
                    GButton(icon: Icons.home, text: 'home'.tr()),
                    GButton(icon: Icons.favorite, text: 'favorites'.tr()),
                    GButton(icon: Icons.list_alt, text: 'my_reservations'.tr()),
                    GButton(icon: Icons.chat, text: 'chat'.tr()),
                    GButton(icon: Icons.person, text: 'profile'.tr()),
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
