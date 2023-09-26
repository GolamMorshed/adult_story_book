import 'package:adult_story_book/screens/image_to_text.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adult_story_book/screens/create_story.dart';
import 'package:adult_story_book/screens/all_stories.dart';
import 'package:adult_story_book/screens/story_list.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class Dashboard extends StatefulWidget {
  final String userId;
  final String userName;
  Dashboard({required this.userId, required this.userName});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool isDarkMode = false; // Track dark mode state
  late stt.SpeechToText _speech;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    initSpeechRecognition();
    loadTheme();
  }
  // Function to initialize speech recognition
  void initSpeechRecognition() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech recognition status: $status'),
      onError: (errorNotification) =>
          print('Speech recognition error: $errorNotification'),
    );
    if (available) {
      print('Speech recognition initialized.');
    } else {
      print('Error initializing speech recognition.');
    }
  }
  // Function to load the theme preference from SharedPreferences
  void loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void toggleDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = !isDarkMode;
      prefs.setBool('isDarkMode', isDarkMode);
    });
  }

  void startListening() async {
    if (!_speech.isListening) {
      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            handleVoiceCommand(result.recognizedWords);
          }
        },
      );
    }
  }

  void handleVoiceCommand(String command) {
    if (command.toLowerCase().contains('open')) {
      print("Opening settings...");
    } else if (command.toLowerCase().contains('navigate to profile')) {
      print("Navigating to profile...");
    } else {
      print("Unrecognized command: $command");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = isDarkMode ? ThemeData.dark() : ThemeData.light();

    return MaterialApp(
      title: 'Dashboard App',
      theme: themeData, // Set the theme based on isDarkMode
      home: Scaffold(
        appBar: AppBar(
          title: Text('Dashboard'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.mic), // Replace with your desired button icon
              onPressed: () {
                startListening();
              },
            ),
          ],
        ),
        drawer: Sidebar(userName: widget.userName),
        body: DashboardGrid(userId: widget.userId),
        floatingActionButton: FloatingActionButton(
          onPressed: toggleDarkMode, // Toggle dark mode on button press
          child: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
        ),
      ),
    );
  }
}

class DashboardGrid extends StatelessWidget {
  final String userId;
  final List<String> gridItems = [
    'Extract Images',
    'Create Story',
    'Story Lists',
    'All Stories',
  ];

  final List<Color> itemColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
  ];

  DashboardGrid({required this.userId});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
      ),
      itemCount: gridItems.length,
      itemBuilder: (context, index) {
        Color itemColor = itemColors[index % itemColors.length];
        String itemName = gridItems[index];
        IconData itemIcon;

        // Assign icons based on item names (customize as needed)
        if (itemName == 'Extract Images') {
          itemIcon = Icons.image;
        } else if (itemName == 'Create Story') {
          itemIcon = Icons.edit;
        } else if (itemName == 'Story Lists') {
          itemIcon = Icons.view_list;
        } else if (itemName == 'All Stories') {
          itemIcon = Icons.library_books;
        } else {
          itemIcon = Icons.extension; // Default icon
        }

        return GestureDetector(
          onTap: () {
            _handleGridItemClick(context, itemName);
          },
          child: Card(
            elevation: 4.0,
            margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            color: itemColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    itemIcon,
                    color: Colors.white,
                    size: 40, // Adjust the icon size as needed
                  ),
                  SizedBox(height: 8),
                  Text(
                    itemName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

  }

  void _handleGridItemClick(BuildContext context, String itemName) {
    if (itemName == 'Create Story') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyApp(userId: userId), // Navigate to CreateStory with userId
        ),
      );
    } else if (itemName == 'Story Lists') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StoryListPage(userId: userId), // Navigate to CreateStory with userId
        ),
      );
    } else if (itemName == 'All Stories') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AllStories(), // Navigate to CreateStory with userId
        ),
      );
    } else if (itemName == 'Extract Images') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageToText(userId: userId), // Navigate to CreateStory with userId
        ),
      );
    }
  }
}

class Sidebar extends StatelessWidget {
  final String userName;
  Sidebar({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              clearUserIdInSharedPreferences();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

void clearUserIdInSharedPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('userId');
}

void main() async {
  String? userId = await getUserIdFromSharedPreferences();
  String? userName = await getUserNameFromSharedPreferences();
  runApp(DashboardApp(userId: userId ?? "", userName: userName ?? ""));
}

class DashboardApp extends StatelessWidget {
  final String userId;
  final String userName;
  DashboardApp({required this.userId, required this.userName});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Dashboard(userId: userId, userName: userName),
    );
  }
}

// SharedPreferences functions for userId and userName
void saveUserIdToSharedPreferences(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('userId', userId);
}

Future<String?> getUserIdFromSharedPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId');
}

void saveUserNameToSharedPreferences(String userName) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('userName', userName);
}

Future<String?> getUserNameFromSharedPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userName');
}
