import 'package:flats_app/Services/log_out.dart';
import 'package:flats_app/providers/user_provider.dart';
import 'package:flats_app/widgets/personal_image.dart';
import 'package:flats_app/widgets/identity_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart'; // ⬅️ مهم

import '../authentication_screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  static String id = 'ProfileScreen';
  final VoidCallback? toggleTheme;
  const ProfileScreen({super.key, this.toggleTheme});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: user!.role == 'tenant' ? false : true,
        title: Text(
          'profile'.tr(), // ⬅️ Profile
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge!.color!,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  child: personalImage(user, 85),
                ),
              ),
              const SizedBox(height: 30),

              // Account info title
              Text(
                'account_info'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 15),

              // Fields
              _readOnlyField(
                label: 'first_name'.tr(),
                value: user.firstName,
              ),
              _readOnlyField(
                label: 'last_name'.tr(),
                value: user.lastName,
              ),
              _readOnlyField(
                label: 'date_of_birth'.tr(),
                value: user.dateOfBirth ?? '',
              ),
              _readOnlyField(
                label: 'phone_number'.tr(),
                value: user.phone,
              ),

              const SizedBox(height: 15),
              Text(
                'identity_photo'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 15),
              identityImage(user),
              const SizedBox(height: 15),
              Divider(color: Theme.of(context).textTheme.bodyLarge!.color!),

              Text(
                'settings'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 15),

              // Dark mode tile
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: Text(
                  'dark_mode'.tr(),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                trailing: Switch(
                  activeColor: Theme.of(context).primaryColor,
                  value: isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      isDarkMode = value;
                    });
                    widget.toggleTheme?.call();
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(
                  'language'.tr(),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                trailing: DropdownButton<String>(
                  value: context.locale.languageCode,
                  underline: const SizedBox(),
                  dropdownColor: Theme.of(context).cardColor,
                  items: const [
                    DropdownMenuItem(
                      value: 'en',
                      child: Text('English'),
                    ),
                    DropdownMenuItem(
                      value: 'ar',
                      child: Text('العربية'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    final newLocale = Locale(value);
                    context.setLocale(newLocale);  // 👈 تغيير اللغة فعلياً
                  },
                ),
              ),
              Divider(color: Theme.of(context).textTheme.bodyLarge!.color!),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title:  Text(
                  'logout'.tr(),
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  await logout(context);
                },
              ),
              const SizedBox(height: 100),
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
          floatingLabelStyle: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
          ),
          suffixIcon: const Icon(Icons.lock_outline, size: 18),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 1.5,
            ),
          ),
        ),
        controller: TextEditingController(text: value),
      ),
    );
  }
}
