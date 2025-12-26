import 'package:flats_app/MainLayout.dart';
import 'package:flats_app/Screens/chatScreen.dart';
import 'package:flats_app/Screens/favoriteScreen.dart';
import 'package:flats_app/Screens/filtered_apartments_screen.dart';
import 'package:flats_app/Screens/homeScreen.dart';
import 'package:flats_app/Screens/profileScreen.dart';
import 'package:flats_app/Screens/showScreen.dart';
import 'package:flats_app/authentication_screens/onboarding_screens.dart';
import 'package:flats_app/authentication_screens/waiting_for_acception.dart';
import 'package:flats_app/lessor/ListApartmentScreen.dart';
import 'package:flats_app/lessor/homePage.dart';
import 'package:flats_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/Reservations.dart';
import 'Screens/seeAllScreen.dart';
import 'authentication_screens/complete_profile_screen.dart';
import 'authentication_screens/login_screen.dart';
import 'authentication_screens/register_screen.dart';
import 'authentication_screens/splash_screen.dart';
import 'lessor/EditeApartment_lessor.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
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
      themeMode: ThemeMode.system,

      routes: {
        ShowScreen.id: (context) => ShowScreen(),
        Homescreen.id: (context) => Homescreen(),
        See_all_screen.id: (context) => See_all_screen(),
        FavoriteScreen.id: (context) => FavoriteScreen(),
        ChatScreen.id: (context) => ChatScreen(),
        ProfileScreen.id: (context) => ProfileScreen(),
        MainlayoutScreen.id: (context) => MainlayoutScreen(),
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
        List_Apatment.id: (context) => List_Apatment(),
        EditeapartmentLessor.id:(context)=>EditeapartmentLessor(),

  },

      home: FutureBuilder<Widget>(
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
      )
    );
  }
}
