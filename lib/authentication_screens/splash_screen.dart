import 'package:easy_localization/easy_localization.dart';
import 'package:flats_app/MainLayout.dart';
import 'package:flats_app/authentication_screens/login_screen.dart';
import 'package:flats_app/authentication_screens/onboarding_screens.dart';
import 'package:flats_app/lessor/homePage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../select_language_screen.dart';

class SplashScreen extends StatefulWidget {
  static String id = 'SplashScreen';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedLangCode = prefs.getString('lang_code');

      if (savedLangCode == null) {
        Navigator.pushReplacementNamed(context, SelectLanguageScreen.id);
        return;
      }

      bool? isOnboardingSeen = prefs.getBool('seen');
      bool? isLoggedIn = prefs.getBool('isLoggedIn');
      if (isOnboardingSeen == true) {
        if(isLoggedIn==true){
          if (prefs.getString('role') == 'tenant') {
            Navigator.pushReplacementNamed(context, MainlayoutScreen.id);
          } else {
            Navigator.pushReplacementNamed(context, Homepage.id);
          }
        }else{
          Navigator.pushReplacementNamed(context, LoginScreen.id);
        }
      } else {
        Navigator.pushReplacementNamed(context, OnboardingScreen.id);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo.png'),
                Text(
                  'Easy booking, comfortable living'.tr(),
                  style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
