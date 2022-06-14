import 'package:flutter/material.dart';
import 'package:talkaboat/models/podcasts/podcast.model.dart';
import 'package:talkaboat/models/search/search_result.model.dart';
import 'package:talkaboat/widgets/podcast-list.widget.dart';

import '../injection/injector.dart';
import '../services/user/user.service.dart';

class LibraryScreen extends StatefulWidget {
  LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final userService = getIt<UserService>();

  buildPopupMenu(BuildContext context, SearchResult entry) =>
      <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'remove',
          child: Card(child: Text('Remove')),
        ),
      ];

  buildPopupButton(context, entry) => PopupMenuButton(
        child: Icon(Icons.more_vert, color: Theme.of(context).iconTheme.color),
        onSelected: (value) {
          switch (value) {
            case "remove":
              print("remove ${entry.id}");
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
    print("render");
    return SafeArea(
        child: Scaffold(
            body: userService.isConnected
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 20),
                    child: FutureBuilder(
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                '${snapshot.error} occurred',
                                style: TextStyle(fontSize: 18),
                              ),
                            );
                          } else if (snapshot.hasData &&
                              snapshot.data != null) {
                            // Extracting data from snapshot object
                            final data = snapshot.data as List<Podcast>;
                            if (data.isNotEmpty) {
                              return PodcastListWidget(
                                searchResults: data,
                                direction: Axis.vertical,
                                trailing: buildPopupButton,
                              );
                            }
                          }
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                      future: userService.getLibrary(),
                    ),
                  )
                : Text("Not logged In")));
  }
}
