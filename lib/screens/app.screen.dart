import 'dart:io';

import 'package:Talkaboat/screens/favorites.screen.dart';
import 'package:Talkaboat/screens/search.screen.dart';
import 'package:Talkaboat/screens/social/social_entry.screen.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_store/open_store.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../injection/injector.dart';
import '../models/podcasts/episode.model.dart';
import '../services/audio/audio-handler.services.dart';
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
            return MaterialPageRoute(builder: (context) => Tabs[currentTabIndex]);
          },
        ));
  }

  @override
  initState() {
    super.initState();
    Tabs = [
      HomeScreen(setEpisode, _selectTab),
      const SearchScreen(),
      const FavoritesScreen(),
      const LibraryScreen(),
      const SocialEntryScreen()
    ];
    checkUpdates(context);
  }

  checkUpdates(context) async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setDefaults(const {"iosBuildNumber": 1, "androidBuildNumber": 1});
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await remoteConfig.fetchAndActivate();

    final requiredBuildNumber = remoteConfig.getInt(Platform.isAndroid ? 'androidBuildNumber' : 'iosBuildNumber');
    var packageInfo = await PackageInfo.fromPlatform();
    final currentBuildNumber = int.parse(packageInfo.buildNumber);
    if (currentBuildNumber < requiredBuildNumber) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: const Text("Update required"),
                content: const Text("Please update your app to continue"),
                elevation: 8,
                actions: [
                  TextButton(
                      onPressed: () {
                        OpenStore.instance.open(
                          appStoreId: '1637833839', // AppStore id of your app
                          androidAppBundleId: 'com.aboat.talkaboat', // Android app bundle package name
                        );
                      },
                      child: const Text("Update")),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Later"))
                ],
              ),
          barrierDismissible: true);
    }
  }

  final audioPlayerHandler = getIt<AudioPlayerHandler>();

  @override
  Widget build(BuildContext context) {
    audioPlayerHandler.setEpisodeRefreshFunction(setEpisode);
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab = await _navigatorKeys[_currentPage]?.currentState?.maybePop();
        if (isFirstRouteInCurrentTab != null && isFirstRouteInCurrentTab) {
          if (_currentPage != "Home") {
            _selectTab("Home", 1);

            return false;
          }
          // let system handle back button if we're on the first route
          return isFirstRouteInCurrentTab;
        }
        return false;
      },
      child: Scaffold(
        body: Stack(children: <Widget>[
          _buildOffstageNavigator("Home"),
          _buildOffstageNavigator("Search"),
          _buildOffstageNavigator("Playlist"),
          _buildOffstageNavigator("Library"),
          _buildOffstageNavigator("Social"),
        ]),
        bottomNavigationBar: Container(
          color: const Color.fromRGBO(15, 23, 41, 1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MiniPlayerWidget(episode: episode),
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                child: SizedBox(
                  height: 70,
                  child: BottomNavigationBar(
                    backgroundColor: const Color.fromRGBO(29, 40, 58, 1),
                    type: BottomNavigationBarType.fixed,
                    selectedFontSize: 0,
                    unselectedFontSize: 0,
                    elevation: 0,
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    currentIndex: currentTabIndex,
                    onTap: (index) {
                      _selectTab(pageKeys[index], index);
                    },
                    items: <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                          icon: buttonNavbar("assets/images/home.png", 20, 20, "Home"),
                          activeIcon: buttonNavbarActiv("assets/images/home.png", 20, 20, "Home"),
                          label: ''),
                      BottomNavigationBarItem(
                          icon: buttonNavbar("assets/images/live.png", 29, 20, "Live"),
                          activeIcon: buttonNavbarActiv("assets/images/live.png", 29, 20, "Live"),
                          label: ''),
                      BottomNavigationBarItem(
                          icon: buttonNavbar("assets/images/favorites.png", 20, 20, "Favorites"),
                          activeIcon: buttonNavbarActiv("assets/images/favorites.png", 20, 20, "Favorites"),
                          label: ''),
                      BottomNavigationBarItem(
                          icon: buttonNavbar("assets/images/playlist.png", 30, 20, "Playlists"),
                          activeIcon: buttonNavbarActiv("assets/images/playlist.png", 30, 20, "Playlists"),
                          label: ''),
                      BottomNavigationBarItem(
                          icon: buttonNavbar("assets/images/social.png", 20, 20, "Social"),
                          activeIcon: buttonNavbarActiv("assets/images/social.png", 20, 20, "Social"),
                          label: ''),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buttonNavbar(String image, double width, double height, String text) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
      Image.asset(
        image,
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
      const SizedBox(height: 10),
      Text(
        text,
        style: GoogleFonts.inter(textStyle: const TextStyle(fontSize: 12)),
      ),
    ]);
  }

  Widget buttonNavbarActiv(String image, double width, double height, String text) {
    return Container(
      height: 69,
      width: 60,
      decoration: const BoxDecoration(
          color: Color.fromRGBO(114, 113, 113, 0.2),
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image,
            width: width,
            height: height,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: GoogleFonts.inter(textStyle: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
