import 'package:Talkaboat/widgets/podcast-favorites.widget.dart';
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
  const HomeScreen(this.setEpisode, this.selectTab, {Key? key}) : super(key: key);
  final Function setEpisode;
  final Function selectTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final homeState = getIt<StateService>();
  final userService = getIt<UserService>();
  final questService = getIt<QuestService>();

  @override
  initState() {
    super.initState();
  }

  // List<Widget> createListOfCategories() {
  Widget createPodcastPreviewRecentlyListed(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("Recently Listened",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.titleMedium!.color!)),
            InkWell(
                onTap: (() {
                  print("Recently Listened - see all");
                }),
                child: Row(children: [
                  Text(
                    "See All",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12, color: Theme.of(context).textTheme.titleMedium!.color!),
                  ),
                  const Icon(Icons.arrow_right_alt)
                ])),
          ])),
      SizedBox(
          height: 150,
          child: userService.podcastProposalsHomeScreen.containsKey(0)
              ? PodcastListWidget(
                  direction: Axis.horizontal,
                  searchResults: userService.getProposals(0)!,
                  checkUpdate: false,
                )
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
                          userService.podcastProposalsHomeScreen[0] = data;
                          return PodcastListWidget(direction: Axis.horizontal, searchResults: homeState.map[0]!);
                        }
                      }
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                  future: PodcastRepository.getRandomPodcast(10),
                ))
    ]);
  }

  Widget createPodcastPreviewByGenre(BuildContext context, String title, int genre) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(title, style: TextStyle(fontSize: 32, color: Theme.of(context).primaryColor))),
      SizedBox(
          height: 200,
          child: userService.podcastProposalsHomeScreen.containsKey(genre)
              ? PodcastListWidget(
                  direction: Axis.horizontal,
                  searchResults: userService.getProposals(genre)!,
                  checkUpdate: false,
                )
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
                          return PodcastListWidget(direction: Axis.horizontal, searchResults: homeState.map[genre]!);
                        }
                      }
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                  future: PodcastRepository.getRandomPodcast(10),
                ))
    ]);
  }

  Widget createFavoritesList(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("Favorites",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.titleMedium!.color!)),
            InkWell(
                onTap: (() {
                  widget.selectTab("Library", 3);
                }),
                child: Row(children: [
                  Text(
                    "See All",
                    style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.titleMedium!.color!),
                  ),
                  const Icon(Icons.arrow_right_alt)
                ])),
          ]),
          userService.podcastProposalsHomeScreen.containsKey(1)
              ? PodcastListFavoritesWidget(
                  searchResults: userService.getProposals(1)!,
                  checkUpdate: false,
                )
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
                          userService.podcastProposalsHomeScreen[1] = data;
                          return PodcastListFavoritesWidget(searchResults: userService.podcastProposalsHomeScreen[1]!);
                        }
                      }
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                  future: PodcastRepository.getRandomPodcast(10),
                )
        ]));
  }

  Widget createTaskBar(BuildContext context, String title) {
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
                      fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.titleMedium!.color!)),
              IconButton(
                  onPressed: () {
                    setState(() {});
                  },
                  icon: const Icon(Icons.refresh))
            ],
          )),
      const SizedBox(
          height: 184,
          child: QuestListWidget(
            direction: Axis.horizontal,
          ))
    ]);
  }

  refresh() {
    setState(() {});
  }

  // Widget createLibraryPreviewGrid() {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
            child: Column(
      children: [
        HomeAppBarWidget(refresh: refresh),
        //const SizedBox(height: 5),
        //createLibraryPreview(),
        const SizedBox(height: 5),
        createTaskBar(context, 'Tasks'),
        const SizedBox(height: 20),
        createPodcastPreviewRecentlyListed(context),
        const SizedBox(height: 20),
        createFavoritesList(context),
        const SizedBox(height: 20),
      ],
    )));
  }

  createLibraryPreview() {
    if (!userService.isConnected || userService.library.isEmpty) {
      return Container();
    }
    var libraryEntries = userService.getLibraryEntries(6);
    var height = double.parse((libraryEntries.length / 2 * 120).toString());
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: height,
        child: Wrap(
          spacing: 10,
          children: [for (var entry in libraryEntries) LibraryPreviewWidget(podcast: entry)],
        ),
      ),
    );
  }
}
