import 'package:flutter/material.dart';
import 'package:talkaboat/models/search/search_result.model.dart';
import 'package:talkaboat/widgets/podcast-list.widget.dart';

import '../services/repositories/search.repository.dart';
import '../themes/colors.dart';

class PodcastSearch extends SearchDelegate<String?> {
  List<SearchResult> searchResults = List.empty();

  @override
  String get searchFieldLabel => "Search podcasts...";

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
                  } else if (snapshot.hasData && snapshot.data != null) {
                    // Extracting data from snapshot object
                    final data = snapshot.data as List<SearchResult>?;
                    if (data != null && data.isNotEmpty) {
                      searchResults = data;
                      return PodcastListWidget(
                          direction: Axis.vertical,
                          searchResults: searchResults);
                    }
                  }
                }
                return Container();
              },
              future: SearchRepository.searchSuggestion(query),
            ));
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
                direction: Axis.vertical, searchResults: searchResults)
            : const SizedBox());
  }
}
