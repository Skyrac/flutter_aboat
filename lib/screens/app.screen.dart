import 'dart:io';

import 'package:Talkaboat/screens/playlist.screen.dart';
import 'package:Talkaboat/screens/search-and-filter.screen.dart';
import 'package:Talkaboat/screens/social/social_entry.screen.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
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
      const SearchAndFilterScreen(),
      const PlaylistScreen(),
      LibraryScreen(),
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
          bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, children: [
            MiniPlayerWidget(episode: episode),
            CurvedNavigationBar(
                backgroundColor: episode == null ? Colors.transparent : Theme.of(context).bottomAppBarColor,
                color: Theme.of(context).bottomNavigationBarTheme.backgroundColor!,
                buttonBackgroundColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
                animationCurve: Curves.easeInOut,
                animationDuration: const Duration(milliseconds: 600),
                height: Platform.isIOS ? 65 : 50,
                index: currentTabIndex,
                onTap: (index) {
                  _selectTab(pageKeys[index], index);
                },
                items: <Widget>[
                  const Icon(Icons.home, size: 30),
                  const Icon(Icons.search, size: 30),
                  const Icon(Icons.playlist_add, size: 30),
                  Stack(
                    children: [
                      const SizedBox(height: 30, width: 30),
                      const Center(child: Icon(Icons.library_books, size: 30)),
                      pageKeys[currentTabIndex] == "Library" || !userService.unseenLibraryNotifcationUpdates()
                          ? const SizedBox()
                          : const Positioned(
                              right: 10, top: 10, child: Icon(Icons.notifications_active, size: 20, color: Colors.red)),
                    ],
                  ),
                  const Icon(Icons.people, size: 30)
                ]),
          ])),
    );
  }
}
