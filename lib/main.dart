import 'package:flats_app/MainLayout.dart';
import 'package:flats_app/Screens/chatScreen.dart';
import 'package:flats_app/Screens/favoriteScreen.dart';
import 'package:flats_app/Screens/homeScreen.dart';
import 'package:flats_app/Screens/profileScreen.dart';
import 'package:flats_app/Screens/showScreen.dart';
import 'package:flats_app/authentication_screens/onboarding_screens.dart';
import 'package:flutter/material.dart';

import 'Screens/seeAllScreen.dart';
import 'authentication_screens/complete_profile_screen.dart';
import 'authentication_screens/login_screen.dart';
import 'authentication_screens/register_screen.dart';
import 'authentication_screens/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      routes: {
        ShowScreen.id: (context) => ShowScreen(),
        Homescreen.id:(context)=> Homescreen(),
        See_all_screen.id:(context)=>See_all_screen(),
        FavoriteScreen.id:(context)=>FavoriteScreen(),
        ChatScreen.id:(context)=>ChatScreen(),
        ProfileScreen.id:(context)=>ProfileScreen(),
        MainlayoutScreen.id:(context)=>MainlayoutScreen(),
        CompleteProfileScreen.id:(context)=>CompleteProfileScreen(),
        LoginScreen.id:(context)=>LoginScreen(),
        RegisterScreen.id:(context)=>RegisterScreen(),
        SplashScreen.id:(context)=>SplashScreen(),
        OnboardingScreen.id:(context)=>OnboardingScreen()

    },
      debugShowCheckedModeBanner: false,
      home : SplashScreen()

    );
  }
}
