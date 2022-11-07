import 'package:flutter/material.dart';

import '../injection/injector.dart';
import '../models/podcasts/podcast.model.dart';
import '../models/search/search_result.model.dart';
import '../services/user/user.service.dart';
import '../widgets/login-button.widget.dart';
import '../widgets/podcast-list.widget.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen(this.escapeWithNav, {Key? key}) : super(key: key);

  final Function escapeWithNav;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final userService = getIt<UserService>();

  buildPopupMenu(BuildContext context, SearchResult entry) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'remove',
          child: Card(child: Text('Remove')),
        ),
      ];

  buildPopupButton(context, entry) => PopupMenuButton(
        child: Icon(Icons.more_vert, color: Theme.of(context).iconTheme.color),
        onSelected: (value) async {
          switch (value) {
            case "remove":
              await userService.removeFromFavorites(entry.id);
              break;
          }
          setState(() {});
        },
        itemBuilder: (BuildContext context) {
          return buildPopupMenu(context, entry);
        },
      );

  @override
  Widget build(BuildContext context) {
    userService.SetLastFavoritesNotifcationUpdate();
    return SafeArea(
        child: Scaffold(
            body: userService.isConnected
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                    child: FutureBuilder(
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                '${snapshot.error} occurred',
                                style: const TextStyle(fontSize: 18),
                              ),
                            );
                          } else if (snapshot.hasData && snapshot.data != null) {
                            // Extracting data from snapshot object
                            final data = snapshot.data as List<Podcast>;
                            if (data.isNotEmpty) {
                              return PodcastListWidget(
                                widget.escapeWithNav,
                                searchResults: data,
                                direction: Axis.vertical,
                                trailing: buildPopupButton,
                                checkUpdate: true,
                              );
                            }
                          }
                        } else {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return Center(
                            child: Text(
                          "You don't have any bookmarked podcasts.\n\nYou can bookmark podcasts when searching by clicking the vertical aligned ... at the right side of each podcast.",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ));
                      },
                      future: userService.getFavorites(),
                    ),
                  )
                : Center(child: LoginButton(widget.escapeWithNav))));
  }
}
