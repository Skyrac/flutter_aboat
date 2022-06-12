import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:talkaboat/models/search/search_result.model.dart';
import 'package:talkaboat/screens/podcast-detail.screen.dart';

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
        icon: Icon(Icons.clear),
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

  Widget makeListBuilder(context, List<SearchResult> data) => ListView.builder(
      itemCount: data.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        if (data[index] == null) {
          return const ListTile();
        }
        final item = data[index];
        return makeCard(context, item);
      });

  Widget makeCard(context, SearchResult entry) => Card(
        elevation: 8.0,
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration:
                const BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
            child: makeListTile(context, entry),
          ),
        ),
      );

  Widget makeListTile(context, SearchResult entry) => ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        leading: SizedBox(
          width: 60,
          height: 100,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                  child: CachedNetworkImage(
                imageUrl: entry.image == null ? '' : entry.image!,
                fit: BoxFit.fill,
                placeholder: (_, __) =>
                    const Center(child: CircularProgressIndicator()),
                // progressIndicatorBuilder: (context, url, downloadProgress) =>
                //     CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ))),
        ),
        title: Text(
          entry.title!,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          entry.description!,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: TextStyle(color: Colors.white),
        ),
        trailing: const Icon(Icons.keyboard_arrow_right,
            color: Colors.white, size: 30.0),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      PodcastDetailScreen(podcastSearchResult: entry)));
          // Navigator.push(
          //     context, MaterialPageRoute(builder: (context) => DetailPage()));
        },
      );

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
                      return makeListBuilder(context, searchResults);
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
            ? makeListBuilder(context, searchResults)
            : const SizedBox());
  }
}
