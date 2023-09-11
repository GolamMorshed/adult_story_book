import 'package:adult_story_book/screens/story_list.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adult_story_book/screens/create_story.dart';

class Dashboard extends StatelessWidget {
  final String userId;
  final String userName;
  Dashboard({required this.userId, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      drawer: Sidebar(userName: userName),
      body: DashboardGrid(userId: userId),
    );
  }
}

class DashboardGrid extends StatelessWidget {
  final String userId;
  final List<String> gridItems = [
    'Create Story',
    'Story Lists',
    'Item 3',
    'Item 4',
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

        return GestureDetector(
          onTap: () {
            _handleGridItemClick(context, itemName);
          },
          child: GridTile(
            child: Container(
              decoration: BoxDecoration(
                color: itemColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  itemName,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
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
    } else if (itemName == 'Item 3') {
      // Handle navigation to Item 3
    } else if (itemName == 'Item 4') {
      // Handle navigation to Item 4
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

