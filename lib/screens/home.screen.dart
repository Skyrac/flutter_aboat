import 'package:flutter/material.dart';
import 'package:talkaboat/services/repositories/mediacenter.repository.dart';
import 'package:talkaboat/services/repositories/podcast.repository.dart';
import 'package:talkaboat/themes/colors.dart';
import 'package:talkaboat/widgets/episode-preview.widget.dart';
import 'package:talkaboat/widgets/library-preview.widget.dart';

import '../models/podcasts/podcast.model.dart';
import '../widgets/home-app-bar.widget.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen(this.setEpisode);

  Function setEpisode;

  List<Widget> createListOfCategories() {
    List<Podcast> podcasts = MediacenterRepository.getLibraryMock();
    List<Widget> libraryPreviews = podcasts
        .map((Podcast podcast) => LibraryPreviewWidget(podcast: podcast))
        .toList();
    return libraryPreviews;
  }

  Widget createEpisodePreview(BuildContext context, String title) {
    var episodeList = PodcastRepository.getEpisodesMock(1);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(title,
              style: TextStyle(
                  fontSize: 32, color: Theme.of(context).primaryColor))),
      Container(
          height: 280,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (ctx, index) {
                return EpisodePreviewWidget(episodeList[index], setEpisode);
              },
              itemCount: episodeList.length))
    ]);
  }

  Widget createLibraryPreviewGrid() {
    return Container(
        height: 300,
        padding: const EdgeInsets.all(10),
        child: GridView.count(
          primary: false,
          childAspectRatio: 5 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 2,
          children: createListOfCategories(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
            child: Container(
      child: Column(
        children: [
          HomeAppBarWidget(),
          SizedBox(height: 5),
          createLibraryPreviewGrid(),
          createEpisodePreview(context, 'Made for you!'),
          createEpisodePreview(context, 'Favorites')
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
