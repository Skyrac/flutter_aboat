import 'package:flutter/material.dart';
import 'package:talkaboat/services/repositories/mediacenter.repository.dart';
import 'package:talkaboat/services/repositories/podcast.repository.dart';
import 'package:talkaboat/themes/colors.dart';
import 'package:talkaboat/widgets/episode-preview.widget.dart';
import 'package:talkaboat/widgets/library-preview.widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/podcasts/episode.model.dart';
import '../widgets/home-app-bar.widget.dart';

class HomeScreen extends HookConsumerWidget  {
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

  Widget createEpisodePreview(BuildContext context, String title, WidgetRef ref) {
    final configs = ref.watch(episodeProvider);
    return
     Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(title,
                  style: TextStyle(
                      fontSize: 32, color: Theme.of(context).primaryColor))),
          Container(
              height: 300,
              child:       configs.when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (error, stack) => Text('Error: $error'),
    data: (episodeList) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (ctx, index) {
                    return EpisodePreviewWidget(episodeList[index]!, setEpisode);
                  },
                  itemCount: episodeList.length)))
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
      child: Column(
        children: [
          HomeAppBarWidget(),
          SizedBox(height: 5),
          // createLibraryPreviewGrid(),
          createEpisodePreview(context, 'Made for you!', ref),
          createEpisodePreview(context, 'Favorites', ref)
        ],
      ),
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        DefaultColors.primaryColor.shade900,
        DefaultColors.secondaryColor.shade900,
        DefaultColors.secondaryColor.shade900
      ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
    )));
  }
}
