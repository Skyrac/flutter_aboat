import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/services/quests/quest.service.dart';
import 'package:Talkaboat/services/state/state.service.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/widgets/home-categories.dart';
import 'package:Talkaboat/widgets/home-suggested.widget.dart';
import 'package:flutter/material.dart';
import 'package:Talkaboat/widgets/quests/quest-list.widget.dart';
import '../widgets/home-app-bar.widget.dart';
import '../widgets/library-preview.widget.dart';

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

  refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(155),
          child: HomeAppBarWidget(refresh: refresh),
        ),
        body: TabBarView(children: [
          HomeScreenSuggestedTab(widget.selectTab),
          HomeScreenCategoriesTab(),
          Container(),
        ]),
      ),
    );
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
}
