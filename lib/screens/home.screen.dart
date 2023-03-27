import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/services/quests/quest.service.dart';
import 'package:Talkaboat/services/state/state.service.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/utils/scaffold_wave.dart';
import 'package:Talkaboat/widgets/home-categories.dart';
import 'package:Talkaboat/widgets/podcasts/podcast-home-suggested.widget.dart';
import 'package:Talkaboat/widgets/videos/video-home-suggested.widget.dart';
import 'package:flutter/material.dart';
import 'package:Talkaboat/widgets/quests/quest-list.widget.dart';
import '../widgets/home-app-bar.widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/home-news.widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.setEpisode, required this.selectTab}) : super(key: key);
  final Function setEpisode;
  final Function selectTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final userService = getIt<UserService>();
  final questService = getIt<QuestService>();

  refresh() {
    //setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: ScaffoldWave(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: HomeAppBarWidget(
            refresh: refresh,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.0),
                    border: const Border(bottom: BorderSide(color: Color.fromRGBO(164, 202, 255, 1))),
                  ),
                  child: TabBar(
                    labelColor: const Color.fromRGBO(188, 140, 75, 1),
                    indicatorColor: const Color.fromRGBO(188, 140, 75, 1),
                    unselectedLabelColor: const Color.fromRGBO(164, 202, 255, 1),
                    tabs: [
                      Tab(text: AppLocalizations.of(context)!.suggested),
                      Tab(text: AppLocalizations.of(context)!.categories),
                      Tab(text: AppLocalizations.of(context)!.news),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(children: [
          GetSuggestedTab(),
          const HomeScreenCategoriesTab(),
          const HomeNewsScreenWidget(),
        ]),
      ),
    );
  }

  Widget GetSuggestedTab() {
    if(userService.currentView.label == ContentViews.Podcasts) {
      return PodcastHomeScreenSuggestedTab(widget.selectTab);
    } else {
      return VideoHomeScreenSuggestedTab(widget.selectTab);
    }
  }
}

class CustomAppBar extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(0, size.height);
    path.quadraticBezierTo(size.width / 4, size.height - 40, size.width / 2, size.height - 20);

    path.quadraticBezierTo(3 / 4 * size.width, size.height, size.width, size.height - 20);

    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}
