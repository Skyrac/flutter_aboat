import 'dart:async';

import 'package:Talkaboat/models/user/social-user.model.dart';
import 'package:Talkaboat/services/user/social.service.dart';
import 'package:Talkaboat/widgets/login-button.widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../injection/injector.dart';
import '../../services/user/user.service.dart';
import '../../utils/scaffold_wave.dart';

class SocialEntryScreen extends StatefulWidget {
  const SocialEntryScreen(this.escapeWithNav, {Key? key}) : super(key: key);

  final Function escapeWithNav;

  @override
  State<SocialEntryScreen> createState() => _SocialEntryScreenState();
}

class _SocialEntryScreenState extends State<SocialEntryScreen> with SingleTickerProviderStateMixin {
  final userService = getIt<UserService>();
  late TabController _tabController;
  final socialService = getIt<SocialService>();
  final friendController = TextEditingController();
  Timer? _debounce;
  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabIndex);
    friendController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        _handleTabIndex();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabIndex);
    _tabController.dispose();
    _debounce?.cancel();
    friendController.dispose();
    super.dispose();
  }

  void _handleTabIndex() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: ScaffoldWave(
            appBar: PreferredSize(
                preferredSize: const Size.fromHeight(100),
                child: AppBar(
                  backgroundColor: const Color.fromRGBO(29, 40, 58, 1),
                  leadingWidth: 45,
                  titleSpacing: 10,
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
                        child: const TabBar(
                          labelColor: Color.fromRGBO(188, 140, 75, 1),
                          indicatorColor: Color.fromRGBO(188, 140, 75, 1),
                          unselectedLabelColor: Color.fromRGBO(164, 202, 255, 1),
                          tabs: [
                            Tab(
                              icon: Icon(Icons.feed, color: Colors.white),
                            ),
                            Tab(
                                icon: Icon(
                              Icons.emoji_people,
                              color: Colors.white,
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  title: Container(margin: const EdgeInsets.fromLTRB(7, 5, 0, 0), child: const Text("Social")),
                )),
            body: userService.isConnected
                ? TabBarView(
                    children: [
                      createFeedBody(),
                      createFriendBody(),
                    ],
                  )
                : Center(child: LoginButton(widget.escapeWithNav))),
      ),
    );
    //);
  }

  Widget createFeedBody() {
    return const Center(child: Text("There are no posts in your feed yet."));
  }

  Widget createFriendBody() {
    var size = MediaQuery.of(context).size;
    return SafeArea(
      child: Column(mainAxisSize: MainAxisSize.max, children: [
        buildSearchField(context),
        Expanded(
          child: SizedBox(
              width: size.width > 640 ? 640 : size.width,
              child: friendController.text.isEmpty ? showFriends() : showFriendsAndPossibleFriends()),
        )
      ]),
    );
  }

  String search = '';

  Widget buildSearchField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: const BoxDecoration(
              color: Color.fromRGBO(29, 40, 58, 1.0),
              border: Border(bottom: BorderSide(width: 2, color: Color.fromRGBO(188, 140, 75, 1.0)))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: TextField(
                controller: friendController,
                onChanged: ((text) {
                  setState(() {
                    search = text.toLowerCase();
                  });
                }),
                decoration: const InputDecoration(
                    border: InputBorder.none, hintText: "Search friends...", suffixIcon: Icon(Icons.search)),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
        ),
      ),
    );
  }

  showFriends() {
    return ListView(
        scrollDirection: Axis.vertical, children: createFriendCards(socialService.getPendingAndFriendsLocally()));
  }

  SocialUser? activeRequest;

  showFriendsAndPossibleFriends() {
    return FutureBuilder<List<SocialUser>>(
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

              final data = snapshot.data;
              if (data != null && data.isNotEmpty) {
                return ListView(scrollDirection: Axis.vertical, children: createFriendCards(data));
              }
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
        future: socialService.searchFriends(friendController.text));
  }

  createFriendCards(List<SocialUser> data) {
    if (data.isEmpty) {
      return [const SizedBox()];
    }
    var size = MediaQuery.of(context).size;
    double width = size.width > 640 ? 640 : size.width;
    List<Widget> widgets = [];
    for (var element in data) {
      widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: SizedBox(
              width: width,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.only(right: 5),
                    width: 100,
                    height: 100,
                    child: Center(
                      child: Stack(
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                  child: CachedNetworkImage(
                                imageUrl: element.image ??
                                    "https://www.gravatar.com/avatar/00000000000000000000000000000000?d=wavatar&f=y",
                                cacheManager: CacheManager(Config(
                                    element.image ??
                                        "https://www.gravatar.com/avatar/00000000000000000000000000000000?d=wavatar&f=y",
                                    stalePeriod: const Duration(days: 2))),
                                fit: BoxFit.fill,
                                placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ))),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: SizedBox(
                        height: 70,
                        width: width - 175,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              element.name ?? "No name",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3.0),
                              child: Text("@${element.userName!}"),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3.0),
                              child: Text(
                                element.description ?? "",
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      )),
                  Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    IconButton(
                        onPressed: () async {
                          if (socialService.isFriend(element.userId)) {
                            await socialService.removeFriend(element);
                          } else if (socialService.isRequest(element.userId)) {
                            if (activeRequest != element) {
                              activeRequest = element;
                            } else {
                              await socialService.acceptFriend(activeRequest);
                              activeRequest = null;
                            }
                          } else {
                            await socialService.requestFriends(element);
                          }
                          setState(() {});
                        },
                        icon: socialService.isFriend(element.userId)
                            ? const Icon(Icons.remove)
                            : socialService.isPending(element.userId)
                                ? const Icon(Icons.hourglass_empty)
                                : socialService.isRequest(element.userId)
                                    ? (activeRequest == element ? const Icon(Icons.check) : const Icon(Icons.question_mark))
                                    : const Icon(Icons.add)),
                    activeRequest != element
                        ? const SizedBox()
                        : IconButton(
                            onPressed: () async {
                              await socialService.declineFriend(element);
                              activeRequest = null;
                              setState(() {});
                            },
                            icon: const Icon(Icons.block))
                  ])
                ],
              ))));
    }
    return widgets;
  }
}
