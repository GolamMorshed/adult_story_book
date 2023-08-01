import 'package:flutter/material.dart';
import 'package:adult_story_book/screens/login.dart';
import 'package:adult_story_book/screens/forgotpassword.dart';

class Registration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: RegistrationPage(),
    );
  }
}

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full name',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _register,
                child: Text('Register'),
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: _navigateToLogin,
              child: Text('Already have an account? Login'),
            ),
            TextButton(
              onPressed: _forgotPassword,
              child: Text('Forgot Password?'),
            ),
          ],
        ),
      ),
    );
  }

  void _register() {

    // showDialog(
    //   context: context,
    //   builder: (context) => AlertDialog(
    //     title: Text('Registration Successful'),
    //     content: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       mainAxisSize: MainAxisSize.min,
    //       children: [
    //         Text('Name: $name'),
    //         Text('Username: $username'),
    //         Text('Email: $email'),
    //         Text('Password: $password'),
    //       ],
    //     ),
    //     actions: [
    //       TextButton(
    //         onPressed: () => Navigator.of(context).pop(),
    //         child: Text('OK'),
    //       ),
    //     ],
    //   ),
    // );
  }

  void _navigateToLogin() {
    Navigator.push(
      context, // the current build context
      MaterialPageRoute(
        builder: (context) => Login(),
      ),
    );
  }
  
  void _forgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
    );
  }
}



