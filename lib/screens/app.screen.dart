import 'package:Talkaboat/screens/playlist.screen.dart';
import 'package:Talkaboat/screens/search-and-filter.screen.dart';
import 'package:Talkaboat/screens/social/social_entry.screen.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../injection/injector.dart';
import '../models/podcasts/episode.model.dart';
import '../services/audio/audio-handler.services.dart';
import '../themes/colors.dart';
import '../widgets/mini-player.widget.dart';
import 'home.screen.dart';
import 'library.screen.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  var Tabs;
  var userService = getIt<UserService>();
  String _currentPage = "Home";
  List<String> pageKeys = ["Home", "Search", "Playlist", "Library", "Social"];
  final Map<String, GlobalKey<NavigatorState>> _navigatorKeys = {
    "Home": GlobalKey<NavigatorState>(),
    "Search": GlobalKey<NavigatorState>(),
    "Playlist": GlobalKey<NavigatorState>(),
    "Library": GlobalKey<NavigatorState>(),
    "Social": GlobalKey<NavigatorState>(),
  };

  int currentTabIndex = 0;
  Episode? episode;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  Episode? setEpisode(Episode episode) {
    this.episode = episode;
    setState(() {});
    return this.episode;
  }

  void _selectTab(String tabItem, int index) {
    if (tabItem == _currentPage) {
      _navigatorKeys[tabItem]?.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentPage = pageKeys[index];
        currentTabIndex = index;
      });
    }
  }

  Widget _buildOffstageNavigator(String tabItem) {
    return Offstage(
        offstage: _currentPage != tabItem,
        child: Navigator(
          key: _navigatorKeys[tabItem],
          onGenerateRoute: (routeSettings) {
            return MaterialPageRoute(
                builder: (context) => Tabs[currentTabIndex]);
          },
        ));
  }

  @override
  initState() {
    super.initState();
    Tabs = [
      HomeScreen(setEpisode),
      const SearchAndFilterScreen(),
      PlaylistScreen(),
      LibraryScreen(),
      SocialEntryScreen()
    ];
  }

  final audioPlayerHandler = getIt<AudioPlayerHandler>();

  @override
  Widget build(BuildContext context) {
    audioPlayerHandler.setEpisodeRefreshFunction(setEpisode);
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        DefaultColors.primaryColor.shade900,
        DefaultColors.secondaryColor.shade900,
        DefaultColors.secondaryColor.shade900
      ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: WillPopScope(
        onWillPop: () async {
          final isFirstRouteInCurrentTab =
              await _navigatorKeys[_currentPage]?.currentState?.maybePop();
          if (isFirstRouteInCurrentTab != null && isFirstRouteInCurrentTab) {
            if (_currentPage != "Home") {
              _selectTab("Home", 1);

              return false;
            }
          }
          // let system handle back button if we're on the first route
          return isFirstRouteInCurrentTab != null && isFirstRouteInCurrentTab;
        },
        child: Scaffold(
            body: Stack(children: <Widget>[
              _buildOffstageNavigator("Home"),
              _buildOffstageNavigator("Search"),
              _buildOffstageNavigator("Playlist"),
              _buildOffstageNavigator("Library"),
              _buildOffstageNavigator("Social"),
            ]),
            bottomNavigationBar:
                Column(mainAxisSize: MainAxisSize.min, children: [
              MiniPlayerWidget(episode: episode),
              CurvedNavigationBar(
                  backgroundColor: episode == null
                      ? Colors.transparent
                      : Theme.of(context).bottomAppBarColor,
                  color: Theme.of(context)
                      .bottomNavigationBarTheme
                      .backgroundColor!,
                  buttonBackgroundColor: Theme.of(context)
                      .bottomNavigationBarTheme
                      .selectedItemColor,
                  animationCurve: Curves.easeInOut,
                  animationDuration: const Duration(milliseconds: 600),
                  height: 50,
                  index: currentTabIndex,
                  onTap: (index) {
                    _selectTab(pageKeys[index], index);
                  },
                  items: <Widget>[
                    Icon(Icons.home, size: 30),
                    Icon(Icons.search, size: 30),
                    Icon(Icons.playlist_add, size: 30),
                    Stack(children: [
                      SizedBox(height: 30, width: 30),
                      Center(child: Icon(Icons.library_books, size: 30)),
                      pageKeys[currentTabIndex] == "Library" || !userService.unseenLibraryNotifcationUpdates() ? SizedBox() :Positioned(right: 10, top:10, child: Icon(Icons.notifications_active, size: 20, color: Colors.red)),
                    ],),
                    Icon(Icons.people, size: 30)
                  ]),
            ])),
      ),
    );
  }
}
