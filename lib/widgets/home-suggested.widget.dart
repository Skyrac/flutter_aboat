import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/services/repositories/podcast.repository.dart';
import 'package:Talkaboat/services/state/state.service.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/widgets/library-preview.widget.dart';
import 'package:Talkaboat/widgets/podcast-favorites.widget.dart';
import 'package:Talkaboat/widgets/podcast-list.widget.dart';
import 'package:Talkaboat/widgets/quests/quest-list.widget.dart';
import 'package:flutter/material.dart';

class HomeScreenSuggestedTab extends StatefulWidget {
  const HomeScreenSuggestedTab(this.selectTab, {Key? key}) : super(key: key);

  final Function selectTab;

  @override
  State<HomeScreenSuggestedTab> createState() => _HomeScreenSuggestedTabState();
}

class _HomeScreenSuggestedTabState extends State<HomeScreenSuggestedTab> {
  final homeState = getIt<StateService>();
  final userService = getIt<UserService>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        //const SizedBox(height: 5),
        //createLibraryPreview(),
        const SizedBox(height: 5),
        createTaskBar(context, 'Tasks'),
        const SizedBox(height: 20),
        createPodcastPreviewRecentlyListed(context),
        const SizedBox(height: 20),
        createFavoritesList(context),
        const SizedBox(height: 5),
      ],
    ));
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
              Text(title, style: Theme.of(context).textTheme.titleLarge),
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

  Widget createPodcastPreviewRecentlyListed(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Text("Recently Listened", style: Theme.of(context).textTheme.titleLarge),
      ),
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
                        if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                          userService.podcastProposalsHomeScreen[0] = snapshot.data!;
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

  Widget createFavoritesList(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("Favorites", style: Theme.of(context).textTheme.titleLarge),
            InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: (() {
                  widget.selectTab("Library", 3);
                }),
                child: Row(children: [
                  Text(
                    "See All",
                    style: Theme.of(context).textTheme.titleSmall,
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
                        if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                          userService.podcastProposalsHomeScreen[1] = snapshot.data!;
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

  createLibraryPreview() {
    if (!userService.isConnected || userService.favorites.isEmpty) {
      return Container();
    }
    var libraryEntries = userService.getFavoritesEntries(6);
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
                        if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                          userService.podcastProposalsHomeScreen[genre] = snapshot.data!;
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
}