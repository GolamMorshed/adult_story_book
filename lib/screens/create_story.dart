import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Create Story',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StoryInputPage(),
    );
  }
}

class StoryInputPage extends StatefulWidget {
  @override
  _StoryInputPageState createState() => _StoryInputPageState();
}

class _StoryInputPageState extends State<StoryInputPage> {
  final TextEditingController titleController = TextEditingController();
  String? selectedGenre;
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isListening = false;
  String _text = '';

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  void _initializeSpeech() async {
    if (await _speech.initialize()) {
      setState(() {});
    } else {
      print('Speech recognition not available');
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();

      if (available) {
        _speech.listen(
          onResult: (result) => setState(() {
            _text = result.recognizedWords;
          }),
        );
      }
    } else {
      _speech.stop();
    }

    setState(() {
      _isListening = !_isListening;
    });
  }

  Future<void> _saveStory() async {
    String title = titleController.text;
    String genre = selectedGenre ?? '';
    String story = _text;

    print(title);
    print(genre);
    print(story);

    final apiUrl = 'http://127.0.0.1:8000/api/stories';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'genre': genre,
        'content': story,
      }),
    );

    if (response.statusCode == 201) {
      print('Story saved successfully');
    } else {
      print('Failed to save the story. Status Code: ${response.statusCode}');
    }
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create a Story'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Title:',
              style: TextStyle(fontSize: 18),
            ),
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Enter the story title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Genre:',
              style: TextStyle(fontSize: 18),
            ),
            DropdownButtonFormField<String>(
              value: selectedGenre,
              items: <String>[
                'Science Fiction',
                'Fantasy',
                'Romance',
                'Mystery',
                // Add more genre options as needed
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedGenre = newValue;
                });
              },
              decoration: InputDecoration(
                hintText: 'Select the genre',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Story:',
              style: TextStyle(fontSize: 18),
            ),
            // Replace TextFormField with a Row containing a TextFormField and a microphone button
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: TextEditingController(text: _text),
                    maxLines: null, // Allows for multiple lines
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: 'Speak or type your story here (up to 1000 words)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.mic),
                  onPressed: _listen,
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveStory,
              child: Text('Save'),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
