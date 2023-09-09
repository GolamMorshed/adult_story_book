import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:adult_story_book/screens/dashboard.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final String _apiUrl = 'http://127.0.0.1:8000/api/login'; // Replace with your API URL
  bool _loginFailed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
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
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
            if (_loginFailed)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Invalid email or password',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    // Create a Map with the credentials to send in the request body
    Map<String, String> credentials = {
      'email': email,
      'password': password,
    };

    // Send a POST request to your API
    final response = await http.post(
      Uri.parse(_apiUrl),
      body: credentials,
    );

    if (response.statusCode == 200) {
      // Successful login
      final Map<String, dynamic> data = jsonDecode(response.body);
      print(data);

      // Check if 'user' field is present and it's a Map
      if (data.containsKey('user') && data['user'] is Map<String, dynamic>) {
        Map<String, dynamic> userData = data['user'] as Map<String, dynamic>;
        print('Login successful. User ID: ${userData['id']}');

        // Extract the user ID from the response data
        String userId = userData['id'].toString();

        // Navigate to the Dashboard screen with the userId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardApp(userId: userId),
          ),
        );

        setState(() {
          _loginFailed = false;
        });
      } else {
        // 'user' field is missing or not a Map
        setState(() {
          _loginFailed = true;
        });
      }
    } else {
      // Login failed
      setState(() {
        _loginFailed = true;
      });
    }
  }

}

void main() {
  runApp(MaterialApp(
    home: LoginScreen(),
  ));
}
