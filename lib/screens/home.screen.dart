import 'package:flutter/material.dart';
import 'package:talkaboat/services/repositories/podcast.repository.dart';
import 'package:talkaboat/services/state/home-state.service.dart';
import 'package:talkaboat/themes/colors.dart';

import '../injection/injector.dart';
import '../models/search/search_result.model.dart';
import '../widgets/home-app-bar.widget.dart';
import '../widgets/podcast-list.widget.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen(this.setEpisode, {Key? key}) : super(key: key);
  final Function setEpisode;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final homeState = getIt<HomeStateService>();

  // List<Widget> createListOfCategories() {
  Widget createPodcastPreviewByGenre(
      BuildContext context, String title, int genre) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(title,
              style: TextStyle(
                  fontSize: 32, color: Theme.of(context).primaryColor))),
      SizedBox(
          height: 200,
          child: homeState.map[genre] != null &&
                  homeState.map[genre]!.isNotEmpty
              ? PodcastListWidget(
                  direction: Axis.horizontal,
                  searchResults: homeState.map[genre]!)
              : FutureBuilder(
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
                        final data = snapshot.data as List<SearchResult>?;
                        if (data != null && data.isNotEmpty) {
                          var searchResults = data;
                          homeState.map[genre] = data;
                          return PodcastListWidget(
                              direction: Axis.horizontal,
                              searchResults: homeState.map[genre]!);
                        }
                      }
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                  future: PodcastRepository.getRandomPodcast(10),
                ))
    ]);
  }

  // Widget createLibraryPreviewGrid() {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
            child: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        DefaultColors.primaryColor.shade900,
        DefaultColors.secondaryColor.shade900,
        DefaultColors.secondaryColor.shade900
      ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Column(
        children: [
          const HomeAppBarWidget(),
          const SizedBox(height: 5),
          createPodcastPreviewByGenre(context, 'Made for you!', 14),
          const SizedBox(height: 20),
          createPodcastPreviewByGenre(context, 'Favorites!', 21),
          // createLibraryPreviewGrid(),
          // createEpisodePreview(context, 'Made for you!', ref),
          // createEpisodePreview(context, 'Favorites', ref)
        ],
      ),
    )));
  }
}
