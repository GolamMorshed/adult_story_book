import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share/share.dart';
import 'package:translator/translator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


class Story {
  final int id;
  final String title;
  final String genre;
  final String content;

  Story({
    required this.id,
    required this.title,
    required this.genre,
    required this.content,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'],
      title: json['title'],
      genre: json['genre'],
      content: json['content'],
    );
  }
}

class StoryDashboard1 extends StatefulWidget {
  final String userId;

  StoryDashboard1({
    required this.userId,
  });

  @override
  _StoryDashboardState createState() => _StoryDashboardState();
}

class _StoryDashboardState extends State<StoryDashboard1> {
  List<Story> stories = [];

  TextEditingController searchController = TextEditingController();
  FlutterTts flutterTts = FlutterTts();
  bool isDarkMode = true;
  bool isLoggedIn = false;
  File? backgroundImage; // Selected background image


  @override
  void initState() {
    super.initState();
    String userId = widget.userId;
    fetchStories();
  }

  Future<void> fetchStories() async {
    final apiUrl = 'http://127.0.0.1:8000/api/stories';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      final storiesList = jsonData['data'];

      setState(() {
        stories = storiesList.map<Story>((json) => Story.fromJson(json)).toList();
      });
    } else {
      print('Failed to fetch stories. Status Code: ${response.statusCode}');
    }
  }

  List<Story> getFilteredStories(String query) {
    return stories.where((story) {
      final title = story.title.toLowerCase();
      final genre = story.genre.toLowerCase();
      final content = story.content.toLowerCase();
      final searchQuery = query.toLowerCase();

      return title.contains(searchQuery) ||
          genre.contains(searchQuery) ||
          content.contains(searchQuery);
    }).toList();
  }

  // Function to pick a background image
  Future<void> pickBackgroundImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        backgroundImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Story Viewer',
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('      Story Viewer'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back), // Add back button icon
            onPressed: () {
              Navigator.pop(context); // Navigate back when pressed
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.image), // Button to choose background image
              onPressed: pickBackgroundImage,
            ),
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            image: backgroundImage != null
                ? DecorationImage(
              image: FileImage(backgroundImage!), // Set selected background image
              fit: BoxFit.cover,
            )
                : null,
          ),
          child: Column(
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
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  itemCount: searchController.text.isEmpty
                      ? stories.length
                      : getFilteredStories(searchController.text).length,
                  itemBuilder: (context, index) {
                    final story = searchController.text.isEmpty
                        ? stories[index]
                        : getFilteredStories(searchController.text)[index];
                    return StoryCard(
                      story: story,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => StoryDetail(
                              userId: widget.userId,
                              story: story,
                              flutterTts: flutterTts,
                              backgroundImage: backgroundImage, // Pass background image
                            ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    story.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    story.genre,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class StoryDetail extends StatefulWidget {
  final String userId;
  final Story story;
  final FlutterTts flutterTts;
  final File? backgroundImage; // Add this line

  StoryDetail({
    required this.userId,
    required this.story,
    required this.flutterTts,
    this.backgroundImage, // Add this line
  });

  @override
  _StoryDetailState createState() => _StoryDetailState();
}

class _StoryDetailState extends State<StoryDetail> {
  double fontSize = 12.0;
  bool readingMode = false;
  int currentPage = 0;
  int maxPages = 0;
  bool isDarkMode = false;
  bool isPlaying = false;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String currentTranslation = '';
  GoogleTranslator translator = GoogleTranslator();
  final double minFontSize = 18.0;
  late Map<String, dynamic> userLeftOver;

  _StoryDetailState() {
    _speech = stt.SpeechToText();
  }

  @override
  void initState() {
    super.initState();
    fetchUserLeftOver(widget.userId, widget.story.id);
    splitContentIntoPages();
    _speech = stt.SpeechToText();
    translateContent(Locale('en'));
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  Future<void> fetchUserLeftOver(String userId, int storyId) async {
    final String user_id = userId;
    final String story_id = storyId.toString();
    final apiUrl = 'http://127.0.0.1:8000/api/user-stories/$userId';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      final List<dynamic> dataList = jsonData['data'];
      for (final item in dataList) {
        if (item.containsKey('user_id')) {
          String fetchUserId = item['user_id'];
          if(item['user_id'] == user_id && item['story_id'] == story_id){
            final String pageNo = item['page_number'];
            int pageNumber = int.tryParse(pageNo) ?? 0;
            navigateToPage(pageNumber);

            //this.currentPage = pageNumber;
            //print("Current Page no this: $currentPage");
          }
        } else {
          print('The "user_id" field does not exist in an item of the "data" list.');
          print("Current Page no this: $currentPage");
        }
      }

    } else {
      print('Failed to fetch user left over data. Status Code: ${response.statusCode}');
    }
  }
  void navigateToPage(int pageNumber) {
    if (pageNumber >= 0 && pageNumber < maxPages) {
      setState(() {
        currentPage = pageNumber;
      });
      _startListening();
    }
  }


  void increaseFontSize() {
    setState(() {
      fontSize += 2.0;
      if (fontSize > minFontSize) {
        fontSize = minFontSize;
      }
    });

  }

  void decreaseFontSize() {
    setState(() {
      fontSize -= 2.0;
      // if (fontSize < minFontSize) {
      //   fontSize = minFontSize;
      // }
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
      storePage(currentPage);
      _startListening();
    }
  }

  void storePage(int pageNumber) async {
    final apiUrl = 'http://127.0.0.1:8000/api/user-story-pages';
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'user_id': widget.userId,
        'story_id': widget.story.id.toString(),
        'page_number': pageNumber.toString(),
      },
    );

    if (response.statusCode == 201) {
      print('Page stored successfully.');
    } else {
      print('Failed to store page. Status Code: ${response.statusCode}');
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
      storePage(currentPage);
      _startListening();
    }
  }

  Future<void> toggleTTS() async {
    if (isPlaying) {
      await widget.flutterTts.stop();
    } else {
      await widget.flutterTts.speak(pages[currentPage]);
    }

    setState(() {
      isPlaying = !isPlaying;
    });

    if (_isListening) {
      _speech.stop();
    } else {
      _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            handleVoiceCommand(result.recognizedWords);
            _speech.stop();
          }
        },
      );
    }
  }

  List<String> pages = [];

  void splitContentIntoPages() {
    final content = widget.story.content;
    final words = content.split(' ');
    final maxWordsPerPage = 150;
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

  Future<void> translateContent(Locale targetLocale) async {
    if (targetLocale == Locale('en')) {
      setState(() {
        currentTranslation = '';
      });
      return;
    }

    try {
      final translation = await translator.translate(
        pages[currentPage],
        from: 'en',
        to: targetLocale.languageCode,
      );
      setState(() {
        currentTranslation = translation.text;
      });
    } catch (e) {
      print('Translation error: $e');
    }
  }

  void toggleVoiceNavigation() {
    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        _startListening();
      } else {
        _stopListening();
      }
    });
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      _speech.listen(
        onResult: (result) {
          handleVoiceCommand(result.recognizedWords);
        },
      );
    } else {
      print('Speech recognition is not available');
    }
  }

  void handleVoiceCommand(String command) {
    if (command.toLowerCase().contains('next')) {
      nextPage();
    } else if (command.toLowerCase().contains('previous')) {
      previousPage();
    }
  }

  void _stopListening() {
    _speech.stop();
  }

  @override
  Widget build(BuildContext context) {
    final contentText = currentPage < pages.length ? pages[currentPage] : '';
    final translatedText =
    currentTranslation.isNotEmpty ? currentTranslation : contentText;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.story.title),
        actions: [
          PopupMenuButton<Locale>(
            onSelected: (Locale targetLocale) {
              translateContent(targetLocale);
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<Locale>(
                  value: Locale('en', 'US'),
                  child: Text('English'),
                ),
                PopupMenuItem<Locale>(
                  value: Locale('es', 'ES'),
                  child: Text('Español'),
                ),
                // Add more languages as needed
              ];
            },
          ),
        ],
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
                ElevatedButton.icon(
                  onPressed: toggleVoiceNavigation,
                  icon: Icon(
                    Icons.mic,
                    color: _isListening ? Colors.red : Colors.green,
                  ),
                  label: Text(
                    _isListening ? 'Listening...' : 'Voice Navigation',
                    style: TextStyle(
                      color: _isListening ? Colors.red : Colors.green,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Share.share(
                        'Check out this story: ${widget.story.title}\n\n${widget.story.content}');
                  },
                  child: Icon(Icons.share),
                )
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
                      primary: Colors.white,
                    ),
                    icon: Icon(
                      Icons.add,
                      color: Colors.green,
                    ),
                    label: Text(
                      'Increase Font Size',
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      decreaseFontSize();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                    ),
                    icon: Icon(
                      Icons.remove,
                      color: Colors.red,
                    ),
                    label: Text(
                      'Decrease Font Size  ',
                      style: TextStyle(
                        color: Colors.red,
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
                  color: isDarkMode ? Colors.black : Colors.white,
                ),
                padding: EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Text(
                    translatedText,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
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


