import 'package:Talkaboat/models/quests/quest.model.dart';
import 'package:Talkaboat/widgets/quests/quest-list.widget.dart';
import 'package:flutter/material.dart';

import '../injection/injector.dart';
import '../models/podcasts/podcast.model.dart';
import '../services/quests/quest.service.dart';
import '../services/repositories/podcast.repository.dart';
import '../services/state/state.service.dart';
import '../services/user/user.service.dart';
import '../themes/colors.dart';
import '../widgets/home-app-bar.widget.dart';
import '../widgets/library-preview.widget.dart';
import '../widgets/podcast-list.widget.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen(this.setEpisode, {Key? key}) : super(key: key);
  final Function setEpisode;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final homeState = getIt<StateService>();
  final userService = getIt<UserService>();
  final questService = getIt<QuestService>();

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
          child: userService.podcastProposalsHomeScreen.containsKey(genre)
              ? PodcastListWidget(
                  direction: Axis.horizontal,
                  searchResults: userService.getProposals(genre)!, checkUpdate: false,)
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
                        final data = snapshot.data as List<Podcast>?;
                        if (data != null && data.isNotEmpty) {
                          userService.podcastProposalsHomeScreen[genre] = data;
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

  Widget createTaskBar(
      BuildContext context, String title) {
    if (!userService.isConnected) {
      return Container();
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 32, color: Theme.of(context).primaryColor)),
              IconButton(onPressed: () {
                setState(() { });
              }, icon: const Icon(Icons.refresh))
            ],
          )),
      SizedBox(
          height: 250,
          child: QuestListWidget(direction: Axis.horizontal,))
    ]);
  }

  refresh() {
    setState(() { });
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
          HomeAppBarWidget(refresh: refresh),
          const SizedBox(height: 5),
          createLibraryPreview(),
          const SizedBox(height: 20),
          createTaskBar(context, 'Open Tasks'),
          const SizedBox(height: 20),
          createPodcastPreviewByGenre(context, 'Made for you!', 0),
          const SizedBox(height: 20),
          createPodcastPreviewByGenre(context, 'Favorites!', 1),

          // createEpisodePreview(context, 'Made for you!', ref),
          // createEpisodePreview(context, 'Favorites', ref)
        ],
      ),
    )));
  }

  createLibraryPreview() {
    if (!userService.isConnected || userService.library.length <= 0) {
      return Container();
    }
    var libraryEntries = userService.getLibraryEntries(6);
    var height = double.parse((libraryEntries.length / 2 * 120).toString());
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: height,
        child: Wrap(
          spacing: 10,
          children: [
            for (var entry in libraryEntries)
              LibraryPreviewWidget(podcast: entry)
          ],
        ),
      ),
    );
  }
}
