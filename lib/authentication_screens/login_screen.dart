import 'package:flats_app/authentication_screens/register_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../widgets/text_field_widget.dart';
//import 'package:rent_appartments_project/widgets/text_field_widget.dart';

class LoginScreen extends StatefulWidget {
  static String id='LoginScreen';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TapGestureRecognizer _signUpRecognizer;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorText;

  bool _hidePassword = true;

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
      setState(() => _errorText = 'Please enter a valid phone number');
      return;
    }
    if (!phoneDigits.startsWith('09')) {
      setState(() => _errorText = 'Phone number must start with 09');
      return;
    }
    if (password.length < 8) {
      setState(() => _errorText = 'Password must be at least 8 characters');
      return;
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: Image.asset(
                  'assets/yumna.png',
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Login',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 34),
              ),
              SizedBox(height: 20),
              Text(
                'Welcome back! Please enter your details',
                style: TextStyle(fontSize: 17),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 50, 50, 20),
                child: TextFieldWidget(
                  controller: _phoneController,
                  hint: 'Phone number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 0, 50, 20),
                child: TextFieldWidget(
                  controller: _passwordController,
                  hint: 'Password (min 8 chars)',
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
                  borderRadius: BorderRadiusGeometry.circular(30),
                  child: MaterialButton(
                    onPressed: _tryLogin,
                    color: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 70, vertical: 10),
                    child: Text(
                      'Login',
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
                      text: "Don't have an account? ",
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: "Sign up",
                          style: TextStyle(
                            color: Colors.blue,
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
