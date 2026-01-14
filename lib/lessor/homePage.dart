import 'dart:async';

import 'package:flats_app/Screens/profileScreen.dart';
import 'package:flats_app/global_data.dart';
import 'package:flats_app/lessor/tenantScreen.dart';
import 'package:flats_app/lessor/walletLessorScreens/homCardLessor.dart';
import 'package:flats_app/providers/notification_provider.dart';
import 'package:flats_app/providers/user_provider.dart';
import 'package:flats_app/widgets/personal_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  final VoidCallback toggleTheme;
  const Homepage({super.key, required this.toggleTheme});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    context.read<UserProvider>().setUserFromPrefs();
    final String token = userToken;

    Future.microtask(() async {
      final provi = context.read<notification_provider>();

      provi.onNewNotifications = (newOnes) {
        for (final n in newOnes) {
          showSimpleNotification(
            Text(
              n.data.message.isEmpty ? "New notification" : n.data.message,
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
        backgroundColor: Theme.of(context).cardColor,
        drawer: DrawerProfile(toggleTheme: widget.toggleTheme),
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
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
                        Icons.notifications,
                        color: Colors.white,
                      ),
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
                              minWidth: 18,
                              minHeight: 18,
                            ),
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
              labelColor: Theme.of(context).primaryColor,
              indicatorColor: Theme.of(context).primaryColor,
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
                  Chat_Screen(),
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
  final VoidCallback toggleTheme;
  const DrawerProfile({super.key, required this.toggleTheme});

  @override
  State<DrawerProfile> createState() => _DrawerProfileState();
}

class _DrawerProfileState extends State<DrawerProfile> {

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    if (user == null) {
      return SpinKitThreeBounce(
        color: Theme.of(context).primaryColor,
        size: 20,
      );
    }
    return Drawer(
      backgroundColor: Theme.of(context).cardColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
              child: Row(
                children: [
                  personalImage(user, 25),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.userName??'Guest',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.color,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.phone ?? "0988892049",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.color,
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ProfileScreen(toggleTheme: widget.toggleTheme),
                  ),
                );
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
                Navigator.pushNamed(context, tenants_Screen.id);
              },
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 20),
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
