import 'dart:io';

import 'package:flats_app/Services/log_out.dart';
import 'package:flats_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class profileLessor extends StatefulWidget {
  static String id = 'profileLessor';
  final VoidCallback? toggleTheme;
  const profileLessor({super.key, this.toggleTheme});
  @override
  State<profileLessor> createState() => _profileLessorState();
}

class _profileLessorState extends State<profileLessor> {
  bool isDarkMode = false;
  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool savedDark = prefs.getBool('isDarkMode') ?? false;
    setState(() {
      isDarkMode = savedDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue[50],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(0.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: CircleAvatar(
                    radius: 85,
                    backgroundImage: user!.personalPhoto != null
                        ? FileImage(File(user.personalPhoto!.path))
                        : AssetImage('assets/img_2.png'),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Account info',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _readOnlyField(label: 'First name', value: user.firstName),
              _readOnlyField(label: 'Last name', value: user.lastName),
              _readOnlyField(
                label: 'Date of birth',
                value: user.dateOfBirth ?? '',
              ),
              _readOnlyField(label: 'Phone number', value: user.phone),
              const SizedBox(height: 15),
              const Text(
                'Identity photo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1.5),
                  image: user.identityPhoto != null
                      ? DecorationImage(
                    image: FileImage(File(user.identityPhoto!.path)),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _readOnlyField({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          floatingLabelStyle: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w600,
          ),
          suffixIcon: const Icon(Icons.lock_outline, size: 18),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 1.5),
          ),
        ),
        controller: TextEditingController(text: value),
      ),
    );
  }
}
