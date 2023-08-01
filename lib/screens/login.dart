import 'package:flutter/material.dart';
import 'package:adult_story_book/screens/registration.dart';
import 'package:adult_story_book/screens/forgotpassword.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final String _validUsername = 'admin';
  final String _validPassword = 'password';
  bool _loginFailed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
            ),
            if (_loginFailed)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Invalid username or password',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(height: 16),
            TextButton(
              onPressed: _navigateToRegistration,
              child: Text('Create an account'),
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

  void _login() {
    String username = _usernameController.text.trim();
    String password = _passwordController.text;

    if (username == _validUsername && password == _validPassword) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Login Successful'),
          content: Text('Welcome, $username!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
      setState(() {
        _loginFailed = false;
      });
    } else {
      setState(() {
        _loginFailed = true;
      });
    }
  }

  void _navigateToRegistration() {

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistrationPage()),
    );
  }

  void _forgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
    );
  }
}
