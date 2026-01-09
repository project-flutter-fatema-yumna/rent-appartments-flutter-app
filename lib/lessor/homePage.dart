import 'dart:async';

import 'package:flats_app/MyColors.dart';
import 'package:flats_app/lessor/profileLessor.dart';
import 'package:flats_app/lessor/tenantScreen.dart';
import 'package:flats_app/lessor/walletLessorScreens/homCardLessor.dart';
import 'package:flats_app/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/log_out.dart';
import 'AddApartmentScreen.dart';
import 'ListApartmentScreen.dart';
import 'OrdersScreen.dart';
import 'about_screen.dart';
import 'chat/homeChatScreen.dart';
import 'help_support_screen.dart';
import 'notificationsLessorScreen.dart';

class Homepage extends StatefulWidget {
  static String id = 'Homepage';
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final String token = '1|EZIEoy5aLnCdi5XP2jxeaGtnNT60yqCeYyfoaP0W9a2b30e6';

    Future.microtask(() async {
      final provi = context.read<notification_provider>();

      provi.onNewNotifications = (newOnes) {
        for (final n in newOnes) {
          showSimpleNotification(
            Text(
              n.data.message.isEmpty
                  ? "New notification"
                  : n.data.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              n.type
                  .split('\\')
                  .last,
              style: const TextStyle(fontSize: 12),
            ),
            background: Colors.blue,
            autoDismiss: true,
            slideDismissDirection: DismissDirection.up,
          );
        }
      };

     // final prefs = await SharedPreferences.getInstance();
      //final token = prefs.getString('token');

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
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: myColors.colorWhite,
        drawer: DrawerProfile(),
        appBar: AppBar(
          backgroundColor: Colors.blue,
          leading: Builder(
            builder: (context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: Icon(Icons.more_vert, color: Colors.white),
              );
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        Navigator.pushNamed(context, notificationsLessor.id);
                      },
                      icon: const Icon(
                          Icons.notifications, color: Colors.white),
                    ),
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Consumer<notification_provider>(
                        builder: (context, p, child) {
                          final List = p.unReadList;
                          if (List.isEmpty) return const SizedBox.shrink();

                          return Container(
                            constraints: const BoxConstraints(
                                minWidth: 18, minHeight: 18),
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              "${List.length}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
                Tab(child: Text('Chats', style: TextStyle(fontSize: 18))),

              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  addApartmentScreen(),
                  List_Apatment(),
                  OrdersScreen(),
                  Chat_Screen()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
class DrawerProfile extends StatefulWidget {
  @override
  State<DrawerProfile> createState() => _DrawerProfileState();
}

class _DrawerProfileState extends State<DrawerProfile> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.blue),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 30, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "User name",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "0988892049",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Menu items
            _Tile(
              icon: Icons.person_outline,
              title: "My Profile",
              onTap: () {
                Navigator.pushNamed(context, profileLessor.id);
              },
            ),
            _Tile(
              icon: Icons.home_work_outlined,
              title: "My Apartments",
              onTap: () {
                Navigator.pop(context);
                final controller = DefaultTabController.of(context);
                controller.animateTo(1);
              },
            ),
            _Tile(
              icon: Icons.receipt_long_outlined,
              title: "Orders",
              onTap: () {
                Navigator.pop(context);
                final controller = DefaultTabController.of(context);
                controller.animateTo(2);
              },
            ),
            _Tile(
              icon: Icons.credit_card_outlined,
              title: "My Wallet",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, LessorWalletScreen.id);
              },
            ),
            _Tile(
              icon: Icons.person_outline,
              title: "My Tenants",
              onTap: () {
                Navigator.pushNamed(context,tenants_Screen.id);
              },
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 20),
            ),

            _Tile(
              icon: Icons.language,
              title: "Language",
              onTap: () => Navigator.pop(context),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text(
                    "Dark Theme",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: Transform.scale(
                    scale: 0.7,
                    child: Switch(
                      value: isDark,
                      onChanged: (v) {
                        setState(() => isDark = v);
                      },
                    ),
                  ),
                ),
              ),
            ),
            _Tile(
              icon: Icons.help_outline,
              title: "Help & Support",
              onTap: () => Navigator.pushNamed(context, HelpSupportScreen.id),
            ),
            _Tile(
              icon: Icons.info_outline,
              title: "About",
              onTap: () => Navigator.pushNamed(context, AboutScreen.id),
            ),

            const Spacer(),

            // Logout
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await logout(context);
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _Tile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
