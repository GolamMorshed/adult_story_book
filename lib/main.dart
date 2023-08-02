import 'package:flutter/material.dart';
import 'package:adult_story_book/screens/login.dart';
import 'package:adult_story_book/screens/registration.dart';
import 'package:adult_story_book/screens/dashboard.dart';
import 'package:adult_story_book/screens/speech_to_text.dart';
import 'package:adult_story_book/screens/recording_lists.dart';
import 'package:adult_story_book/screens/social_media.dart';
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'social_media',
    routes: {
      'login': (context) => Login(),
      'registration': (context) => Registration(),
      'dashboard': (context) => Dashboard(),
      'speech_to_text': (context) => SpeechToTextScreen(),
      'recording_lists': (context) => AttractiveListViewScreen(),
      'social_media': (context) => StoryBoard(),
    },
  ));
}