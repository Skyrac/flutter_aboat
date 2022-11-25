import 'dart:async';

import 'package:Talkaboat/models/chat/chat-dtos.dart';
import 'package:Talkaboat/services/hubs/chat/chat.service.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/widgets/chat-input.widget.dart';
import 'package:Talkaboat/widgets/chat.widget.dart';
import 'package:Talkaboat/widgets/episode-list-with-header.widget.dart';
import 'package:Talkaboat/widgets/podcast-details.widget.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../injection/injector.dart';
import '../models/search/search_result.model.dart';
import '../services/audio/podcast.service.dart';
import '../themes/colors.dart';
import '../utils/scaffold_wave.dart';
import '../widgets/podcast-detail-sliver.widget.dart';

class PodcastDetailScreen extends StatefulWidget {
  const PodcastDetailScreen(this.escapeWithNav, {Key? key, required this.podcastSearchResult}) : super(key: key);

  final SearchResult podcastSearchResult;
  final Function escapeWithNav;

  @override
  State<PodcastDetailScreen> createState() => _PodcastDetailScreenState();
}

class _PodcastDetailScreenState extends State<PodcastDetailScreen> with SingleTickerProviderStateMixin {
  final podcastService = getIt<PodcastService>();
  final ChatService chatService = getIt<ChatService>();
  final userService = getIt<UserService>();
  late TabController tabController;
  final focusNode = FocusNode();
  int currentTab = 0;
  Future<SearchResult?>? _getPodcast;

  ChatMessageDto? replyMessage;
  ChatMessageDto? editedMessage;

  @override
  initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this, animationDuration: Duration.zero);
    tabController.addListener(() {
      debugPrint(
          "tabcontroller update ${tabController.indexIsChanging} ${tabController.index} ${tabController.previousIndex}");
      setState(() {
        currentTab = tabController.index;
      });
    });
    _getPodcast = getPodcast();
  }

  @override
  dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<SearchResult?> getPodcast() async {
    if (widget.podcastSearchResult.roomId != null) {
      return widget.podcastSearchResult;
    } else if (widget.podcastSearchResult.id != null) {
      return await podcastService.getPodcastDetails(widget.podcastSearchResult.id!, "asc", -1);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    userService.UpdatePodcastVisitDate(widget.podcastSearchResult.id);
    final size = MediaQuery.of(context).size;

    return ScaffoldWave(
        height: 33,
        header: SliverPersistentHeader(
          delegate: PodcastDetailSliver(widget.escapeWithNav,
              expandedHeight: size.height * 0.4, podcast: widget.podcastSearchResult, controller: tabController),
          pinned: true,
        ),
        appBar: AppBar(
          centerTitle: false,
          leadingWidth: 35,
          titleSpacing: 3,
          backgroundColor: const Color.fromRGBO(29, 40, 58, 1),
          title: Text(
            widget.podcastSearchResult.title!,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color.fromRGBO(99, 163, 253, 1),
                ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: IconButton(
                  icon: const Icon(Icons.share, color: Color.fromRGBO(99, 163, 253, 0.5), size: 36),
                  tooltip: '',
                  onPressed: () => {
                        //TODO: Geräte Abhängigkeit prüfen
                        Share.share(
                            "Check the Podcast ${widget.podcastSearchResult.title} on Talkaboat.online mobile App! Start listening and earn while supporting new and upcoming podcasters.\n\n Download it now on \nAndroid: https://play.google.com/store/apps/details?id=com.aboat.talkaboat\n",
                            subject: "Check this out! A Podcast on Talkaboat.online.")
                      }),
            ),
            !userService.isConnected
                ? const SizedBox()
                : userService.isInFavorites(widget.podcastSearchResult.id)
                    // : isFav
                    ? Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: IconButton(
                          icon: const Icon(Icons.favorite, color: Color.fromRGBO(99, 163, 253, 0.5), size: 36),
                          tooltip: '',
                          onPressed: () async {
                            await userService.removeFromFavorites(widget.podcastSearchResult.id!);
                            setState(() {});
                          },
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: IconButton(
                          icon: const Icon(Icons.favorite_border, color: Color.fromRGBO(99, 163, 253, 0.5), size: 36),
                          tooltip: '',
                          onPressed: () async {
                            await userService.addToFavorites(widget.podcastSearchResult.id!);
                            setState(() {});
                          },
                        ),
                      ),
          ],
        ),
        body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              DefaultColors.primaryColor.shade900,
              DefaultColors.secondaryColor.shade900,
              DefaultColors.secondaryColor.shade900
            ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: FutureBuilder<SearchResult?>(
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
                    return createCustomScrollView(snapshot.data!);
                  } else {
                    return const Center(
                      child: Text(
                        'No data found for this podcast. Please try again later!',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              future: _getPodcast,
            )));
  }

  List<Widget> createTabs(int podcastId, int roomId) {
    return [
      EpisodeHeaderList(
        podcastId: podcastId,
        escapeWithNav: widget.escapeWithNav,
      ),
      PodcastDetails(
        podcastId: podcastId,
        escapeWithNav: widget.escapeWithNav,
      ),
      Chat(
        focusNode: focusNode,
        roomId: roomId,
        messageType: 1,
        replyToMessage: (message) {
          setState(() {
            editedMessage = null;
            replyMessage = message;
          });
        },
        editMessage: (message) {
          setState(() {
            replyMessage = null;
            editedMessage = message;
          });
        },
        cancelReplyAndEdit: () {
          setState(() {
            replyMessage = null;
            editedMessage = null;
          });
        },
      ),
    ];
  }

  Widget createCustomScrollView(SearchResult podcastSearchResult) {
    final size = MediaQuery.of(context).size;

    final tabs = createTabs(podcastSearchResult.id!, podcastSearchResult.roomId!);

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
            constraints: BoxConstraints(minHeight: size.height * 0.5),
            child: currentTab == 0 ? tabs[currentTab] : SingleChildScrollView(child: tabs[currentTab])),
        tabController.index == 2
            ? ChatInput(
                roomId: podcastSearchResult.roomId!,
                focusNode: focusNode,
                messageType: 1,
                cancelReplyAndEdit: () {
                  setState(() {
                    replyMessage = null;
                    editedMessage = null;
                  });
                })
            : const SizedBox()
      ],
    );
  }
}
