import 'package:flutter/material.dart';
import 'package:adult_story_book/screens/login.dart';
import 'package:adult_story_book/screens/registration.dart';
import 'package:adult_story_book/screens/dashboard.dart';
import 'package:adult_story_book/screens/speech_to_text.dart';
import 'package:adult_story_book/screens/recording_lists.dart';
import 'package:adult_story_book/screens/social_media.dart';
import 'package:adult_story_book/screens/create_story.dart';
import 'package:adult_story_book/screens/all_stories.dart';
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'all_stories',
    routes: {
      'login': (context) => LoginScreen(),
      'registration': (context) => Registration(),
      'dashboard': (context) => Dashboard(),
      'create_story': (context) => MyApp(),
      'speech_to_text': (context) => SpeechToTextScreen(),
      'recording_lists': (context) => AttractiveListViewScreen(),
      'social_media': (context) => StoryBoard(),
      'all_stories': (context) => AllStories(),
    },
  ));
}