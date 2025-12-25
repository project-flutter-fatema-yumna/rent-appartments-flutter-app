import 'package:flats_app/models/user_data.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/text_field_widget.dart';
import 'complete_profile_screen.dart';
import 'login_screen.dart';

String _currentState = 'tenant';

class RegisterScreen extends StatefulWidget {
  static String id = 'RegisterScreen';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TapGestureRecognizer _loginRecognizer;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  UserData user = UserData();
  String? _errorText;
  final bool _hidePassword = true;

  @override
  void initState() {
    super.initState();
    _loginRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.pushReplacementNamed(context, LoginScreen.id);
      };
  }

  @override
  void dispose() {
    _loginRecognizer.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _tryVerify() {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    setState(() {
      _errorText = null;
    });
    if (password.isEmpty || phone.isEmpty || confirmPassword.isEmpty) {
      setState(() => _errorText = 'Please fill all fields');
      return;
    }
    final phoneDigits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (phoneDigits.length < 10) {
      setState(() => _errorText = 'Phone number must be exactly 10 digits');
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
    if (password != confirmPassword) {
      setState(() => _errorText = 'Password and confirmation do not match');
      return;
    }
    user.phone = phone;
    user.password = password;
    user.passwordConfirmation = confirmPassword;
    user.role = _currentState;
    Navigator.pushNamed(context, CompleteProfileScreen.id, arguments: user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentGeometry.center,
                end: AlignmentGeometry.bottomCenter,
                colors: [
                  Colors.blue.shade50,
                  Colors.blue.shade50,
                  Colors.blue.shade100,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 150,
                    width: 150,
                    child: Image.asset('assets/yumna.png', fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Create account',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 34),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Unlock your personalized experience!',
                    style: TextStyle(fontSize: 16),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 30, 50, 12),
                    child: TextFieldWidget(
                      controller: _phoneController,
                      hint: 'Phone number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 0, 50, 12),
                    child: TextFieldWidget(
                      controller: _passwordController,
                      hint: 'Password (min 8 chars)',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: _hidePassword,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 0, 50, 12),
                    child: TextFieldWidget(
                      controller: _confirmPasswordController,
                      hint: 'Confirm password',
                      icon: Icons.lock,
                      isPassword: true,
                      obscureText: _hidePassword,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 65.0,
                      vertical: 20,
                    ),
                    child: Row(
                      children: [
                        RegisterAs(
                          role: 'tenant',
                          onTap: () {
                            setState(() {
                              _currentState = 'tenant';
                            });
                          },
                        ),
                        SizedBox(width: 10),
                        RegisterAs(
                          role: 'lessor',
                          onTap: () {
                            setState(() {
                              _currentState = 'lessor';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: MaterialButton(
                        onPressed: _tryVerify,
                        color: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 70,
                          vertical: 12,
                        ),
                        child: const Text(
                          'Verify',
                          style: TextStyle(color: Colors.white, fontSize: 17),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: "Login",
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: _loginRecognizer,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class RegisterAs extends StatelessWidget {
  String role = 'tenant';
  VoidCallback onTap;
  RegisterAs({required this.role, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 3,
          color: _currentState == role ? Colors.blue[50] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _currentState == role ? Colors.blue : Colors.grey.shade300,
              width: _currentState == role ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(
                  role == 'tenant' ? Icons.person : Icons.house,
                  color: _currentState == role ? Colors.blue : Colors.grey,
                ),
                SizedBox(height: 6),
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 16,
                    color: _currentState == role ? Colors.blue : Colors.grey,
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
