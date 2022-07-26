import 'package:Talkaboat/services/user/social.service.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../../injection/injector.dart';
import '../../services/user/user.service.dart';
import '../login.screen.dart';

class SocialEntryScreen extends StatefulWidget {
  const SocialEntryScreen({Key? key}) : super(key: key);

  @override
  State<SocialEntryScreen> createState() => _SocialEntryScreenState();
}

class _SocialEntryScreenState extends State<SocialEntryScreen> with SingleTickerProviderStateMixin {
  final userService = getIt<UserService>();
  late TabController _tabController;
  final socialService = getIt<SocialService>();
  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabIndex);
    super.initState();

  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabIndex);
    _tabController.dispose();
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
                title: Text("Social", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),),
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                    child: IconButton(
                      icon: Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                      print(_tabController.index);
                      },
                    ),
                  )
                ],
                bottom: TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(icon: Icon(Icons.feed, color: Colors.white),),
                    Tab(icon: Icon(Icons.emoji_people, color: Colors.white,)),
                  ],
                ),

              ),
              body: userService.isConnected
                  ? TabBarView(
                controller: _tabController,
                  children: [
                    createFeedBody(),
                    createFriendBody(),
                  ],)
                  : createLoginButton()),
        );
  }

  Widget createFeedBody() {
    return Icon(Icons.directions_car);
  }

  final friendController = TextEditingController();

  Widget createFriendBody() {
    var size = MediaQuery.of(context).size;
    return  SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,

            children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width: size.width / 4 * 3,
                  child: TextField(controller: friendController,)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                child: Card(child: InkWell(
                  onTap: (() async { await socialService.SearchFriends(friendController.text); }),
                    child: Icon(Icons.search, size: 36,)),),
              )
            ],
          ),
        ]),
      ),
    );
  }


  createLoginButton() => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Card(
          child: InkWell(
            onTap: (() {
              Navigator.push(
                  context,
                  PageTransition(
                      alignment: Alignment.bottomCenter,
                      curve: Curves.bounceOut,
                      type: PageTransitionType.fade,
                      duration: const Duration(milliseconds: 300),
                      reverseDuration: const Duration(milliseconds: 200),
                      child: LoginScreen(() => setState(() {}))));
            }),
            child: SizedBox(
                height: 80,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Text(
                    "Login",
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                )),
          ),
        ),
      ),
    ),
  );
}
