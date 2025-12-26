import 'dart:async';

import 'package:flats_app/MainLayout.dart';
import 'package:flats_app/Services/check_user_status.dart';
import 'package:flats_app/Services/create_token.dart';
import 'package:flats_app/authentication_screens/login_screen.dart';
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
      await prefs.setString('token', token);
      prefs.setBool('isLoggedIn', true);
      prefs.setBool('isRegistered', false);
      _loggingIn = false;
      Navigator.pushReplacementNamed(context, MainlayoutScreen.id);
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
      backgroundColor: const Color(0xFFE3F2FD),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 90),
              child: Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _status == 'pending'
                          ? 'Your account is pending admin approval!'
                          : (_status == 'active')
                          ? 'You are active!'
                          : 'Sorry, your account is rejected',

                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Image.asset(
                      _status == 'pending'
                          ? 'assets/undraw_season-change_ohe6.png'
                          : (_status == 'active')
                          ? 'assets/undraw_order-confirmed_m9e9.png'
                          : 'assets/undraw_access-denied_krem.png',
                      height: 200,
                      width: 400,
                    ),
                    _status == 'active'
                        ? _loggingIn
                              ? CircularProgressIndicator(color: Colors.blue)
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
