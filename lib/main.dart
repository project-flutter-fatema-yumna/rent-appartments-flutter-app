import 'package:flats_app/MainLayout.dart';
import 'package:flats_app/Screens/favoriteScreen.dart';
import 'package:flats_app/Screens/filtered_apartments_screen.dart';
import 'package:flats_app/Screens/homeScreen.dart';
import 'package:flats_app/Screens/profileScreen.dart';
import 'package:flats_app/Screens/showScreen.dart';
import 'package:flats_app/authentication_screens/onboarding_screens.dart';
import 'package:flats_app/authentication_screens/waiting_for_acception.dart';
import 'package:flats_app/lessor/ListApartmentScreen.dart';
import 'package:flats_app/lessor/homePage.dart';
import 'package:flats_app/providers/notification_provider.dart';
import 'package:flats_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/NoticesScreen.dart';
import 'Screens/Reservations.dart';
import 'Screens/seeAllScreen.dart';
import 'Screens/walletTenantScreens/homCardTenant.dart';
import 'authentication_screens/complete_profile_screen.dart';
import 'authentication_screens/login_screen.dart';
import 'authentication_screens/register_screen.dart';
import 'authentication_screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'lessor/EditeApartment_lessor.dart';
import 'lessor/OrdersScreen.dart';
import 'lessor/about_screen.dart';
import 'lessor/chat/chatSecondScreen.dart';
import 'lessor/chat/homeChatScreen.dart';
import 'lessor/help_support_screen.dart';
import 'lessor/notificationsLessorScreen.dart';
import 'lessor/profileLessor.dart';
import 'lessor/tenantScreen.dart';
import 'lessor/walletLessorScreens/homCardLessor.dart';
import 'noti_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initNotification();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
  runApp(
    OverlaySupport.global(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => notification_provider()),
        ],
        child: MyApp(isDarkMode: isDarkMode),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;

  const MyApp({super.key, required this.isDarkMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() async {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
  }

  Future<Widget> decisionScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isRegistered = prefs.getBool('isRegistered');
    if (isRegistered == true) {
      return WaitingForAcception();
    } else {
      return SplashScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      themeMode: _themeMode,

      routes: {
        ShowScreen.id: (context) => ShowScreen(),
        Homescreen.id: (context) => Homescreen(),
        See_all_screen.id: (context) => See_all_screen(),
        FavoriteScreen.id: (context) => FavoriteScreen(),
        ProfileScreen.id: (context) => ProfileScreen(toggleTheme: null),
        MainlayoutScreen.id: (context) =>
            MainlayoutScreen(toggleTheme: toggleTheme),
        CompleteProfileScreen.id: (context) => CompleteProfileScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegisterScreen.id: (context) => RegisterScreen(),
        SplashScreen.id: (context) => SplashScreen(),
        OnboardingScreen.id: (context) => OnboardingScreen(),
        WaitingForAcception.id: (context) => WaitingForAcception(),
        FilteredApartmentsScreen.id: (context) => FilteredApartmentsScreen(),
        Homepage.id: (context) => Homepage(),
        List_Apatment.id: (context) => List_Apatment(),
        ReservationsScreen.id: (context) => ReservationsScreen(),
        EditeapartmentLessor.id: (context) => EditeapartmentLessor(),
        // ApartmentDetailsSheet.id:(context)=>ApartmentDetailsSheet(),
        OrdersScreen.id: (context) => OrdersScreen(),
        profileLessor.id: (context) => profileLessor(),
        notificationsLessor.id: (context) => notificationsLessor(),
        notificationScreen.id: (context) => notificationScreen(),
        LessorWalletScreen.id: (context) => LessorWalletScreen(),
        TenantWalletScreen.id:(context)=>TenantWalletScreen(),
        tenants_Screen.id: (context) => tenants_Screen(),
        HelpSupportScreen.id:(context)=>HelpSupportScreen(),
        AboutScreen.id:(context)=>AboutScreen(),
      },
      home:
          // Homepage()
         FutureBuilder<Widget>(
            future: decisionScreen(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return const Scaffold(
                  body: Center(child: Text('Something went wrong')),
                );
              }
              return snapshot.data!;
            },
          ),
    );
  }
}
