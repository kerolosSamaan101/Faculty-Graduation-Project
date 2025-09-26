import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/utils/routes_manager.dart';

const List<String> interestOptions = [
  'Software Testing',
  'Flutter',
  'Cyber Security',
  'ML & DL',
  'Game Development',
  'Other'
];

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _controllers =
      List.generate(13, (_) => TextEditingController());
  List<bool> _selectedInterests = List.filled(interestOptions.length, false);

  // Controllers index mapping
  int get fullName => 0;
  int get email => 1;
  int get password => 2;
  int get confirmPassword => 3;
  int get university => 4;
  int get college => 5;
  int get academicYear => 6;
  int get phoneNumber => 7;
  int get linkedIn => 8;
  int get location => 9;
  int get bio => 10;
  int get skills => 11;
  int get jobTitle => 12;

  String selectedStatus = 'Student';
  final List<String> statuses = [
    'Student',
    'Graduate',
    'Employee',
    'Company Representative'
  ];
  File? _profileImage;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  Future<void> saveUserData() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final email = _controllers[this.email].text.trim();
      final userKey = 'user_$email';

      // Save all user data
      await prefs.setString(
          '$userKey.fullName', _controllers[fullName].text.trim());
      await prefs.setString('$userKey.email', email);
      await prefs.setString(
          '$userKey.password', _controllers[password].text.trim());
      await prefs.setString(
          '$userKey.university', _controllers[university].text.trim());
      await prefs.setString(
          '$userKey.college', _controllers[college].text.trim());
      await prefs.setString(
          '$userKey.academicYear', _controllers[academicYear].text.trim());
      await prefs.setString(
          '$userKey.jobTitle', _controllers[jobTitle].text.trim());
      await prefs.setString(
          '$userKey.phoneNumber', _controllers[phoneNumber].text.trim());
      await prefs.setString(
          '$userKey.linkedIn', _controllers[linkedIn].text.trim());
      await prefs.setString(
          '$userKey.location', _controllers[location].text.trim());
      await prefs.setString('$userKey.bio', _controllers[bio].text.trim());
      await prefs.setString(
          '$userKey.skills', _controllers[skills].text.trim());
      await prefs.setString('$userKey.status', selectedStatus);

      // Save interests (ensure at least one is selected)
      final selected = [
        for (var i = 0; i < interestOptions.length; i++)
          if (_selectedInterests[i]) interestOptions[i]
      ];

      if (selected.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select at least one interest')),
        );
        return;
      }

      await prefs.setStringList('$userKey.interests', selected);

      // Save profile image path if selected
      if (_profileImage != null) {
        await prefs.setString('$userKey.profileImagePath', _profileImage!.path);
      }

      // Add to registered users list
      List<String> users = prefs.getStringList('registered_users') ?? [];
      if (!users.contains(email)) {
        users.add(email);
        await prefs.setStringList('registered_users', users);
      }

      // Create a default user ID if not exists
      if (prefs.getString('$userKey.userId') == null) {
        await prefs.setString('$userKey.userId', email); // Using email as ID
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account created successfully!')),
      );

      Navigator.pushReplacementNamed(context, RoutsManager.loginScreen);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: ${e.toString()}')),
      );
    }
  }

  // Validation methods
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
      return 'Please enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 8) return 'Password must be at least 8 characters long';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _controllers[password].text) return 'Passwords do not match';
    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    return value == null || value.isEmpty
        ? 'Please enter your $fieldName'
        : null;
  }

  String? _validateJobTitle(String? value) {
    if (selectedStatus == 'Company Representative' &&
        (value == null || value.isEmpty)) {
      return 'Job title is required for Company Representatives';
    }
    return null;
  }

  Widget _buildInterestsSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Interests",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
        SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: List.generate(interestOptions.length, (index) {
            return FilterChip(
              label: Text(interestOptions[index]),
              selected: _selectedInterests[index],
              onSelected: (bool selected) {
                setState(() {
                  _selectedInterests[index] = selected;
                });
              },
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 40),
                Text("Sign Up",
                    style:
                        TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
                SizedBox(height: 40),
                _buildProfilePicture(),
                SizedBox(height: 10),
                _buildTextField(fullName, "Full Name",
                    validator: (v) => _validateRequired(v, "full name")),
                _buildTextField(email, "Email", validator: _validateEmail),
                _buildTextField(password, "Password",
                    obscureText: true, validator: _validatePassword),
                _buildTextField(confirmPassword, "Confirm Password",
                    obscureText: true, validator: _validateConfirmPassword),
                _buildTextField(university, "University",
                    validator: (v) => _validateRequired(v, "university")),
                _buildTextField(college, "College",
                    validator: (v) => _validateRequired(v, "college")),
                _buildTextField(academicYear, "Academic Year",
                    validator: (v) => _validateRequired(v, "academic year")),
                _buildStatusDropdown(),
                _buildTextField(jobTitle, "Job Title",
                    validator: _validateJobTitle),
                _buildTextField(phoneNumber, "Phone Number"),
                _buildTextField(linkedIn, "LinkedIn Profile (Optional)"),
                _buildTextField(location, "Location"),
                _buildTextField(bio, "Bio", maxLines: 3),
                _buildTextField(skills, "Skills"),
                SizedBox(height: 20),
                _buildInterestsSelection(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: saveUserData,
                  child: Text('Sign Up', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 50,
        backgroundImage:
            _profileImage != null ? FileImage(_profileImage!) : null,
        child: _profileImage == null ? Icon(Icons.add_a_photo, size: 50) : null,
      ),
    );
  }

  Widget _buildTextField(int index, String hintText,
      {bool obscureText = false,
      String? Function(String?)? validator,
      int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: _controllers[index],
        obscureText: obscureText,
        maxLines: maxLines,
        decoration: _inputDecoration(hintText),
        validator: validator,
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      hintStyle: TextStyle(color: Colors.grey),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildStatusDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: selectedStatus,
        items: statuses
            .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                ))
            .toList(),
        onChanged: (value) => setState(() => selectedStatus = value!),
        decoration: _inputDecoration('Status'),
      ),
    );
  }
}
