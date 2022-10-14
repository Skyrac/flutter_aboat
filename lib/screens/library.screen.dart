import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../injection/injector.dart';
import '../models/podcasts/podcast.model.dart';
import '../models/search/search_result.model.dart';
import '../services/user/user.service.dart';
import '../widgets/podcast-list.widget.dart';
import 'login.screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

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
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Card(
                          child: InkWell(
                            onTap: (() {
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      alignment: Alignment.bottomCenter,
                                      curve: Curves.bounceOut,
                                      type: PageTransitionType.fade,
                                      duration: const Duration(milliseconds: 300),
                                      reverseDuration: const Duration(milliseconds: 200),
                                      child: LoginScreen(() => setState(() {}))));
                            }),
                            child: SizedBox(
                                height: 80,
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                  child: Text(
                                    "Login",
                                    style: Theme.of(context).textTheme.titleLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                )),
                          ),
                        ),
                      ),
                    ),
                  )));
  }
}
