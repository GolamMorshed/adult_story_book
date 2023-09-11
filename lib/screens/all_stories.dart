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

void main() {
  runApp(AllStories());
}

class AllStories extends StatefulWidget {
  @override
  _AllStoriesState createState() => _AllStoriesState();
}

class _AllStoriesState extends State<AllStories> {
  List<Story> stories = [];
  TextEditingController searchController = TextEditingController();
  FlutterTts flutterTts = FlutterTts(); // Initialize FlutterTts
  bool isDarkMode = false; // Track dark mode state

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
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(), // Use dark theme when isDarkMode is true
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
                  return StoryCard(
                    story: story,
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              isDarkMode = !isDarkMode; // Toggle dark mode
            });
          },
          child: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode), // Change icon based on mode
        ),
      ),
    );
  }
}

class StoryCard extends StatelessWidget {
  final Story story;
  final VoidCallback onTap;

  StoryCard({required this.story, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                story.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                story.genre,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
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
  bool readingMode = false;
  int currentPage = 0;
  int maxPages = 0;
  bool isDarkMode = false;
  bool isPlaying = false; // Track TTS playback state

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

  void toggleReadingMode() {
    setState(() {
      readingMode = !readingMode;
    });
  }

  void nextPage() {
    if (currentPage < maxPages - 1) {
      setState(() {
        currentPage++;
      });
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
    }
  }

  Future<void> toggleTTS() async {
    if (isPlaying) {
      // Stop TTS playback
      await widget.flutterTts.stop();
    } else {
      // Start TTS playback
      await widget.flutterTts.speak(pages[currentPage]);
    }

    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  void initState() {
    super.initState();
    splitContentIntoPages();
  }

  List<String> pages = [];

  void splitContentIntoPages() {
    final content = widget.story.content;
    final words = content.split(' '); // Split content into words
    final maxWordsPerPage = 200; // Adjust this value for the desired page length
    int start = 0;

    while (start < words.length) {
      int end = start + maxWordsPerPage;
      if (end > words.length) {
        end = words.length;
      }

      final page = words.sublist(start, end).join(' ');
      pages.add(page);

      start = end;
    }
    maxPages = pages.length;
  }

  @override
  Widget build(BuildContext context) {
    final contentText = currentPage < pages.length ? pages[currentPage] : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.story.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // Toggle dark mode
                    setState(() {
                      isDarkMode = !isDarkMode;
                    });
                  },
                  child: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                ),
                ElevatedButton(
                  onPressed: toggleTTS,
                  child: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                ),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [


                  ElevatedButton.icon(
                    onPressed: () {
                      increaseFontSize();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white, // Set button background color to white
                    ),
                    icon: Icon(
                      Icons.add,
                      color: Colors.green, // Set icon color to green
                    ),
                    label: Text(
                      'Increase Font Size',
                      style: TextStyle(
                        color: Colors.green, // Set text color to green
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      decreaseFontSize();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white, // Set button background color to white
                    ),
                    icon: Icon(
                      Icons.remove,
                      color: Colors.red, // Set icon color to red
                    ),
                    label: Text(
                      'Decrease Font Size  ',
                      style: TextStyle(
                        color: Colors.red, // Set text color to red
                      ),
                    ),
                  ),

                ],
              ),
            ),
            GestureDetector(
              onTap: toggleReadingMode,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: readingMode ? Colors.blue : Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                  color: isDarkMode ? Colors.black : Colors.white, // Background color based on mode
                ),
                padding: EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Text(
                    contentText,
                    style: TextStyle(fontSize: fontSize, color: isDarkMode ? Colors.white : Colors.black), // Text color based on mode
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: previousPage,
                  child: Text('Previous Page'),
                ),
                ElevatedButton(
                  onPressed: nextPage,
                  child: Text('Next Page'),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
