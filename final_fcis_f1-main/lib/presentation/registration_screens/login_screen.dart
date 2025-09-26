import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/colors_manager.dart';
import '../../core/utils/routes_manager.dart';
import '../../presentation/home/tabs/material_posts_tab/components/post_storage_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isFirstRun = true;

  @override
  void initState() {
    super.initState();
    _checkFirstRun();
  }

  Future<void> _checkFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFirstRun = prefs.getBool('isFirstRun') ?? true;
    });

    if (_isFirstRun) {
      await PostStorageService().clearAllPosts();
      await prefs.clear();
      await prefs.setBool('isFirstRun', false);
    }
  }

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userKey = 'user_$email';
    String? savedPassword = prefs.getString('$userKey.password');

    await Future.delayed(Duration(seconds: 1)); // Simulate network delay

    if (savedPassword == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No account found with this email')),
      );
      return;
    }

    if (password == savedPassword) {
      // Save all session data
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('currentUserEmail', email);
      await prefs.setString(
          'userId', prefs.getString('$userKey.userId') ?? email);

      // Save user profile data to session
      await prefs.setString(
          'userName', prefs.getString('$userKey.fullName') ?? 'Anonymous');
      await prefs.setString(
          'userImage', prefs.getString('$userKey.profileImagePath') ?? '');
      await prefs.setString(
          'jobTitle', prefs.getString('$userKey.jobTitle') ?? '');
      await prefs.setString(
          'userStatus', prefs.getString('$userKey.status') ?? 'Student');

      // Save interests to session
      await prefs.setStringList(
          'userInterests', prefs.getStringList('$userKey.interests') ?? []);

      // Ensure user is in registered_users list
      List<String> users = prefs.getStringList('registered_users') ?? [];
      if (!users.contains(email)) {
        users.add(email);
        await prefs.setStringList('registered_users', users);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful')),
      );

      Navigator.pushReplacementNamed(context, RoutsManager.mainScrean);
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Incorrect password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Text(
                    'FCIS F1',
                    style: TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                      color: ColorsManager.darkGrey,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                _buildEmailField(),
                SizedBox(height: 20),
                _buildPasswordField(),
                SizedBox(height: 40),
                _isLoading
                    ? CircularProgressIndicator(color: Colors.black)
                    : _buildLoginButton(),
                SizedBox(height: 20),
                _buildSignUpLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Email",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
        SizedBox(height: 15),
        TextField(
          controller: _emailController,
          decoration: _inputDecoration("Email"),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Password",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
        SizedBox(height: 15),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: _inputDecoration("Password"),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      hintStyle: const TextStyle(color: Colors.grey),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.grey),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: Size(240, 40),
        backgroundColor: Colors.black,
      ),
      onPressed: _login,
      child:
          Text('Login', style: TextStyle(color: ColorsManager.backGroundColor)),
    );
  }

  Widget _buildSignUpLink() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, RoutsManager.signUpScreen);
      },
      child: Text(
        "Create Account",
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15,
          color: Colors.black,
        ),
      ),
    );
  }
}
