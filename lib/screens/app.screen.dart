import 'dart:async';
import 'dart:io';

import 'package:Talkaboat/navigator_keys.dart';
import 'package:Talkaboat/widgets/nested-view.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/utils/common.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_store/open_store.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../injection/injector.dart';
import '../models/podcasts/episode.model.dart';
import '../services/audio/audio-handler.services.dart';
import '../themes/colors.dart';
import '../widgets/podcasts/mini-player.widget.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> with RouteAware {
  final userService = getIt<UserService>();
  String _currentPage = "Home";
  List<String> pageKeys = ["Home", "Live", "Favorites", "Playlist", "Social"];

  int currentTabIndex = 0;
  Episode? episode;

  Episode? setEpisode(Episode episode) {
    setState(() {
      this.episode = episode;
    });
    return this.episode;
  }

  void _selectTab(String tabItem, int index) {
    if (tabItem == _currentPage) {
      //_navigatorKeys[tabItem]?.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentPage = pageKeys[index];
        currentTabIndex = index;
      });
    }
  }

  GlobalKey<NavigatorState> _navigatorKey() {
    switch (currentTabIndex) {
      case 0:
        return NavigatorKeys.bottomNavigationBarHome;
      case 1:
        return NavigatorKeys.bottomNavigationBarLive;
      case 2:
        return NavigatorKeys.bottomNavigationBarFavorites;
      case 3:
        return NavigatorKeys.bottomNavigationBarPlaylist;
      //case 4:
        //return NavigatorKeys.bottomNavigationBarSocial;
      default:
        return NavigatorKeys.bottomNavigationBarHome;
    }
  }

  @override
  initState() {
    super.initState();
    checkUpdates(context);
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<bool> myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) async {
    Future.delayed(Duration.zero, () {
      Provider.of<SelectEpisodePage>(context, listen: false).changeFalse();
    });
    final key = _navigatorKey();
    final isfirst = await isCurrentRouteFirst(key.currentContext!);
    if (isfirst) {
      // kill app
      return false;
    } else {
      //pop route
      key.currentState!.pop();
    }
    return true;
  }

  @override
  void didPopNext() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: const Color.fromRGBO(29, 40, 58, 1),
        statusBarColor: DefaultColors.secondaryColor.shade900 // status bar color
        ));
  }

  @override
  void didPush() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: const Color.fromRGBO(29, 40, 58, 1),
        statusBarColor: DefaultColors.secondaryColor.shade900 // status bar color
        ));
  }

  checkUpdates(context) async {
    final remoteConfig = FirebaseRemoteConfig.instance;
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
                title: Text(AppLocalizations.of(context)!.updateRequired),
                content: Text(AppLocalizations.of(context)!.pleaseUpdateYourApp),
                elevation: 8,
                actions: [
                  TextButton(
                      onPressed: () {
                        OpenStore.instance.open(
                          appStoreId: '1637833839', // AppStore id of your app
                          androidAppBundleId: 'com.aboat.talkaboat', // Android app bundle package name
                        );
                      },
                      child: Text(AppLocalizations.of(context)!.update)),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(AppLocalizations.of(context)!.later))
                ],
              ),
          barrierDismissible: true);
    }
  }

  final audioPlayerHandler = getIt<AudioPlayerHandler>();

  Future<bool> isCurrentRouteFirst(BuildContext context) {
    var completer = Completer<bool>();
    Navigator.popUntil(context, (route) {
      completer.complete(route.isFirst);
      return true;
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    audioPlayerHandler.setEpisodeRefreshFunction(setEpisode);
    return Scaffold(
      body: NestedView(
        navigatorKey: _navigatorKey(),
        routeName: _currentPage,
        setEpisode: setEpisode,
        selectTab: _selectTab,
      ),
      bottomNavigationBar: Container(
        color: const Color.fromRGBO(15, 23, 41, 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MiniPlayerWidget(episode: episode, navKey: _navigatorKey()),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
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
                  //BottomNavigationBarItem(
                  //    icon: buttonNavbar("assets/images/social.png", 20, 20, "Social"),
                  //    activeIcon: buttonNavbarActiv("assets/images/social.png", 20, 20, "Social"),
                  //    label: ''),
                ],
              ),
            ),
          ],
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
