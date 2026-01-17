import 'dart:convert';
import 'package:flats_app/MainLayout.dart';
import 'package:flats_app/authentication_screens/register_screen.dart';
import 'package:flats_app/global_data.dart';
import 'package:flats_app/lessor/homePage.dart';
import 'package:flats_app/widgets/snack_bar.dart';
import 'package:flats_app/models/user_data.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../helper/Host.dart';
import '../widgets/text_field_widget.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';


class LoginScreen extends StatefulWidget {
  static String id = 'LoginScreen';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TapGestureRecognizer _signUpRecognizer;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorText;
  bool _isLoading = false;
  bool _hidePassword = true;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _signUpRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.pushReplacementNamed(context, RegisterScreen.id);
      };
  }

  @override
  void dispose() {
    _signUpRecognizer.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _tryLogin() {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    setState(() {
      _errorText = null;
    });
    if (phone.isEmpty) {
      setState(() => _errorText = 'Please enter phone number');
      return;
    }
    final phoneDigits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (phoneDigits.length < 10) {
      setState(() => _errorText = 'Phone number must be exactly 10 digits');
      return;
    }
    if (!phoneDigits.startsWith('09')) {
      setState(() => _errorText = 'error_phone_start_09'.tr());
      return;
    }
    if (password.length < 8) {
      setState(() => _errorText = 'error_password_min_8'.tr());
      return;
    }
    login(_phoneController.text, _passwordController.text);
  }

  Future login(String phone, String password) async {
    try {
      setState(() {
        _isLoading = true;
      });
      var response = await http.post(
        Uri.parse('http://${Host.host}:8000/api/login'),
        headers: {"Content-Type": 'application/json'},
        body: jsonEncode({'phone': phone, 'password': password}),
      );
      //print(response.statusCode);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final jsonMap = decoded['user'];
        final token = decoded['token'];
        UserData user = await UserData.fromJson(jsonMap);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('phone', user.phone);
        await prefs.setString('firstName', user.firstName);
        await prefs.setString('lastName', user.lastName);
        await prefs.setString('userName', user.userName);
        await prefs.setString('dob', user.dateOfBirth ?? '');
        await prefs.setString('role', user.role);
        await prefs.setInt('userId', user.id!);
        userId = user.id;

        if (user.personalPhotoUrl != null) {
          await prefs.setString('personalPhotoUrl', user.personalPhotoUrl!);
        }

        if (user.identityPhotoUrl != null) {
          await prefs.setString('identityPhotoUrl', user.identityPhotoUrl!);
        }
        prefs.setString('token', token);
        userToken = token;
        userId = user.id;


        prefs.setBool('isLoggedIn', true);
        if (prefs.getString('role') == 'tenant') {
          Navigator.pushReplacementNamed(context, MainlayoutScreen.id);
        } else {
          Navigator.pushReplacementNamed(context, Homepage.id);
        }
      } else if (response.statusCode == 401) {
        mySnackBar(context, 'Wrong password or phone number');
      } else if (response.statusCode == 500) {
        mySnackBar(context, 'error connection');
      }
    } catch (e) {
      print(e);
      mySnackBar(context, 'Something went wrong');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).cardColor,
                radius: 70,
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).primaryColor,
                  size: 100,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'login'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 34),
              ),
              SizedBox(height: 20),
              Text(
                'login_subtitle'.tr(),
                style: TextStyle(fontSize: 17),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 18),
                child: TextFieldWidget(
                  controller: _phoneController,
                  hint: 'phone_number'.tr(),
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 18),
                child: TextFieldWidget(
                  controller: _passwordController,
                  hint: 'password_hint'.tr(),
                  icon: Icons.lock,
                  isPassword: true,
                  obscureText: _hidePassword,
                  textInputAction: TextInputAction.done,
                  onToggleVisibility: () {
                    setState(() => _hidePassword = !_hidePassword);
                  },
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    _errorText!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: _isLoading
                      ? CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                        )
                      : MaterialButton(
                          onPressed: _tryLogin,
                          color: Theme.of(context).primaryColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: 70,
                            vertical: 10,
                          ),
                          child: Text(
                            'login'.tr(),
                            style: TextStyle(color: Colors.white, fontSize: 17),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      text: "dont_have_account".tr(),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                      children: [
                        TextSpan(
                          text: "sign_up".tr(),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: _signUpRecognizer,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
