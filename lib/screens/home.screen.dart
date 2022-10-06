import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/screens/settings/settings.screen.dart';
import 'package:Talkaboat/services/quests/quest.service.dart';
import 'package:Talkaboat/services/state/state.service.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/widgets/home-categories.dart';
import 'package:Talkaboat/widgets/home-suggested.widget.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

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

  refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Good morning'),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: IconButton(
                      icon: const Icon(Icons.settings),
                      tooltip: '',
                      onPressed: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                alignment: Alignment.bottomCenter,
                                curve: Curves.bounceOut,
                                type: PageTransitionType.rightToLeftWithFade,
                                duration: const Duration(milliseconds: 500),
                                reverseDuration: const Duration(milliseconds: 500),
                                child: SettingsScreen(refresh: refresh)));
                      },
                    ),
                  )
                ],
                bottom: const TabBar(tabs: [
                  Tab(
                    text: "Suggested",
                  ),
                  Tab(
                    text: "Categories",
                  ),
                  Tab(
                    text: "News",
                  )
                ]),
              ),
              body: TabBarView(children: [
                HomeScreenSuggestedTab(widget.selectTab),
                HomeScreenCategoriesTab(),
                Container(),
              ]),
            )));
  }
}
