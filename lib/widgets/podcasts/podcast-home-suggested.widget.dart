import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/podcasts/podcast-rank.model.dart';
import 'package:Talkaboat/screens/search.screen.dart';
import 'package:Talkaboat/services/ads/ad-manager.service.dart';
import 'package:Talkaboat/services/audio/podcast.service.dart';
import 'package:Talkaboat/services/repositories/podcast.repository.dart';
import 'package:Talkaboat/services/state/state.service.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/widgets/podcasts/podcast-favorites.widget.dart';
import 'package:Talkaboat/widgets/podcasts/podcast-list-horizontal.widget.dart';
import 'package:Talkaboat/widgets/podcasts/podcast-list.widget.dart';
import 'package:Talkaboat/widgets/quests/quest-list.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../stormm-missions.widget.dart';

class PodcastHomeScreenSuggestedTab extends StatefulWidget {
  const PodcastHomeScreenSuggestedTab(this.selectTab, {Key? key}) : super(key: key);

  final Function selectTab;


  @override
  State<PodcastHomeScreenSuggestedTab> createState() => _PodcastHomeScreenSuggestedTabState();
}

class _PodcastHomeScreenSuggestedTabState<T extends PodcastHomeScreenSuggestedTab> extends State<PodcastHomeScreenSuggestedTab>
    with WidgetsBindingObserver {
  final userService = getIt<UserService>();
  final podcastService = getIt<PodcastService>();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    AdManager.preLoadAd(false);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ImageCache _imageCache = PaintingBinding.instance!.imageCache!;

    _imageCache.clear();

    _imageCache.clearLiveImages();
    AdManager.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint("Resumed");
        AdManager.preLoadAd(false);
        break;
      case AppLifecycleState.inactive:

        debugPrint("Inactive");
        AdManager.dispose();
        break;
      case AppLifecycleState.paused:

        debugPrint("Paused");
        AdManager.dispose();
        break;
      case AppLifecycleState.detached:

        debugPrint("Detached");
        AdManager.dispose();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ...createOnlyLoggedInWidgets(context),
          PodcastListHorizontal(
              future: podcastService.getRandomPodcastsByRank( 10, Rank.NewComer),
              title: "Newcomer",
              multiplier: "x1.5",
              seeAllCb: (() {
                Navigator.push(
                  context,
                  buildSearchScreenTransition(
                    rank: Rank.NewComer,
                    title: "Newcomers",
                  ),
                );
              })),
          const StormmMissionWidget(),
          const SizedBox(height: 20),
          PodcastListHorizontal(
              future: podcastService.getRandomPodcastsByRank( 10, Rank.Receiver),
              title: "Receiver",
              multiplier: "x1.25",
              seeAllCb: (() {
                Navigator.push(
                  context,
                  buildSearchScreenTransition(
                    rank: Rank.Receiver,
                    title: "Receivers",
                  ),
                );
              })),
          const SizedBox(height: 20),
          PodcastListHorizontal(
              future: podcastService.getRandomPodcastsByRank( 10, Rank.Hodler),
              title: "Holder",
              multiplier: "x1.1",
              seeAllCb: (() {
                Navigator.push(
                  context,
                  buildSearchScreenTransition(
                    rank: Rank.Hodler,
                    title: "Hodlers",
                  ),
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
      createTaskBar(context, AppLocalizations.of(context)!.tasks),
      const SizedBox(height: 20),
      PodcastListHorizontal(
          future: PodcastRepository.getRecentlyListened(), title: AppLocalizations.of(context)!.recentlyListened),
      const SizedBox(height: 20),
      createFavoritesList(context),
      const SizedBox(height: 20),
    ];
  }

  Widget createTaskBar(BuildContext context, String title) {
    if (!userService.isConnected) {
      return Container();
    }
    return  QuestListWidget(
            direction: Axis.horizontal);
  }

  Widget createFavoritesList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(AppLocalizations.of(context)!.favorites, style: Theme.of(context).textTheme.titleLarge),
          InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: (() {
                widget.selectTab("Favorites", 2);
              }),
              child: Row(children: [
                Text(
                  AppLocalizations.of(context)!.seeAll,
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
                  return PodcastListFavoritesWidget(searchResults: snapshot.data!.take(10).toList());
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
                          debugPrint("${snapshot.data}");
                          return PodcastListWidget(direction: Axis.horizontal, searchResults: userService.podcastProposalsHomeScreen[genre]!);
                        }
                      }
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                  future: PodcastRepository.getRandomPodcast(10, userService.selectedLanguage),
                ))
    ]);
  }
}
