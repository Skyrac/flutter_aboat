import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:talkaboat/services/repositories/podcast.repository.dart';
import 'package:talkaboat/themes/colors.dart';
import 'package:talkaboat/widgets/episode-preview.widget.dart';

import '../models/podcasts/episode.model.dart';
import '../models/search/search_result.model.dart';
import '../widgets/home-app-bar.widget.dart';
import '../widgets/podcast-list.widget.dart';

class HomeScreen extends HookConsumerWidget {
  HomeScreen(this.setEpisode, {Key? key}) : super(key: key);

  final Function setEpisode;

  // List<Widget> createListOfCategories() {
  //   // List<Podcast> podcasts = MediacenterRepository.getLibraryMock();
  //   // List<Widget> libraryPreviews = podcasts
  //   //     .map((Podcast podcast) => LibraryPreviewWidget(podcast: podcast))
  //   //     .toList();
  //   // return libraryPreviews;
  // }

  final episodeProvider = FutureProvider<List<Episode?>>((ref) async {
    return PodcastRepository.getEpisodesMock(0);
  });

  Widget createEpisodePreview(
      BuildContext context, String title, WidgetRef ref) {
    final configs = ref.watch(episodeProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(title,
              style: TextStyle(
                  fontSize: 32, color: Theme.of(context).primaryColor))),
      Container(
          height: 300,
          child: configs.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
              data: (episodeList) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (ctx, index) {
                    return EpisodePreviewWidget(episodeList[index]!);
                  },
                  itemCount: episodeList.length)))
    ]);
  }

  Widget createPodcastPreviewByGenre(
      BuildContext context, String title, int genre, WidgetRef ref) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(title,
              style: TextStyle(
                  fontSize: 32, color: Theme.of(context).primaryColor))),
      Container(
          height: 200,
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
                    var searchResults = data;
                    return PodcastListWidget(
                        direction: Axis.horizontal,
                        searchResults: searchResults);
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
  //   return Container(
  //       height: 300,
  //       padding: const EdgeInsets.all(10),
  //       child: GridView.count(
  //         primary: false,
  //         childAspectRatio: 5 / 2,
  //         crossAxisSpacing: 10,
  //         mainAxisSpacing: 10,
  //         crossAxisCount: 2,
  //         children: createListOfCategories(),
  //       ));
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          createPodcastPreviewByGenre(context, 'Made for you!', 14, ref),
          const SizedBox(height: 20),
          createPodcastPreviewByGenre(context, 'Favorites!', 21, ref),
          // createLibraryPreviewGrid(),
          // createEpisodePreview(context, 'Made for you!', ref),
          // createEpisodePreview(context, 'Favorites', ref)
        ],
      ),
    )));
  }
}
