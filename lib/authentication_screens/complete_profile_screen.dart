import 'dart:convert';
import 'dart:io';
import 'package:flats_app/MainLayout.dart';
import 'package:flats_app/authentication_screens/waiting_for_acception.dart';
import 'package:flats_app/models/user_data.dart';
import 'package:flats_app/models/snack_bar.dart';
import 'package:flats_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/text_field_widget.dart';

class CompleteProfileScreen extends StatefulWidget {
  static String id = 'CompleteProfileScreen';
  CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();

  String? _errorText;
  XFile? _profileImage;
  XFile? _idImage;
  late UserData user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null) {
        user = args as UserData;
        _firstNameController.text = user.firstName;
        _lastNameController.text = user.lastName;
        _dateOfBirthController.text = user.dateOfBirth ?? '';
        _profileImage = user.personalPhoto;
        _idImage = user.identityPhoto;

        setState(() {});
      }
    });

    _firstNameController.addListener(() {
      user.firstName = _firstNameController.text;
    });
    _lastNameController.addListener(() {
      user.lastName = _lastNameController.text;
    });
    _dateOfBirthController.addListener(() {
      user.dateOfBirth = _dateOfBirthController.text;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, bool isProfile) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        if (isProfile) {
          _profileImage = image;
          user.personalPhoto = image;
        } else {
          _idImage = image;
          user.identityPhoto = image;
        }
      });
    }
  }

  Future<void> _showImageSourceSheet(
    BuildContext context,
    bool isProfile,
  ) async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Image Source',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, isProfile);
                },
              ),

              ListTile(
                leading: const Icon(Icons.image, color: Colors.blue),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, isProfile);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 1)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 1)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: Colors.blue),
          textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.blue),
        ),
        child: child!,
      ),
    );

    if (pickedDate != null) {
      final formatted =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      setState(() {
        _dateOfBirthController.text = formatted;
      });
      user.dateOfBirth = formatted;
    }
  }

  void _tryRegister() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final dob = _dateOfBirthController.text;
    setState(() => _errorText = null);
    if (firstName.isEmpty || lastName.isEmpty) {
      setState(() => _errorText = 'Please enter your full name');
      return;
    }
    if (dob.isEmpty) {
      setState(() => _errorText = 'Please select your date of birth');
      return;
    }
    if (_profileImage == null) {
      setState(() => _errorText = 'Please upload your photo');
      return;
    }
    if (_idImage == null) {
      setState(() => _errorText = 'Please upload your identity photo');
      return;
    }
    user.firstName = firstName;
    user.lastName = lastName;
    user.dateOfBirth = dob;
    user.personalPhoto = _profileImage;
    user.identityPhoto = _idImage;
    register(user);
  }

  Future register(UserData user) async {
    try {
      setState(() {
        _isLoading = true;
      });
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:8000/api/register'),
      );
      request.fields['first_name'] = user.firstName;
      request.fields['last_name'] = user.lastName;
      request.fields['phone'] = user.phone;
      request.fields['password'] = user.password;
      request.fields['password_confirmation'] = user.passwordConfirmation;
      request.fields['role'] = user.role;
      request.fields['date_of_birth'] = user.dateOfBirth!;
      request.headers['Accept'] = 'application/json';
      request.files.add(
        await http.MultipartFile.fromPath(
          'idenitityPhoto',
          user.identityPhoto!.path,
        ),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'personalPhoto',
          user.personalPhoto!.path,
        ),
      );
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 201) {
        var json = jsonDecode(response.body);
        user.id = json['user']['id'];
        user.userName = json['user']['username'];
        user.password = '';
        user.passwordConfirmation = '';
        user.status = 'pending';
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('phone', user.phone);
        prefs.setBool('isRegistered', true);

        if (!mounted) return;
        context.read<UserProvider>().setUserData(user);
        Navigator.pushReplacementNamed(context, WaitingForAcception.id);
      } else if (response.statusCode == 422) {
        if (!mounted) return;
        Navigator.of(context).pop();
        mySnackBar(context, 'The phone has already been taken');
      } else {
        if (!mounted) return;
        mySnackBar(context, 'Something went wrong');
      }
      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;
      mySnackBar(context, 'Something went wrong');
      print('$e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blue[50], toolbarHeight: 30),
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
                  GestureDetector(
                    onTap: () async {
                      await _showImageSourceSheet(context, true);
                    },
                    child: Container(
                      padding: EdgeInsets.all(0.05),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade400,
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _profileImage != null
                            ? FileImage(File(_profileImage!.path))
                            : null,
                        child: _profileImage == null
                            ? const Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Profile',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Let\'s complete your profile!',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.only(right: 30),
                    child: TextFieldWidget(
                      controller: _firstNameController,
                      hint: 'Enter your first name',
                      keyboardType: TextInputType.name,
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(right: 30),
                    child: TextFieldWidget(
                      controller: _lastNameController,
                      hint: 'Enter your last name',
                      keyboardType: TextInputType.name,
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(right: 30),
                    child: TextFieldWidget(
                      controller: _dateOfBirthController,
                      hint: 'Select your date of birth',
                      readOnly: true,
                      suffixIcon: Icon(Icons.cake),
                      onTap: () => _pickDate(),
                    ),
                  ),
                  if (_errorText != null) ...[
                    const SizedBox(height: 12),
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
                    padding: const EdgeInsets.only(top: 30),
                    child: GestureDetector(
                      onTap: () => _showImageSourceSheet(context, false),
                      child: Container(
                        width: 170,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade500),
                          image: _idImage != null
                              ? DecorationImage(
                                  image: FileImage(File(_idImage!.path)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _idImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.credit_card,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Upload ID Card",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.blue)
                          : MaterialButton(
                              onPressed: _tryRegister,
                              color: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 70,
                                vertical: 12,
                              ),
                              child: const Text(
                                'Register',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                              ),
                            ),
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
