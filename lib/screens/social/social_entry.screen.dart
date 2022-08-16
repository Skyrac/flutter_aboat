import 'dart:async';

import 'package:Talkaboat/models/user/social-user.model.dart';
import 'package:Talkaboat/services/user/social.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../../injection/injector.dart';
import '../../models/user/user-info.model.dart';
import '../../services/user/user.service.dart';
import '../../themes/colors.dart';
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
  final friendController = TextEditingController();
  Timer? _debounce;
  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabIndex);
    friendController.addListener(() {if (_debounce?.isActive ?? false) _debounce?.cancel();
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
                title: Text("Social", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),),
                actions: [
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
    return Center(child: Text("There are no posts in your feed yet."));
  }


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
                  child: TextField(controller: friendController,  decoration: InputDecoration(
                    hintText: 'Search friends...',
                    suffixIcon: IconButton(
                      onPressed: friendController.clear,
                      icon: Icon(Icons.clear, color: friendController.text.isEmpty ? Colors.transparent : DefaultColors.primaryColor),
                    ),))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                child: Card(child: InkWell(
                  onTap: (() async {
                    setState(() { });
                  }),
                    child: Icon(Icons.search, size: 30,)),),
              )
            ],
          ),
              Expanded(
                child: SizedBox(
                    width: size.width > 640 ? 640 : size.width,
                    child:
                friendController.text.isEmpty ? showFriends() : showFriendsAndPossibleFriends()),
              )
        ]),
      ),
    );
  }

  showFriends() {
    return ListView(scrollDirection: Axis.vertical,
        children: createFriendCards(socialService.getPendingAndFriendsLocally())
    );
  }

  SocialUser? activeRequest;

  showFriendsAndPossibleFriends() {
    return FutureBuilder<List<SocialUser>>(builder: (context, snapshot) {
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
              return ListView(scrollDirection: Axis.vertical,
                children: createFriendCards(data)
              );

          }
        }
      }
      return const Center(child: CircularProgressIndicator());
    }, future: socialService.searchFriends(friendController.text));
  }

  createFriendCards(List<SocialUser> data) {
    if(data.isEmpty) {
      return [SizedBox()];
    }
    var size = MediaQuery.of(context).size;
    double width = size.width > 640 ? 640 : size.width;
    List<Widget> widgets = [];
    data.forEach((element) {
      widgets.add(
        Card(child: Container(height: 120, width: width, child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(element.image ?? "https://www.gravatar.com/avatar/00000000000000000000000000000000?d=wavatar&f=y")),
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

                  Text(element.name ?? "No name", style: Theme.of(context).textTheme.bodyLarge,),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: Text("@${element.userName!}"),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: Text(element.description ?? "", overflow: TextOverflow.ellipsis,),
                )
            ],),
              )),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
                children: [
            IconButton(onPressed: () async {
              if(socialService.isFriend(element.userId)) {
                await socialService.removeFriend(element);
              } else if(socialService.isRequest(element.userId)) {
                if(activeRequest != element) {
                  activeRequest = element;
                } else {
                  await socialService.acceptFriend(activeRequest);
                  activeRequest = null;
                }
              } else {
                await socialService.requestFriends(element);
              }
              setState(() { });
            }, icon: socialService.isFriend(element.userId)
                ? Icon(Icons.remove) : socialService.isPending(element.userId)
                ? Icon(Icons.hourglass_empty) : socialService.isRequest(element.userId)
                ? (activeRequest == element ?  Icon(Icons.check) : Icon(Icons.question_mark)) : Icon(Icons.add)),
            activeRequest != element ? SizedBox() :
            IconButton(onPressed: () async {
              await socialService.declineFriend(element);
              activeRequest = null;
              setState(() { });
            }, icon: Icon(Icons.block))])
          ],
        )))
      );
    });
    return widgets;
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
