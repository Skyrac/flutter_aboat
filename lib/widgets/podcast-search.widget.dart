import 'package:flutter/material.dart';
import 'package:talkaboat/models/search/search_result.model.dart';
import 'package:talkaboat/services/user/user.service.dart';
import 'package:talkaboat/widgets/podcast-list.widget.dart';

import '../injection/injector.dart';
import '../services/repositories/search.repository.dart';
import '../themes/colors.dart';

class PodcastSearch extends SearchDelegate<String?> {
  List<SearchResult> searchResults = List.empty();
  String previousSearch = "";
  final List<String> selectedLanguages;
  final List<int> genreIds;
  PodcastSearch({required this.selectedLanguages, required this.genreIds});

  @override
  String get searchFieldLabel => "Search podcasts...";
  final userService = getIt<UserService>();

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: theme.textTheme,
        primaryColor: Colors.amber,
        primaryIconTheme: theme.primaryIconTheme,
        primaryTextTheme: theme.primaryTextTheme);
  }

  buildPopupMenu(BuildContext context, SearchResult entry) =>
      <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'toggleLibrary',
          child: userService.isInLibrary(entry.id!)
              ? Card(child: Text('Remove from Library'))
              : Card(child: Text('Add to Library')),
        ),
      ];

  buildPopupButton(context, entry) => PopupMenuButton(
        child: Icon(Icons.more_vert, color: Theme.of(context).iconTheme.color),
        onSelected: (value) async {
          switch (value) {
            case "toggleLibrary":
              await userService.toggleLibraryEntry(entry.id);
              break;
          }
        },
        itemBuilder: (BuildContext context) {
          return buildPopupMenu(context, entry);
        },
      );

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    var shouldSearch = searchResults.isEmpty || previousSearch != query;
    if (shouldSearch && searchResults.isNotEmpty) {
      searchResults.clear();
    }
    previousSearch = query;
    return query.length <= 1
        ? Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              DefaultColors.primaryColor.shade900,
              DefaultColors.secondaryColor.shade900,
              DefaultColors.secondaryColor.shade900
            ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
          )
        : Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              DefaultColors.primaryColor.shade900,
              DefaultColors.secondaryColor.shade900,
              DefaultColors.secondaryColor.shade900
            ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: shouldSearch
                ? FutureBuilder(
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              '${snapshot.error} occurred',
                              style: TextStyle(fontSize: 18),
                            ),
                          );
                        } else if (snapshot.hasData && snapshot.data != null) {
                          // Extracting data from snapshot object
                          final data = snapshot.data as List<SearchResult>?;
                          if (data != null && data.isNotEmpty) {
                            searchResults = data;
                            return PodcastListWidget(
                                direction: Axis.vertical,
                                searchResults: searchResults,
                                trailing: buildPopupButton);
                          }
                        }
                      }
                      return const CircularProgressIndicator();
                    },
                    future: SearchRepository.searchSuggestion(query,
                        languages: selectedLanguages.join(","),
                        genres: genreIds.join(",")),
                  )
                : PodcastListWidget(
                    direction: Axis.vertical,
                    searchResults: searchResults,
                    trailing: buildPopupButton));
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          DefaultColors.primaryColor.shade900,
          DefaultColors.secondaryColor.shade900,
          DefaultColors.secondaryColor.shade900
        ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: searchResults.isNotEmpty
            ? PodcastListWidget(
                direction: Axis.vertical,
                searchResults: searchResults,
                trailing: buildPopupButton)
            : const SizedBox());
  }
}
