import 'dart:async';

import 'package:flats_app/MainLayout.dart';
import 'package:flats_app/Services/check_user_status.dart';
import 'package:flats_app/Services/create_token.dart';
import 'package:flats_app/authentication_screens/login_screen.dart';
import 'package:flats_app/global_data.dart';
import 'package:flats_app/lessor/homePage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaitingForAcception extends StatefulWidget {
  static String id = 'WaitingForAcceptionScreen';
  const WaitingForAcception({super.key});

  @override
  State<WaitingForAcception> createState() => _WaitingForAcceptionState();
}

class _WaitingForAcceptionState extends State<WaitingForAcception> {
  String? _status;
  Timer? timer;
  bool _isLoading = true;
  bool _loggingIn = false;

  void _startPolling() {
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_status != 'pending') {
        timer.cancel();
        return;
      }
      _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? phone = pref.getString('phone');

    if (phone == null) {
      setState(() {
        _status = 'error';
        _isLoading = false;
      });
      return;
    }
    try {
      String status = await getUserStatus(phone);
      setState(() {
        _status = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'error';
        _isLoading = false;
      });
    }
  }

  void _createToken() async {
    setState(() {
      _loggingIn = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phone = prefs.getString('phone');
    if (phone == null) {
      setState(() {
        _loggingIn = false;
      });
      return;
    }
    try {
      String token = await createToken(phone);
      print('////////////////////////');
      print(token);
      await prefs.setString('token', token);
      userToken = token;
      prefs.setBool('isLoggedIn', true);
      prefs.setBool('isRegistered', false);
      _loggingIn = false;
      print('////////////////////////////////////');
      print('role');
      print(prefs.getString('role'));
      if (prefs.getString('role') == 'tenant') {
        Navigator.pushReplacementNamed(context, MainlayoutScreen.id);
      } else {
        Navigator.pushReplacementNamed(context, Homepage.id);
      }
    } catch (e) {
      setState(() {
        _loggingIn = false;
      });
    }
  }

  void _rejected() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isRegistered', false);
    Navigator.pushReplacementNamed(context, LoginScreen.id);
  }

  @override
  void initState() {
    super.initState();
    _checkStatus();
    _startPolling();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 90),
              child: Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border.all(
                    color: Theme.of(context).textTheme.bodyLarge!.color!,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _status == 'pending'
                          ? 'Please wait while our admin reviews your information!'
                          : (_status == 'active')
                          ? 'Now, your account is active, you can start using the app!'
                          : 'Unfortunately... your account was not approved!',

                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                    Image.asset(
                      _status == 'pending'
                          ? 'assets/undraw_season-change_ohe6-removebg-preview.png'
                          : (_status == 'active')
                          ? 'assets/undraw_order-confirmed_m9e9-removebg-preview.png'
                          : 'assets/undraw_access-denied_krem-removebg-preview.png',
                      height: 200,
                      width: 400,
                    ),
                    _status == 'active'
                        ? _loggingIn
                              ? CircularProgressIndicator(
                                  color: Theme.of(context).primaryColor,
                                )
                              : MaterialButton(
                                  onPressed: () {
                                    _createToken();
                                  },
                                  color: Colors.green,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal: 40,
                                  ),
                                  child: Text(
                                    'Start',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                )
                        : _status != 'pending'
                        ? MaterialButton(
                            onPressed: () {
                              _rejected();
                            },
                            color: Colors.red,
                            padding: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 40,
                            ),
                            child: Text(
                              'Return',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          )
                        : SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}
