import 'package:flutter/material.dart';
import 'package:adult_story_book/screens/login.dart';
import 'package:adult_story_book/screens/registration.dart';
import 'package:adult_story_book/screens/dashboard.dart';
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'dashboard',
    routes: {
      'login': (context) => Login(),
      'registration': (context) => Registration(),
      'dashboard': (context) => Dashboard(),
    },
  ));
}