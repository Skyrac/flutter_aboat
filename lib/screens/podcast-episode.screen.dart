import 'package:Talkaboat/models/chat/chat-dtos.dart';
import 'package:Talkaboat/navigator_keys.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/widgets/chat-input.widget.dart';
import 'package:Talkaboat/widgets/chat.widget.dart';
import 'package:Talkaboat/widgets/podcast-episode-details.widget.dart';
import 'package:Talkaboat/widgets/podcast-episode-podcast.widget.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../injection/injector.dart';
import '../models/podcasts/episode.model.dart';
import '../models/podcasts/podcast.model.dart';
import '../models/search/search_result.model.dart';
import '../services/audio/podcast.service.dart';
import '../themes/colors.dart';
import '../utils/common.dart';
import '../utils/scaffold_wave.dart';
import '../widgets/bottom-sheets/playlist.bottom-sheet.dart';
import '../widgets/podcast-episode-sliver.widget.dart';
import 'login.screen.dart';

class PodcastEpisodeScreen extends StatefulWidget {
  final Episode episode;
  final Duration position;
  final Function isActiv;

  const PodcastEpisodeScreen({super.key, required this.episode, required this.position, required this.isActiv});

  @override
  State<PodcastEpisodeScreen> createState() => _PodcastEpisodeScreenState();
}

class _PodcastEpisodeScreenState extends State<PodcastEpisodeScreen> with SingleTickerProviderStateMixin {
  final podcastService = getIt<PodcastService>();
  final userService = getIt<UserService>();
  Future<SearchResult?>? _getPodcast;

  late TabController tabController;
  final focusNode = FocusNode();
  int currentTab = 0;

  ChatMessageDto? replyMessage;
  ChatMessageDto? editedMessage;

  final ScrollController controller = ScrollController();
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
    _getPodcast = getPodcast(widget.episode, widget.episode.podcastId);
  }

  @override
  dispose() {
    tabController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      Provider.of<SelectEpisodePage>(context, listen: false).changeTrue();
    });
    userService.UpdatePodcastVisitDate(widget.episode.podcastId);
    return WillPopScope(
      onWillPop: () async {
        Provider.of<SelectEpisodePage>(context, listen: false).changeFalse();
        return true;
      },
      child: ScaffoldWave(
        height: 33,
        appBar: AppBar(
          centerTitle: false,
          leadingWidth: 35,
          titleSpacing: 3,
          backgroundColor: const Color.fromRGBO(29, 40, 58, 1),
          title: Text(
            widget.episode.title!,
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
                        Share.share(AppLocalizations.of(context)!.share(widget.episode!.title),
                            subject: AppLocalizations.of(context)!.share2)
                      }),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                icon: const Icon(Icons.format_list_bulleted, color: Color.fromRGBO(99, 163, 253, 0.5), size: 36),
                tooltip: '',
                onPressed: () {
                  if (!userService.isConnected) {
                    NavigatorKeys.navigatorKeyMain.currentState!.push(PageTransition(
                        alignment: Alignment.bottomCenter,
                        curve: Curves.bounceOut,
                        type: PageTransitionType.rightToLeftWithFade,
                        duration: const Duration(milliseconds: 500),
                        reverseDuration: const Duration(milliseconds: 500),
                        child: LoginScreen(true, refreshParent: () => setState(() {}))));
                  } else {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                        context: context,
                        builder: (context) => PlaylistBottomSheet(episodeToAdd: widget.episode));
                  }
                },
              ),
            )
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
          ),
        ),
      ),
    );
  }

  List<Widget> createTabs(Episode episode, int roomId, Duration position, ScrollController controller) {
    return [
      PodcastEpisodeDetails(
        episode: episode,
        position: position,
      ),
      PodcastEpisodePodcast(podcastId: episode.podcastId!),
      Chat(
        controller: controller,
        focusNode: focusNode,
        roomId: roomId,
        messageType: 2,
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
    final tabs = createTabs(widget.episode, podcastSearchResult.roomId!, widget.position, controller);

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CustomScrollView(shrinkWrap: true, controller: controller, slivers: [
          SliverPersistentHeader(
            delegate:
                PodcastEpisodeSliver(expandedHeight: size.height * 0.4, episode: widget.episode, controller: tabController),
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Container(constraints: BoxConstraints(minHeight: size.height * 0.5), child: tabs[currentTab]),
          )
        ]),
        tabController.index == 2
            ? ChatInput(
                roomId: podcastSearchResult.roomId!,
                focusNode: focusNode,
                messageType: 2,
                replyMessage: replyMessage,
                editedMessage: editedMessage,
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

  Future<Podcast?> getPodcast(Episode? episode, int? podcastId) {
    if (episode != null) {
      if (episode.podcast != null) {
        return Future.value(episode.podcast);
      }
    }
    if (podcastId != null || (episode != null && episode.podcastId != null)) {
      return podcastService.getPodcastDetails(podcastId ?? episode!.podcastId!, "asc", 1);
    }
    return Future.value(null);
  }
}
