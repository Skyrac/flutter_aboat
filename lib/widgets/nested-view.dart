import 'package:Talkaboat/screens/favorites.screen.dart';
import 'package:Talkaboat/screens/home.screen.dart';
import 'package:Talkaboat/screens/livestream-overview.screen.dart';
import 'package:Talkaboat/screens/playlist.screen.dart';
import 'package:Talkaboat/screens/social/social_entry.screen.dart';
import 'package:flutter/material.dart';

class NestedView extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final String routeName;
  final Function setEpisode;
  final Function selectTab;

  const NestedView(
      {super.key, required this.navigatorKey, required this.routeName, required this.setEpisode, required this.selectTab});

  Map<String, WidgetBuilder> _routeBuilders(
    BuildContext context,
  ) {
    return {
      "Home": (context) => HomeScreen(setEpisode: setEpisode, selectTab: selectTab),
      "Live": (context) => const LivestreamOverviewScreen(),
      "Favorites": (context) => const FavoritesScreen(),
      "Playlist": (context) => const PlaylistScreen(),
      "Social": (context) => const SocialEntryScreen()
    };
  }

  @override
  Widget build(BuildContext context) {
    final routeBuilders = _routeBuilders(context);

    return Navigator(
      key: navigatorKey,
      initialRoute: routeName,
      onGenerateRoute: (routeSettings) => MaterialPageRoute(builder: (context) => routeBuilders[routeName]!(context)),
    );
  }
}
