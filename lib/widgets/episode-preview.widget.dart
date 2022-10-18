import 'package:Talkaboat/services/downloading/file-downloader.service.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

import '../injection/injector.dart';
import '../models/podcasts/episode.model.dart';
import '../screens/login.screen.dart';
import '../services/audio/audio-handler.services.dart';
import '../services/user/user.service.dart';
import '../utils/common.dart';
import 'bottom-sheets/playlist.bottom-sheet.dart';

class EpisodePreviewWidget extends StatefulWidget {
  EpisodePreviewWidget(this.episode, this.direction, this.onPlayEpisode,
      {Key? key})
      : super(key: key);
  Episode episode;
  Axis direction;
  Function onPlayEpisode;

  @override
  State<EpisodePreviewWidget> createState() => _EpisodePreviewWidgetState();
}

class _EpisodePreviewWidgetState extends State<EpisodePreviewWidget> {
  late final audioHandler = getIt<AudioPlayerHandler>();
  final playlistSearchController = TextEditingController();
  final userService = getIt<UserService>();
  popupMenu(BuildContext context, Episode entry) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
            value: 'add',
            child: Container(
                width: 176,
                height: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color.fromRGBO(29, 40, 58, 0.97),
                    border: Border.all(
                        color: const Color.fromRGBO(188, 140, 75, 0.25))),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Image.asset(
                      "assets/images/list _add.png",
                      width: 22,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text('Add to playlist',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                color: const Color.fromRGBO(99, 163, 253, 1))),
                  ],
                ))),
        PopupMenuItem<String>(
            value: 'download',
            child: Container(
                width: 176,
                height: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color.fromRGBO(29, 40, 58, 0.97),
                    border: Border.all(
                        color: const Color.fromRGBO(188, 140, 75, 0.25))),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Image.asset(
                      "assets/images/cloud.png",
                      width: 22,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                        FileDownloadService.containsFile(entry.audio!)
                            ? 'Delete'
                            : 'Download',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                color: const Color.fromRGBO(99, 163, 253, 1))),
                  ],
                ))),
      ];

  buildPopupButton(context, Episode entry) => PopupMenuButton(
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Color.fromRGBO(188, 140, 75, 1)),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        constraints: const BoxConstraints.expand(width: 196, height: 110),
        color: const Color.fromRGBO(15, 23, 41, 1),
        child: Image.asset(
          "assets/images/options.png",
          width: 6,
        ),
        onSelected: (value) async {
          switch (value) {
            case 'download':
              await FileDownloadService.cacheOrDelete(entry.audio!);
              setState(() {});
              break;
            case "add":
              if (!userService.isConnected) {
                Navigator.push(
                    context,
                    PageTransition(
                        alignment: Alignment.bottomCenter,
                        curve: Curves.bounceOut,
                        type: PageTransitionType.rightToLeftWithFade,
                        duration: const Duration(milliseconds: 500),
                        reverseDuration: const Duration(milliseconds: 500),
                        child: LoginScreen(() => setState(() {}))));
              } else {
                showModalBottomSheet(
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20))),
                    context: context,
                    builder: (context) =>
                        PlaylistBottomSheet(episodeToAdd: entry));
              }
              break;
          }
          setState(() {});
        },
        itemBuilder: (BuildContext context) {
          return popupMenu(context, entry);
        },
      );

  Widget makeCard(context, Episode entry) => StreamBuilder<PlaybackState>(
      stream: audioHandler.playbackState,
      builder: (context, snapshot) {
        final playbackState = snapshot.data;
        final processingState = playbackState?.processingState;
        final playing = playbackState?.playing ?? false;
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            child: widget.direction == Axis.horizontal
                ? makeHorizontalListTile(context, entry, playing)
                : makeVerticalListTile(context, entry, playing),
          ),
          // child: Card(
          //   elevation: 8.0,
          //   color: Theme.of(context).cardTheme.color,
          //   color: Theme.of(context).cardTheme.color,
          //   margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
          //   child: Container(
          //     child: widget.direction == Axis.horizontal
          //         ? makeHorizontalListTile(context, entry, playing)
          //         : makeVerticalListTile(context, entry, playing),
          //   ),
          // ),
        );
      });

  Widget makeHorizontalListTile(context, Episode entry, bool playing) =>
      Padding(
          padding: const EdgeInsets.all(10),
          child: InkWell(
              onTap: () async {
                await widget.onPlayEpisode();
                setState(() {});
                // await audioHandler
                //     .updateEpisodeQueue(List.generate(1, (index) => entry));
              },
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 120,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                    height: 120,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: entry.image ??
                                              'https://picsum.photos/200',
                                          cacheManager: CacheManager(Config(
                                              entry.image ??
                                                  'https://picsum.photos/200',
                                              stalePeriod:
                                                  const Duration(days: 2))),
                                          fit: BoxFit.fill,
                                          placeholder: (_, __) => const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                          // progressIndicatorBuilder: (context, url, downloadProgress) =>
                                          //     CircularProgressIndicator(value: downloadProgress.progress),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        ),
                                      ],
                                    )))
                          ],
                        ),
                        Padding(
                            padding: const EdgeInsets.only(
                                left: 5, right: 5, top: 5),
                            child: Text(entry.title!,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: Theme.of(context).textTheme.titleMedium))
                      ],
                    ),
                  ))));

  Widget makeVerticalListTile(context, Episode entry, bool playing) {
    final dt =
        DateTime.fromMillisecondsSinceEpoch(entry.pubDateMs?.toInt() ?? 0);
    var dateFormatted = DateFormat('dd.MM.yyyy').format(dt);
    final remaining =
        Duration(seconds: (entry.audioLengthSec! - entry.playTime!).toInt());
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      height: 105,
      width: MediaQuery.of(context).size.width,
      child: RawMaterialButton(
        onPressed: () async {
          widget.onPlayEpisode();
        },
        child: Container(
          // height: 105,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: audioHandler.isListeningEpisode(widget.episode.id) && playing
                ? const Color.fromRGBO(188, 140, 75, 0.2)
                : Colors.transparent,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                child: Center(
                  child: Stack(
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                              child: CachedNetworkImage(
                            imageUrl:
                                entry.image ?? 'https://picsum.photos/200',
                            cacheManager: CacheManager(Config(
                                entry.image ?? 'https://picsum.photos/200',
                                stalePeriod: const Duration(days: 2))),
                            fit: BoxFit.fill,
                            placeholder: (_, __) => const Center(
                                child: CircularProgressIndicator()),
                            // progressIndicatorBuilder: (context, url, downloadProgress) =>
                            //     CircularProgressIndicator(value: downloadProgress.progress),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ))),
                      Positioned.fill(
                          child: Center(
                              child: audioHandler.isListeningEpisode(
                                          widget.episode.id) &&
                                      playing
                                  ? Image.asset(
                                      "assets/images/pause.png",
                                      width: 25,
                                    )
                                  : Image.asset("assets/images/play.png",
                                      width: 25))),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                height: 105,
                width: 220,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        entry.title!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12),
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(removeAllHtmlTags(entry.description!),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            audioHandler.isListeningEpisode(
                                        widget.episode.id) &&
                                    playing
                                ? Row(
                                    children: [
                                      Image.asset(
                                          "assets/images/play_small.png"),
                                      const SizedBox(
                                        width: 3,
                                      ),
                                      const Text('Playing',
                                          style: TextStyle(fontSize: 10)),
                                    ],
                                  )
                                : const SizedBox(),
                            Container(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(dateFormatted.toString(),
                                  style: const TextStyle(fontSize: 10)),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text.rich(TextSpan(children: [
                              TextSpan(
                                  text: remaining.inHours != 0
                                      ? '${remaining.inHours % 60}st '
                                      : "",
                                  style: const TextStyle(fontSize: 10)),
                              TextSpan(
                                  text: remaining.inMinutes != 0
                                      ? '${remaining.inMinutes % 60}min '
                                      : "",
                                  style: const TextStyle(fontSize: 10)),
                              TextSpan(
                                text: '${remaining.inSeconds % 60}sec',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ])),
                          ],
                        ),
                        RawMaterialButton(
                          elevation: 0.0,
                          focusElevation: 0.0,
                          hoverElevation: 0.0,
                          highlightElevation: 0,
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(
                              minWidth: 0.0, minHeight: 0.0),
                          padding: const EdgeInsets.all(0),
                          onPressed: (() async {
                            await FileDownloadService.cacheOrDelete(
                                entry.audio!);
                            setState(() {});
                          }),
                          child: FileDownloadService.containsFile(entry.audio!)
                              ? Image.asset(
                                  "assets/images/cloud_complete.png",
                                  width: 25,
                                )
                              : Image.asset(
                                  "assets/images/cloud.png",
                                  width: 25,
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              buildPopupButton(context, entry),
            ],
          ),
        ),
      ),
    );
  }

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  @override
  Widget build(BuildContext context) {
    return widget.episode == null
        ? const SizedBox()
        : FutureBuilder(
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      '${snapshot.error} occurred',
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                } else {
                  return makeCard(context, widget.episode);
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
            future: FileDownloadService.getFile(widget.episode.audio!),
          );
  }
}
