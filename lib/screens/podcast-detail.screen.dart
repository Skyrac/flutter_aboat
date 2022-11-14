import 'dart:async';
import 'dart:convert';

import 'package:Talkaboat/models/chat/create-message-dto.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/widgets/login-button.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:swipe_to/swipe_to.dart';

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
  final ChatHubService chatHub = getIt<ChatHubService>();
  List<String> messageType = ["", "Podcast", "Episode"];
  List<ChatMessageDto> messages = [];
  Future<SearchResult?>? getPodcast;
  Future<List<ChatMessageDto>>? _getMessages;
  final focusNode = FocusNode();

  final textController = TextEditingController();
  String? message;

  var sort = "asc";
  var isDescOpen = false;
  var userService = getIt<UserService>();

  @override
  initState() {
    getPodcast = GetPodcast();
    _getMessages = getMessages();
    super.initState();
  }

  selectEpisode(int index, List<Episode> data) async {
    var selectedEpisode = data[index];
    if (audioPlayer.isListeningEpisode(selectedEpisode.episodeId)) {
      audioPlayer.togglePlaybackState();
    } else {
      await audioPlayer.updateEpisodeQueue(data, index: index);
    }
  }

  selectMessage(int index, List<ChatMemberDto> data) {
    var selectedMessage = data[index];
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

  Widget buildMessages(List<ChatMessageDto> data) => StreamBuilder(
      stream: chatHub.onReceiveMessage,
      initialData: data,
      builder: (context, snapshot) {
        final data2 = snapshot.data as List<ChatMessageDto>;
        return ListView.builder(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            itemCount: data2.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              final item = data2[index];
              var messageIndex = index;
              return buildMessage(context, item);
            });
      });

  void _handleSwipeReply({required bool isLeftSwipe, required String reply}) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          reply,
          textAlign: TextAlign.center,
        ),
        backgroundColor: isLeftSwipe ? Colors.red.shade600 : Colors.green.shade600,
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }

  void _displayInputBottomSheet(bool isLeftSwipe) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: 16.0,
            ),
            child: TextField(
              autofocus: true,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              onSubmitted: (value) => _handleSwipeReply(isLeftSwipe: isLeftSwipe ? true : false, reply: value),
              decoration: const InputDecoration(
                labelText: 'Reply',
                hintText: 'enter reply here',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      5.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildMessage(context, ChatMessageDto entry) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 7.5, 20, 7.5),
        child: SwipeTo(
          onLeftSwipe: () {
            print("swipe");
            // _displayInputBottomSheet(true);
            focusNode.requestFocus();
          },
          child: RawMaterialButton(
            onLongPress: () {},
            onPressed: () {},
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromRGBO(29, 40, 58, 0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: RawMaterialButton(
                    onPressed: () {
                      print(entry.id);
                    },
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text(
                              entry.senderName.toString(),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(messageType[entry.messageType],
                                style: const TextStyle(color: Color.fromRGBO(99, 163, 253, 1))),
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 25),
                          child: Align(alignment: Alignment.centerLeft, child: Text(entry.content.toString())),
                        ),
                      ],
                    ),
                  ),
                )),
          ),
        ),
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

  Future<List<ChatMessageDto>> getMessages() async {
    var podcast = await podcastService.getPodcastDetails(widget.podcastSearchResult!.id!, sort, -1);
    if (!chatHub.isConnected) {
      await chatHub.connect();
      return await chatHub.getHistory(MessageHistoryRequestDto(roomId: podcast.roomId!, direction: 0));
    } else {
      return await chatHub.getHistory(MessageHistoryRequestDto(roomId: podcast.roomId!, direction: 0));
    }
  }

  // Stream<List<ChatMessageDto>> getMessages() async* {
  //   var podcast = await podcastService.getPodcastDetails(widget.podcastSearchResult!.id!, sort, -1);
  //   if (!chatHub.isConnected) {
  //     await chatHub.connect();
  //     yield await chatHub.getHistory(MessageHistoryRequestDto(roomId: podcast.roomId!, direction: 0));
  //   } else {
  //     yield await chatHub.getHistory(MessageHistoryRequestDto(roomId: podcast.roomId!, direction: 0));
  //   }
  // }

  Widget createCustomScrollView(SearchResult podcastSearchResult) {
    Future<Podcast> getPodcastDetail(int podcastId, String sort, int amount) async {
      if (chatHub.isConnected) {
        return podcastService.getPodcastDetails(podcastId, sort, amount);
      } else {
        await chatHub.connect();
        return podcastService.getPodcastDetails(podcastId, sort, amount);
      }
    }

    final size = MediaQuery.of(context).size;

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
                future: podcastService.getPodcastDetails(podcastSearchResult.id!, sort, -1),
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
                                const SizedBox(
                                  width: 30,
                                  child: Text(
                                    "Titel",
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                SizedBox(
                                  width: 250,
                                  child: Text(
                                    snapshot.data!.title!,
                                    textAlign: TextAlign.end,
                                  ),
                                ),
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
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    delegate: PodcastDetailSliver(expandedHeight: size.height * 0.4, podcast: podcastSearchResult),
                    pinned: true,
                  ),
                  //userService.isConnected
                  // & chatHub.isConnected
                  //?
                  FutureBuilder(
                      // stream: _getMessages,
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
                              return SliverToBoxAdapter(
                                child: Container(
                                  alignment: Alignment.topCenter,
                                  // height: 400,
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      buildMessages(data),
                                      // userService.isConnected
                                      //     ?
                                      //     // MessageInput(message!, textController, podcastSearchResult)
                                      //     Container(
                                      //         padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                      //         margin: EdgeInsets.symmetric(horizontal: 20),
                                      //         decoration: BoxDecoration(
                                      //           borderRadius: BorderRadius.circular(10),
                                      //           color: Color.fromRGBO(15, 23, 41, 1),
                                      //           border: Border.all(
                                      //               color: const Color.fromRGBO(99, 163, 253, 1), // set border color
                                      //               width: 1.0),
                                      //         ),
                                      //         child: TextField(
                                      //           controller: textController,
                                      //           onSubmitted: (content) {
                                      //             message = content;
                                      //             chatHub.sendMessage(
                                      //                 CreateMessageDto(0, podcastSearchResult.roomId!, content, 0, null, null));
                                      //             textController.clear();
                                      //             getMessages();
                                      //             setState(() {
                                      //               getMessages();
                                      //             });
                                      //           },
                                      //           onChanged: (text) {
                                      //             print(text);
                                      //             message = text;
                                      //           },
                                      //           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      //                 color: const Color.fromRGBO(164, 202, 255, 1),
                                      //               ),
                                      //           keyboardType: TextInputType.text,
                                      //           maxLines: null,
                                      //           decoration: InputDecoration(
                                      //             border: InputBorder.none,
                                      //             alignLabelWithHint: true,
                                      //             hintText: "Message",
                                      //             suffixIcon: IconButton(
                                      //               onPressed: () async {
                                      //                 var newMessage =
                                      //                     CreateMessageDto(0, podcastSearchResult.roomId!, message!, 0, 2, null);
                                      //                 await chatHub.sendMessage(newMessage);
                                      //                 // chatHub.onReceiveMessageController.add(newMessage as ChatMessageDto);
                                      //                 // chatHub.receiveNewMessage([newMessage]);
                                      //                 textController.clear();

                                      //                 getMessages();
                                      //                 setState(() {
                                      //                   getMessages();
                                      //                 });
                                      //               },
                                      //               icon: Icon(Icons.send, color: Color.fromRGBO(99, 163, 253, 1)),
                                      //             ),
                                      //             hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      //                 color: const Color.fromRGBO(135, 135, 135, 1),
                                      //                 fontStyle: FontStyle.italic),
                                      //           ),
                                      //         ),
                                      //       )
                                      //     : SizedBox(),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return SliverToBoxAdapter(
                                  child: Container(
                                height: 300,
                                child: Stack(alignment: Alignment.bottomCenter, children: [
                                  Positioned(
                                    top: 0,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.symmetric(horizontal: 20),
                                      child: Text(
                                        'No data found for this podcast. Please try again later!',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                ]),
                              ));
                            }
                          }
                        }

                        return SliverToBoxAdapter(
                            child: Center(
                          child: CircularProgressIndicator(),
                        )
                            // Column(
                            //   children: [
                            //     chatHub.isConnected ? Text("User autorised") : SizedBox(),
                            //     Row(
                            //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                            //       children: [
                            //         Container(
                            //             width: 100,
                            //             height: 30,
                            //             color: Colors.blue,
                            //             child: RawMaterialButton(
                            //                 child: podcastService.podcast != null
                            //                     ? Text("Join the room ${podcastService.podcast!.roomId}")
                            //                     : Text("Join the room ${podcastSearchResult.roomId!}"),
                            //                 onPressed: () async {
                            //                   // await chatHub.connect();
                            //                   podcastService.podcast != null
                            //                       ? await chatHub.joinRoom(JoinRoomDto(podcastService.podcast!.roomId!))
                            //                       : await chatHub.joinRoom(JoinRoomDto(podcastSearchResult.roomId!));
                            //                 })),
                            //         Container(
                            //             width: 100,
                            //             height: 30,
                            //             color: Colors.blue,
                            //             child: RawMaterialButton(
                            //                 child: const Text("leave Room"),
                            //                 onPressed: () async {
                            //                   podcastService.podcast != null
                            //                       ? await chatHub.leaveRoom(JoinRoomDto(podcastService.podcast!.roomId!))
                            //                       : await chatHub.leaveRoom(JoinRoomDto(podcastSearchResult.roomId!));
                            //                 })),
                            //       ],
                            //     ),
                            //   ],
                            // ),
                            );
                      },
                      future: _getMessages)
                  //    : const LoginButton(),
                ],
              ),
              userService.isConnected
                  ? Positioned(
                      bottom: 50,
                      child: Container(
                        width: 350,
                        height: 50,
                        padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color.fromRGBO(15, 23, 41, 1),
                          border: Border.all(
                              color: const Color.fromRGBO(99, 163, 253, 1), // set border color
                              width: 1.0),
                        ),
                        // child: Text("dadasdas"),
                        child: TextField(
                          focusNode: focusNode,
                          controller: textController,
                          onSubmitted: (content) {
                            message = content;
                            chatHub.sendMessage(
                                CreateMessageDto(0, widget.podcastSearchResult!.roomId!, content, 0, null, null));
                            textController.clear();
                          },
                          onChanged: (text) {
                            print(text);
                            message = text;
                          },
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color.fromRGBO(164, 202, 255, 1),
                              ),
                          keyboardType: TextInputType.text,
                          maxLines: null,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            alignLabelWithHint: true,
                            hintText: "Message",
                            suffixIcon: IconButton(
                              onPressed: () async {
                                var newMessage = await chatHub.sendMessage(
                                    CreateMessageDto(0, widget.podcastSearchResult!.roomId!, message!, 0, 2, null));
                                // chatHub.onReceiveMessageController.add(newMessage as ChatMessageDto);
                                // chatHub.receiveNewMessage(newMessage);
                                textController.clear();
                              },
                              icon: Icon(Icons.send, color: Color.fromRGBO(99, 163, 253, 1)),
                            ),
                            hintStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: const Color.fromRGBO(135, 135, 135, 1), fontStyle: FontStyle.italic),
                          ),
                        ),
                      ))
                  : SizedBox()
            ],
          ),
        ]),
      ),
    );
  }

  // Widget MessageInput(String message, TextEditingController textController, SearchResult podcastSearchResult) {
  //   return Container(
  //     padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
  //     margin: EdgeInsets.symmetric(horizontal: 20),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(10),
  //       color: Color.fromRGBO(15, 23, 41, 1),
  //       border: Border.all(
  //           color: const Color.fromRGBO(99, 163, 253, 1), // set border color
  //           width: 1.0),
  //     ),
  //     child: TextField(
  //       controller: textController,
  //       onSubmitted: (content) async {
  //         message = content;
  //         await chatHub.sendMessage(CreateMessageDto(null, podcastSearchResult.roomId!, message, 0, null, null));
  //         textController.clear;
  //       },
  //       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  //             color: const Color.fromRGBO(164, 202, 255, 1),
  //           ),
  //       onChanged: (text) {
  //         print(text);
  //         message = text;
  //       },
  //       keyboardType: TextInputType.text,
  //       maxLines: null,
  //       decoration: InputDecoration(
  //         border: InputBorder.none,
  //         alignLabelWithHint: true,
  //         hintText: "Message",
  //         suffixIcon: IconButton(
  //           onPressed: () async {
  //             await chatHub.sendMessage(CreateMessageDto(null, podcastSearchResult.roomId!, message, 0, null, null));
  //             textController.clear;
  //           },
  //           icon: Icon(Icons.send, color: Color.fromRGBO(99, 163, 253, 1)),
  //         ),
  //         hintStyle: Theme.of(context)
  //             .textTheme
  //             .bodyMedium
  //             ?.copyWith(color: const Color.fromRGBO(135, 135, 135, 1), fontStyle: FontStyle.italic),
  //       ),
  //     ),
  //   );
  // }
}
