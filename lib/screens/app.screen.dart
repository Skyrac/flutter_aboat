import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:talkaboat/models/podcasts/episode.model.dart';
import 'package:talkaboat/screens/home.screen.dart';
import 'package:talkaboat/screens/library.screen.dart';
import 'package:talkaboat/screens/playlist.screen.dart';
import 'package:talkaboat/screens/search-and-filter.screen.dart';
import 'package:talkaboat/widgets/mini-player.widget.dart';

import '../themes/colors.dart';

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
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  Episode? setEpisode(Episode episode) {
    this.episode = episode;
    print(episode);
    setState(() {});
    return this.episode;
  }

  @override
  initState() {
    super.initState();
    Tabs = [
      HomeScreen(setEpisode),
      SearchAndFilterScreen(),
      PlaylistScreen(),
      LibraryScreen()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        DefaultColors.primaryColor.shade900,
        DefaultColors.secondaryColor.shade900,
        DefaultColors.secondaryColor.shade900
      ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Scaffold(
          body: Tabs[currentTabIndex],
          bottomNavigationBar:
              Column(mainAxisSize: MainAxisSize.min, children: [
            MiniPlayerWidget(episode: episode),
            CurvedNavigationBar(
                backgroundColor: episode == null
                    ? Colors.transparent
                    : Theme.of(context).bottomAppBarColor,
                color:
                    Theme.of(context).bottomNavigationBarTheme.backgroundColor!,
                buttonBackgroundColor: Theme.of(context)
                    .bottomNavigationBarTheme
                    .selectedItemColor,
                animationCurve: Curves.easeInOut,
                animationDuration: Duration(milliseconds: 600),
                height: 50,
                index: currentTabIndex,
                onTap: (index) {
                  setState(() {
                    currentTabIndex = index;
                  });
                },
                items: <Widget>[
                  Icon(Icons.home, size: 30),
                  Icon(Icons.search, size: 30),
                  Icon(Icons.playlist_add, size: 30),
                  Icon(Icons.library_books, size: 30)
                ]),
            // BottomNavigationBar(
            //   currentIndex: currentTabIndex,
            //   onTap: (currentIndex) {
            //     currentTabIndex = currentIndex;
            //     setState(() {});
            //   },
            //   items: [
            //     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home', backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor),
            //     BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search', backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor),
            //     BottomNavigationBarItem(
            //         icon: Icon(Icons.playlist_add), label: 'Playlist', backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor),
            //
            //     BottomNavigationBarItem(
            //         icon: Icon(Icons.library_books), label: 'Library', backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor)
            //   ],
            // )
          ])),
    );
  }
}
