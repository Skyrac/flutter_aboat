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

class VideoHomeScreenSuggestedTab extends StatefulWidget {
  const VideoHomeScreenSuggestedTab(this.selectTab, {Key? key}) : super(key: key);

  final Function selectTab;


  @override
  State<VideoHomeScreenSuggestedTab> createState() => _VideoHomeScreenSuggestedTabState();
}

class _VideoHomeScreenSuggestedTabState<T extends VideoHomeScreenSuggestedTab> extends State<VideoHomeScreenSuggestedTab>
    with WidgetsBindingObserver {
  final homeState = getIt<StateService>();
  final userService = getIt<UserService>();
  final podcastService = getIt<PodcastService>();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    debugPrint("Init");
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
          const StormmMissionWidget(),
          const SizedBox(height: 20),
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
                    setState(() {
                    });
                    setState(() {
                      r = !r;
                    });
                  },
                  icon: const Icon(Icons.refresh))
            ],
          )),
      SizedBox(
          height: 224,
          child: QuestListWidget(
            direction: Axis.horizontal,
            checkUpdate: r,
          ))
    ]);
  }

  bool r = false;
}
