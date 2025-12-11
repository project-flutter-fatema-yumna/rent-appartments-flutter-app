import 'dart:convert';
import 'dart:io';
import 'package:flats_app/authentication_screens/waiting_for_acception.dart';
import 'package:flats_app/models/register_data.dart';
import 'package:flats_app/models/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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
  late RegisterData user;
  bool _isLoaded = false;
  bool _isLoading = false;
  @override
  void didChangeDependencies() {
    if (!_isLoaded) {
      user = ModalRoute.of(context)!.settings.arguments as RegisterData;
      _isLoaded = true;
    }
    super.didChangeDependencies();
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
        } else {
          _idImage = image;
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
    print("DOB TEXT = '${_dateOfBirthController.text}'");
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: Colors.blue),
          textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.blue),
        ),
        child: child!,
      ),
    );

    if (pickedDate != null) {
      setState(() {
        _dateOfBirthController.text =
            "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
      });
    }
  }

  void _tryRegister() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    setState(() => _errorText = null);
    if (firstName.isEmpty || lastName.isEmpty) {
      setState(() => _errorText = 'Please enter your full name');
      return;
    }
    if (_dateOfBirthController.text.isEmpty) {
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
    // DateTime parsedDate = DateFormat(
    //   'dd/MM/yyyy',
    // ).parse(_dateOfBirthController.text);
    // user.dateOfBirth = DateFormat('yyyy-MM-dd').format(parsedDate);
    user.personalPhoto = _profileImage;
    user.identityPhoto = _idImage;
    register(user);
  }

  Future register(RegisterData user) async {
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
      //request.fields['date_of_birth'] = user.dateOfBirth;

      request.files.add(
        await http.MultipartFile.fromPath(
          'identityPhoto',
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
      if (response.statusCode == 201) {
        var json = jsonDecode(response.body);
        
        Navigator.pushReplacementNamed(context, WaitingForAcception.id);
      } else if (response.statusCode == 422) {
        mySnackBar(context, 'The phone has already been taken');
      } else {
        mySnackBar(context, 'Something went wrong');
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
