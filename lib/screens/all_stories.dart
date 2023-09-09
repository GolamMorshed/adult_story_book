import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

class Story {
  final String title;
  final String genre;
  final String content;

  Story({
    required this.title,
    required this.genre,
    required this.content,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      title: json['title'],
      genre: json['genre'],
      content: json['content'],
    );
  }
}

class AllStories extends StatefulWidget {
  @override
  _AllStoriesState createState() => _AllStoriesState();
}

class _AllStoriesState extends State<AllStories> {
  List<Story> stories = [];
  TextEditingController searchController = TextEditingController();
  FlutterTts flutterTts = FlutterTts(); // Initialize FlutterTts

  @override
  void initState() {
    super.initState();
    fetchStories();
  }

  Future<void> fetchStories() async {
    final apiUrl = 'http://127.0.0.1:8000/api/stories';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      final storiesList = jsonData['data']; // Assuming the stories are nested under a 'data' key

      setState(() {
        stories = storiesList.map<Story>((json) => Story.fromJson(json)).toList();
      });
    } else {
      print('Failed to fetch stories. Status Code: ${response.statusCode}');
    }
  }

  List<Story> filteredStories() {
    final searchText = searchController.text.toLowerCase();
    return stories.where((story) {
      final title = story.title.toLowerCase();
      return title.contains(searchText);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Story Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Story Viewer'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                onChanged: (_) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Search...',
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredStories().length,
                itemBuilder: (context, index) {
                  final story = filteredStories()[index];
                  return ListTile(
                    title: Text(story.title),
                    subtitle: Text(story.genre),
                    onTap: () {
                      // Navigate to the StoryDetail screen
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => StoryDetail(story: story, flutterTts: flutterTts),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StoryDetail extends StatefulWidget {
  final Story story;
  final FlutterTts flutterTts;

  StoryDetail({required this.story, required this.flutterTts});

  @override
  _StoryDetailState createState() => _StoryDetailState();
}

class _StoryDetailState extends State<StoryDetail> {
  double fontSize = 16.0;

  void increaseFontSize() {
    setState(() {
      fontSize += 2.0;
    });
  }

  void decreaseFontSize() {
    setState(() {
      fontSize -= 2.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.story.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.story.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              widget.story.genre,
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 16),
            Text(
              widget.story.content,
              style: TextStyle(fontSize: fontSize), // Adjustable font size
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // Start speaking the content
                    await widget.flutterTts.speak(widget.story.content);
                  },
                  child: Text('Listen to Content'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    // Stop speaking
                    await widget.flutterTts.stop();
                  },
                  child: Text('Stop Listening'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    increaseFontSize();
                  },
                  child: Text('Increase Font Size'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    decreaseFontSize();
                  },
                  child: Text('Decrease Font Size'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(AllStories());
}
