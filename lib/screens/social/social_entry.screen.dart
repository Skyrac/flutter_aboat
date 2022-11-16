import 'dart:async';

import 'package:Talkaboat/models/user/social-user.model.dart';
import 'package:Talkaboat/services/user/social.service.dart';
import 'package:Talkaboat/widgets/login-button.widget.dart';
import 'package:flutter/material.dart';

import '../../injection/injector.dart';
import '../../services/user/user.service.dart';
import '../../themes/colors.dart';

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
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              "Social",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            actions: const [
              /*
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                    child: IconButton(
                      icon: Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                      print(_tabController.index);
                      },
                    ),
                  )
                    */
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
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
          body: userService.isConnected
              ? TabBarView(
                  controller: _tabController,
                  children: [
                    createFeedBody(),
                    createFriendBody(),
                  ],
                )
              : Center(child: LoginButton(widget.escapeWithNav))),
    );
  }

  Widget createFeedBody() {
    return const Center(child: Text("There are no posts in your feed yet."));
  }

  Widget createFriendBody() {
    var size = MediaQuery.of(context).size;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(mainAxisSize: MainAxisSize.max, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width: size.width / 4 * 3,
                  child: TextField(
                      controller: friendController,
                      decoration: InputDecoration(
                        hintText: 'Search friends...',
                        suffixIcon: IconButton(
                          onPressed: friendController.clear,
                          icon: Icon(Icons.clear,
                              color: friendController.text.isEmpty ? Colors.transparent : DefaultColors.primaryColor),
                        ),
                      ))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                child: Card(
                  child: InkWell(
                      onTap: (() async {
                        setState(() {});
                      }),
                      child: const Icon(
                        Icons.search,
                        size: 30,
                      )),
                ),
              )
            ],
          ),
          Expanded(
            child: SizedBox(
                width: size.width > 640 ? 640 : size.width,
                child: friendController.text.isEmpty ? showFriends() : showFriendsAndPossibleFriends()),
          )
        ]),
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
    data.forEach((element) {
      widgets.add(Card(
          child: SizedBox(
              height: 120,
              width: width,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(element.image ??
                            "https://www.gravatar.com/avatar/00000000000000000000000000000000?d=wavatar&f=y")),
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
    });
    return widgets;
  }
}
