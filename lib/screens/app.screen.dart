import 'package:flutter/material.dart';
import 'package:talkaboat/screens/home.screen.dart';
import 'package:talkaboat/screens/library.screen.dart';
import 'package:talkaboat/screens/playlist.screen.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  final Tabs = [HomeScreen(), PlaylistScreen(), LibraryScreen()];
  int currentTabIndex = 0;
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Tabs[currentTabIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTabIndex,
        onTap: (currentIndex) {
          currentTabIndex = currentIndex;
          setState(() {});
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.playlist_add), label: 'Playlist'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.library_books), label: 'Library')
        ],
      ),
    );
  }
}
