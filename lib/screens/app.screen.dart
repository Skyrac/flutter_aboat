import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:talkaboat/injection/injector.dart';
import 'package:talkaboat/models/podcasts/episode.model.dart';
import 'package:talkaboat/screens/home.screen.dart';
import 'package:talkaboat/screens/library.screen.dart';
import 'package:talkaboat/screens/playlist.screen.dart';
import 'package:talkaboat/widgets/mini-player.widget.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  var Tabs;

  int currentTabIndex = 0;
  Episode? episode;

  Episode? setEpisode(Episode episode) {
    this.episode = episode;
    setState(() {});
    return this.episode;
  }

  @override
  initState() {
    getIt<AudioPlayer>();
    super.initState();
    Tabs = [HomeScreen(setEpisode), PlaylistScreen(), LibraryScreen()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Tabs[currentTabIndex],
      bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, children: [
        MiniPlayerWidget(episode: episode),
        BottomNavigationBar(
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
        )
      ]),
    );
  }
}
