import 'package:flutter/material.dart';

class DashboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Dashboard(),
    );
  }
}

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      drawer: Sidebar(), // Add the Sidebar here
      body: DashboardGrid(), // Add the DashboardGrid widget here
    );
  }
}

class DashboardGrid extends StatelessWidget {
  final List<String> gridItems = [
    'Item 1',
    'Item 2',
    'Item 3',
    'Item 4',
  ];

  final List<Color> itemColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of columns in the grid (2 by 2)
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: gridItems.length,
      itemBuilder: (context, index) {
        Color itemColor = itemColors[index % itemColors.length];

        return GridTile(
          child: Container(
            decoration: BoxDecoration(
              color: itemColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: Text(
                gridItems[index],
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        );
      },
    );
  }
}

class Sidebar extends StatelessWidget {
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
            child: Text(
              'Image and Name',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              // Handle the Home navigation here
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              // Handle the Settings navigation here
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
