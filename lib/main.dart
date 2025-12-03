import 'package:flats_app/MainLayout.dart';
import 'package:flats_app/Screens/chatScreen.dart';
import 'package:flats_app/Screens/favoriteScreen.dart';
import 'package:flats_app/Screens/homeScreen.dart';
import 'package:flats_app/Screens/profileScreen.dart';
import 'package:flats_app/Screens/showScreen.dart';
import 'package:flats_app/widgets/cardHome.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Screens/seeAllScreen.dart';

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
    },
      debugShowCheckedModeBanner: false,
      home :MainlayoutScreen()
    );
  }
}
