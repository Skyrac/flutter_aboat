import 'dart:convert';

import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/widgets/login-button.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../injection/injector.dart';
import '../models/chat/chat-dtos.dart';
import '../models/chat/join-room-dto.dart';
import '../models/chat/message-history-request-dto.dart';
import '../models/podcasts/episode.model.dart';
import '../models/podcasts/podcast.model.dart';
import '../models/search/search_result.model.dart';
import '../services/audio/audio-handler.services.dart';
import '../services/audio/podcast.service.dart';
import '../services/hubs/chat/chat-hub.service.dart';
import '../themes/colors.dart';
import '../utils/scaffold_wave.dart';
import '../widgets/episode-preview.widget.dart';
import '../widgets/podcast-detail-sliver.widget.dart';

class PodcastDetailScreen extends StatefulWidget {
  final SearchResult? podcastSearchResult;
  final int? podcastId;
  final AppBar? appBar;
  const PodcastDetailScreen({Key? key, this.podcastSearchResult, this.podcastId, this.appBar}) : super(key: key);

  @override
  State<PodcastDetailScreen> createState() => _PodcastDetailScreenState();
}

class _PodcastDetailScreenState extends State<PodcastDetailScreen> {
  final audioPlayer = getIt<AudioPlayerHandler>();
  final podcastService = getIt<PodcastService>();
  final chatHub = getIt<ChatHubService>();
  Future<SearchResult?>? getPodcast;
  Future<List<ChatMessageDto>>? _getMessages;

  var sort = "asc";
  var isDescOpen = false;
  var userService = getIt<UserService>();
  void initState() {
    super.initState();
    getPodcast = GetPodcast();
  }

  selectEpisode(int index, List<Episode> data) async {
    var selectedEpisode = data[index];
    if (audioPlayer.isListeningEpisode(selectedEpisode.episodeId)) {
      audioPlayer.togglePlaybackState();
    } else {
      await audioPlayer.updateEpisodeQueue(data, index: index);
    }
  }

  Future<SearchResult?> GetPodcast() async {
    if (widget.podcastSearchResult != null) {
      return widget.podcastSearchResult!;
    } else if (widget.podcastId != null) {
      return await podcastService.getPodcastDetails(widget.podcastId!, sort, -1);
    } else {
      return null;
    }
  }

  Widget buildMessages(List<ChatMessageDto> data) => ListView.builder(
      shrinkWrap: true,
      itemCount: data.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        final item = data[index];
        return buildMessage(context, item);
      });
  Widget buildMessage(context, ChatMessageDto entry) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 7.5, 20, 7.5),
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromRGBO(29, 40, 58, 0.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(
                        entry.senderName.toString(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(entry.messageType.toString(), style: const TextStyle(color: Color.fromRGBO(99, 163, 253, 1))),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 25),
                    child: Align(alignment: Alignment.centerLeft, child: Text(entry.content.toString())),
                  ),
                ],
              ),
            )),
      );

  Widget buildEpisodes(List<Episode> data) => SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            var episode = data[index];
            var episodeIndex = index;
            return EpisodePreviewWidget(
                episode, Axis.vertical, () => {selectEpisode(episodeIndex, data)}, () => setState(() {}));
          },
          childCount: data.length, // 1000 list items
        ),
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    userService.UpdatePodcastVisitDate(widget.podcastId ?? widget.podcastSearchResult?.id);
    return Scaffold(
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
                return SizedBox(
                    height: size.height,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Center(child: CircularProgressIndicator()),
                          const SizedBox(
                            height: 50,
                          ),
                          InkWell(
                            onTap: (() {
                              Navigator.pop(context);
                            }),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.arrow_back),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Text("Back")
                              ],
                            ),
                          )
                        ]));
              },
              future: getPodcast,
            )));
  }

  Widget createCustomScrollView(SearchResult podcastSearchResult) {
    Future<List<ChatMessageDto>> getMessages(int roomId, int direction) async {
      if (!chatHub.isConnected) {
        await chatHub.connect();
        await chatHub.joinRoom(JoinRoomDto(roomId));
        return await chatHub.getHistory(MessageHistoryRequestDto(roomId: roomId, direction: direction));
      } else {
        chatHub.joinRoom(JoinRoomDto(roomId));
        return await chatHub.getHistory(MessageHistoryRequestDto(roomId: roomId, direction: direction));
      }
    }

    Future<Podcast> getPodcastDetail(int podcastId, String sort, int amount) async {
      // if (chatHub.isConnected & userService.isConnected) {
      //   await chatHub.leaveRoom(JoinRoomDto(podcastId));
      //   print('roomID ${podcastService.podcast!.roomId!}');
      //   print('roomID2 ${podcastSearchResult.roomId!}');
      //   return podcastService.getPodcastDetails(podcastId, sort, amount);
      // } else {
      //   print('roomID ${podcastService.podcast!.roomId!}');
      //   print('roomID2 ${podcastSearchResult.roomId!}');
      //   return podcastService.getPodcastDetails(podcastId, sort, amount);
      // }
      print('roomID ${podcastService.podcast!.roomId!}');
      print('roomID2 ${podcastSearchResult.roomId!}');
      return podcastService.getPodcastDetails(podcastId, sort, amount);
    }

    final size = MediaQuery.of(context).size;
    void initState() {
      super.initState();
      _getMessages = podcastService.podcast!.roomId != null
          ? getMessages(podcastService.podcast!.roomId!, 0)
          : getMessages(podcastSearchResult.roomId!, 0);
    }

    return DefaultTabController(
      animationDuration: Duration.zero,
      length: 3,
      child: ScaffoldWave(
        height: 33,
        appBar: AppBar(
          centerTitle: false,
          leadingWidth: 35,
          titleSpacing: 3,
          backgroundColor: const Color.fromRGBO(29, 40, 58, 1),
          title: Text(
            podcastSearchResult.title!,
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
                            "Check the Podcast ${podcastSearchResult.title} on Talkaboat.online mobile App! Start listening and earn while supporting new and upcoming podcasters.\n\n Download it now on \nAndroid: https://play.google.com/store/apps/details?id=com.aboat.talkaboat\n",
                            subject: "Check this out! A Podcast on Talkaboat.online.")
                      }),
            ),
            !userService.isConnected
                ? const SizedBox()
                : userService.isInFavorites(podcastSearchResult.id!)
                    ? Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: IconButton(
                          icon: const Icon(Icons.favorite, color: Color.fromRGBO(99, 163, 253, 0.5), size: 36),
                          tooltip: '',
                          onPressed: () async {
                            await userService.removeFromFavorites(podcastSearchResult.id!);
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
                            await userService.addToFavorites(podcastSearchResult.id!);
                            setState(() {});
                          },
                        ),
                      ),
          ],
        ),
        body: TabBarView(children: [
          CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                delegate: PodcastDetailSliver(expandedHeight: size.height * 0.4, podcast: podcastSearchResult),
                pinned: true,
              ),
              FutureBuilder(
                builder: (context, snapshot) {
                  _getMessages = podcastService.podcast!.roomId != null
                      ? getMessages(podcastService.podcast!.roomId!, 0)
                      : getMessages(podcastSearchResult.roomId!, 0);
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Text(
                            '${snapshot.error} occurred',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      );
                    } else if (snapshot.hasData && snapshot.data != null) {
                      // Extracting data from snapshot object
                      final data = snapshot.data as List<Episode>?;
                      if (data != null && data.isNotEmpty) {
                        return buildEpisodes(data);
                      }
                    }
                  }
                  return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                },
                future: podcastService.getPodcastDetailEpisodes(podcastSearchResult.id!, sort, -1),
              ),
            ],
          ),
          CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                delegate: PodcastDetailSliver(expandedHeight: size.height * 0.4, podcast: podcastSearchResult),
                pinned: true,
              ),
              SliverToBoxAdapter(
                  child: FutureBuilder(
                future: getPodcastDetail(podcastSearchResult.id!, sort, -1),
                // future: podcastService.getPodcastDetails(podcastSearchResult.id!, sort, -1),
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
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              height: 40,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Allgemeines",
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: const Color.fromRGBO(99, 163, 253, 1),
                                    ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                const Text(
                                  "Titel",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Text(
                                    snapshot.data!.title!,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                )
                              ]),
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Folgen",
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(snapshot.data!.totalEpisodes!.toString())
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              alignment: Alignment.centerLeft,
                              child: const Text(
                                "Author",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(20, 0, 0, 10),
                              alignment: Alignment.topLeft,
                              child: Text(
                                snapshot.data!.publisher!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: const Color.fromRGBO(99, 163, 253, 0.5),
                                    ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              margin: const EdgeInsets.only(bottom: 7),
                              child: const Text(
                                "Kategorien",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                  margin: const EdgeInsets.only(bottom: 35),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10), color: const Color.fromRGBO(188, 140, 75, 1)),
                                  width: 100,
                                  height: 35,
                                  child: Center(
                                      child: Text(
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          snapshot.data!.genreIds!,
                                          style: const TextStyle(color: Color.fromRGBO(15, 23, 41, 1))))),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                "Beschreibung",
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: const Color.fromRGBO(99, 163, 253, 1),
                                    ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                snapshot.data!.description!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: const Color.fromRGBO(99, 163, 253, 1)),
                              ),
                            )
                          ],
                        ),
                      );
                    } else {
                      return const Center(
                        child: Text(
                          'No data found for this podcast. Please try again later!',
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    }
                  }
                  return const SizedBox();
                },
              ))
            ],
          ),
          CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                delegate: PodcastDetailSliver(expandedHeight: size.height * 0.4, podcast: podcastSearchResult),
                pinned: true,
              ),
              SliverToBoxAdapter(
                child: userService.isConnected
                    // & chatHub.isConnected
                    ? FutureBuilder(
                        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            if (snapshot.hasError) {
                              return SliverToBoxAdapter(
                                child: Center(
                                  child: Text(
                                    '${snapshot.error} occurred',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                              );
                            } else if (snapshot.hasData && snapshot.data != null) {
                              // Extracting data from snapshot object
                              final data = snapshot.data as List<ChatMessageDto>?;
                              if (data != null && data.isNotEmpty) {
                                // return Text(data[1].content.toString());
                                return Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    buildMessages(data),
                                    Container(
                                      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                      margin: EdgeInsets.symmetric(horizontal: 20),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Color.fromRGBO(15, 23, 41, 1),
                                        border: Border.all(
                                            color: const Color.fromRGBO(99, 163, 253, 1), // set border color
                                            width: 1.0),
                                      ),
                                      child: TextField(
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: const Color.fromRGBO(164, 202, 255, 1),
                                            ),
                                        keyboardType: TextInputType.text,
                                        maxLines: null,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          alignLabelWithHint: true,
                                          hintText: "Message",
                                          suffixIcon: const Icon(Icons.send, color: Color.fromRGBO(99, 163, 253, 1)),
                                          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: const Color.fromRGBO(135, 135, 135, 1), fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                            }
                          }

                          return Column(
                            children: [
                              Container(
                                padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color.fromRGBO(15, 23, 41, 1),
                                  border: Border.all(
                                      color: const Color.fromRGBO(99, 163, 253, 1), // set border color
                                      width: 1.0),
                                ),
                                child: TextField(
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: const Color.fromRGBO(164, 202, 255, 1),
                                      ),
                                  keyboardType: TextInputType.text,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    alignLabelWithHint: true,
                                    hintText: "Message",
                                    suffixIcon: const Icon(Icons.send, color: Color.fromRGBO(99, 163, 253, 1)),
                                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: const Color.fromRGBO(135, 135, 135, 1), fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ),
                              chatHub.isConnected ? Text("User autorised") : SizedBox(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                      width: 100,
                                      height: 30,
                                      color: Colors.blue,
                                      child: RawMaterialButton(
                                          child: const Text("Connect"),
                                          onPressed: () async {
                                            await chatHub.connect();
                                            // await chatHub.joinRoom(JoinRoomDto(648));
                                          })),
                                  Container(
                                      width: 100,
                                      height: 30,
                                      color: Colors.blue,
                                      child: RawMaterialButton(
                                          child: podcastService.podcast!.roomId != null
                                              ? Text("Join the room ${podcastService.podcast!.roomId}")
                                              : Text("Join the room ${podcastSearchResult.roomId!}"),
                                          onPressed: () async {
                                            // await chatHub.connect();
                                            podcastService.podcast!.roomId != null
                                                ? await chatHub.joinRoom(JoinRoomDto(podcastService.podcast!.roomId!))
                                                : await chatHub.joinRoom(JoinRoomDto(podcastSearchResult.roomId!));
                                          })),
                                  Container(
                                      width: 100,
                                      height: 30,
                                      color: Colors.blue,
                                      child: RawMaterialButton(
                                          child: const Text("leave Room"),
                                          onPressed: () async {
                                            podcastService.podcast!.roomId != null
                                                ? await chatHub.leaveRoom(JoinRoomDto(podcastService.podcast!.roomId!))
                                                : await chatHub.leaveRoom(JoinRoomDto(podcastSearchResult.roomId!));
                                          })),
                                ],
                              ),
                            ],
                          );
                          // return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                        },
                        future: _getMessages
                        // future: chatHub.getHistory(MessageHistoryRequestDto(roomId: podcastSearchResult.roomId!, direction: 0)),
                        )
                    : const LoginButton(),
              )
            ],
          ),
        ]),
      ),
    );
  }
}
