import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:adult_story_book/screens/dashboard.dart';

class Story {
  final int id;
  final String title;
  final String genre;
  String content;

  Story({
    required this.id,
    required this.title,
    required this.genre,
    required this.content,
  });
}

class StoryListPage extends StatefulWidget {
  final String userId;

  StoryListPage({required this.userId});

  @override
  _StoryListPageState createState() => _StoryListPageState();
}

class _StoryListPageState extends State<StoryListPage> {
  List<Story> stories = [];

  @override
  void initState() {
    super.initState();
    fetchStories();
  }

  Future<void> fetchStories() async {
    final apiUrl = 'http://localhost:8000/api/stories/user/${widget.userId}';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final dynamic responseData = jsonDecode(response.body);

      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        final List<dynamic> storiesData = responseData['data'];

        setState(() {
          stories = storiesData
              .map((data) => Story(
            id: data['id'],
            title: data['title'],
            genre: data['genre'],
            content: data['content'],
          ))
              .toList();
        });
      } else {
        print('Invalid response format. Expected a "data" key with a List, but received: $responseData');
      }
    } else {
      print('Failed to fetch data. Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  }

  Future<void> deleteStory(int storyId) async {
    final apiUrl = 'http://127.0.0.1:8000/api/stories/$storyId';

    final response = await http.delete(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: 'Story deleted successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      setState(() {
        stories.removeWhere((story) => story.id == storyId);
      });
    } else {

      print('Failed to delete story. Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Story Viewer'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to the previous screen
          },
        ),
      ),
      body: ListView.builder(
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(story.title),
              subtitle: Text('ID: ${story.id}, Genre: ${story.genre}'),
              //subtitle: Text(story.genre),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  ElevatedButton(
                    onPressed: () async {
                      print('story ID: ${story.id}');
                      final editedContent = await Navigator.of(context).push(
                        MaterialPageRoute(

                          builder: (context) => StoryEditPage(storyId: story.id,storyTitle: story.title, storyContent: story.content),

                        ),
                      );

                      if (editedContent != null) {
                        setState(() {
                          story.content = editedContent;
                        });
                      }
                    },
                    child: Text('Edit'),
                  ),
                  SizedBox(width: 8.0), // Add some spacing between buttons
                  ElevatedButton(
                    onPressed: () async {
                      final confirmed = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Confirm Delete'),
                          content: Text('Are you sure you want to delete this story?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await deleteStory(story.id);

                      }
                    },
                    child: Text('Delete'),
                  ),
                ],
              ),

              onTap: () {

              },
            ),
          );
        },
      ),
    );
  }
}

void main() {
  // Define the userId here
  final userId = 'your_user_id_here'; // Replace with the actual user ID

  runApp(
    MaterialApp(
      home: StoryListPage(userId: userId),
    ),
  );
}

class StoryEditPage extends StatefulWidget {

  final int storyId;
  final String storyTitle;
  final String storyContent;

  StoryEditPage({required this.storyId,required this.storyTitle, required this.storyContent});

  @override
  _StoryEditPageState createState() => _StoryEditPageState();
}

class _StoryEditPageState extends State<StoryEditPage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    int storyId = widget.storyId;
    _titleController.text = widget.storyTitle;
    _contentController.text = widget.storyContent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Story'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: TextFormField(
                controller: _contentController,
                maxLines: null, // Allows for multiple lines
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText: 'Content (up to 1000 words)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final editedTitle = _titleController.text;
                final editedContent = _contentController.text;
                await updateStory(widget.storyId, editedTitle, editedContent);
              },
              child: Text('Save'),
            ),

          ],
        ),
      ),
    );
  }


  Future<void> updateStory(int storyId, String title, String content) async {

    final apiUrl = 'http://127.0.0.1:8000/api/stories/$storyId';

    final response = await http.put(
      Uri.parse(apiUrl),
      body: {
        'title': title,
        'content': content,
      },
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: 'Story updated successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      Navigator.of(context).pop({'title': title, 'content': content});
      Navigator.of(context).pop();


    } else {
      print('Failed to update story. Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  }

}

