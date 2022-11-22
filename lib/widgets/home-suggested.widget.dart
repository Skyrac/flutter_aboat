import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/podcasts/podcast-rank.model.dart';
import 'package:Talkaboat/screens/search.screen.dart';
import 'package:Talkaboat/services/audio/podcast.service.dart';
import 'package:Talkaboat/services/repositories/podcast.repository.dart';
import 'package:Talkaboat/services/state/state.service.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/widgets/podcast-favorites.widget.dart';
import 'package:Talkaboat/widgets/podcast-list-horizontal.widget.dart';
import 'package:Talkaboat/widgets/podcast-list.widget.dart';
import 'package:Talkaboat/widgets/quests/quest-list.widget.dart';
import 'package:flutter/material.dart';

class HomeScreenSuggestedTab extends StatefulWidget {
  const HomeScreenSuggestedTab(this.selectTab, this.escapeWithNav, {Key? key}) : super(key: key);

  final Function selectTab;
  final Function escapeWithNav;

  @override
  State<HomeScreenSuggestedTab> createState() => _HomeScreenSuggestedTabState();
}

class _HomeScreenSuggestedTabState extends State<HomeScreenSuggestedTab> {
  final homeState = getIt<StateService>();
  final userService = getIt<UserService>();
  final podcastService = getIt<PodcastService>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ...createOnlyLoggedInWidgets(context),
          PodcastListHorizontal(widget.escapeWithNav,
              future: podcastService.search("", amount: 10, offset: 0, rank: PodcastRank.NewComer),
              title: "Newcomer",
              multiplier: "x1.5", seeAllCb: (() {
            Navigator.push(
              context,
              buildSearchScreenTransition(widget.escapeWithNav, rank: PodcastRank.NewComer, title: "Newcomers"),
            );
          })),
          const SizedBox(height: 20),
          PodcastListHorizontal(widget.escapeWithNav,
              future: podcastService.search("", amount: 10, offset: 0, rank: PodcastRank.Receiver),
              title: "Receiver",
              multiplier: "x1.25", seeAllCb: (() {
            Navigator.push(
              context,
              buildSearchScreenTransition(widget.escapeWithNav, rank: PodcastRank.Receiver, title: "Receivers"),
            );
          })),
          const SizedBox(height: 20),
          PodcastListHorizontal(widget.escapeWithNav,
              future: podcastService.search("", amount: 10, offset: 0, rank: PodcastRank.Hodler),
              title: "Holder",
              multiplier: "x1.1", seeAllCb: (() {
            Navigator.push(
              context,
              buildSearchScreenTransition(widget.escapeWithNav, rank: PodcastRank.Hodler, title: "Hodlers"),
            );
          })),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  List<Widget> createOnlyLoggedInWidgets(BuildContext context) {
    if (!userService.isConnected) {
      return [];
    }
    return <Widget>[
      const SizedBox(height: 5),
      createTaskBar(context, 'Tasks'),
      const SizedBox(height: 20),
      PodcastListHorizontal(widget.escapeWithNav,
          future: PodcastRepository.getRecentlyListened(), title: "Recently Listened"),
      const SizedBox(height: 20),
      createFavoritesList(context),
      const SizedBox(height: 20),
    ];
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
        FutureBuilder(
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
                  return PodcastListFavoritesWidget(widget.escapeWithNav, searchResults: snapshot.data!.take(10).toList());
                }
              }
              // TODO: display a nice text
              return Container();
            }
            return const Center(child: CircularProgressIndicator());
          },
          future: userService.getFavorites(),
        )
      ]),
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
                  widget.escapeWithNav,
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
                          return PodcastListWidget(widget.escapeWithNav,
                              direction: Axis.horizontal, searchResults: homeState.map[genre]!);
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
