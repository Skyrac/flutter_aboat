import 'package:flutter/material.dart';

import '../injection/injector.dart';
import '../models/podcasts/podcast.model.dart';
import '../models/search/search_result.model.dart';
import '../services/user/user.service.dart';
import '../utils/scaffold_wave.dart';
import '../widgets/login-button.widget.dart';
import '../widgets/podcasts/podcast-list.widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen(this.escapeWithNav, {Key? key}) : super(key: key);

  final Function escapeWithNav;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final userService = getIt<UserService>();

  buildPopupMenu(BuildContext context, SearchResult entry) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'remove',
          child: Card(child: Text(AppLocalizations.of(context)!.remove)),
        ),
      ];

  buildPopupButton(context, entry) => PopupMenuButton(
        child: Icon(Icons.more_vert, color: Theme.of(context).iconTheme.color),
        onSelected: (value) async {
          switch (value) {
            case "remove":
              await userService.removePodcastsFromFavorites(entry.id);
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
        child: ScaffoldWave(
            appBar: AppBar(
              backgroundColor: const Color.fromRGBO(29, 40, 58, 1),
              title: const Text("Playlists"),
            ),
            body: userService.isConnected
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                : const Center(child: LoginButton())));
  }
}
