import 'dart:io';

import 'package:flats_app/Services/log_out.dart';
import 'package:flats_app/main.dart';
import 'package:flats_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  static String id = 'ProfileScreen';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isDarkMode = false;
  
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
              const Divider(),
              const Text(
                'Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark mode'),
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    // setState(() {
                    //   isDarkMode = value;
                    //   MyApp.of(context)!.setThemeMode(
                    //     isDarkMode ? ThemeMode.dark : ThemeMode.light,
                    //   );
                    // }
                    //);
                  },
                ),
              ),

              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                trailing: Text(
                  'English',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                onTap: () {},
              ),
              const SizedBox(height: 15),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Log out',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  await logout(context);
                },
              ),
              SizedBox(height: 100,)
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
