import 'package:Talkaboat/widgets/podcast-list.widget.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../injection/injector.dart';
import '../models/search/search_result.model.dart';
import '../screens/login.screen.dart';
import '../services/repositories/search.repository.dart';
import '../services/user/user.service.dart';
import '../themes/colors.dart';

class PodcastSearch extends SearchDelegate<String?> {
  List<SearchResult> searchResults = List.empty();
  final debouncer = Debouncer<String>(const Duration(milliseconds: 1000), initialValue: "");
  String previousSearch = "";
  final List<String> selectedLanguages;
  final List<int> genreIds;
  PodcastSearch({required this.selectedLanguages, required this.genreIds});

  Future<List<SearchResult>?> queryChanged(String query) async {
    debouncer.value = query;
    return SearchRepository.searchSuggestion(query, languages: selectedLanguages.join(","), genres: genreIds.join(","));
  }

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

  buildPopupMenu(BuildContext context, SearchResult entry) {
    if (!userService.isConnected) {
      return <PopupMenuItem<String>>[];
    }
    return [
      PopupMenuItem<String>(
        value: 'toggleLibrary',
        child: userService.isInFavorites(entry.id!)
            ? const Card(child: Text('Remove from Library'))
            : const Card(child: Text('Add to Library')),
      ),
    ];
  }

  buildPopupButton(context, entry) => PopupMenuButton(
        child: Icon(Icons.more_vert, color: Theme.of(context).iconTheme.color),
        onSelected: (value) async {
          switch (value) {
            case "toggleLibrary":
              if (!userService.isConnected) {
                Navigator.push(
                    context,
                    PageTransition(
                        alignment: Alignment.bottomCenter,
                        curve: Curves.bounceOut,
                        type: PageTransitionType.rightToLeftWithFade,
                        duration: const Duration(milliseconds: 500),
                        reverseDuration: const Duration(milliseconds: 500),
                        child: LoginScreen(true, refreshParent: () => {})));
              } else {
                await userService.toggleFavoritesEntry(entry.id);
              }
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
                ? FutureBuilder<List<SearchResult>?>(
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              '${snapshot.error} occurred',
                              style: const TextStyle(fontSize: 18),
                            ),
                          );
                        } else if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
                          if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                            return PodcastListWidget(
                                direction: Axis.vertical, searchResults: snapshot.data!, trailing: buildPopupButton);
                          }
                        } else {
                          return Center(
                              child: SizedBox(
                            width: 200,
                            child: Text(
                              "No results found for \"$query\"! Try another set of filters or search query.",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ));
                        }
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                    future: queryChanged(query),
                  )
                : PodcastListWidget(direction: Axis.vertical, searchResults: searchResults, trailing: buildPopupButton));
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
            ? PodcastListWidget(direction: Axis.vertical, searchResults: searchResults, trailing: buildPopupButton)
            : FutureBuilder<List<SearchResult>?>(
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          '${snapshot.error} occurred',
                          style: const TextStyle(fontSize: 18),
                        ),
                      );
                    } else if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
                      if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                        return PodcastListWidget(
                            direction: Axis.vertical, searchResults: snapshot.data!, trailing: buildPopupButton);
                      }
                    } else {
                      return Center(
                          child: SizedBox(
                        width: 200,
                        child: Text(
                          "No results found for \"$query\"! Try another set of filters or search query.",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ));
                    }
                  }
                  return const Center(child: CircularProgressIndicator());
                },
                future: queryChanged(query),
              ));
  }
}
