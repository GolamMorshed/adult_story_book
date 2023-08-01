import 'package:flutter/material.dart';
import 'package:adult_story_book/screens/login.dart';
import 'package:adult_story_book/screens/registration.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'login',
    routes: {
      'login': (context) => Login(),
      'registration': (context) => Registration(),
    },
  ));
}