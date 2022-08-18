import 'package:Talkaboat/services/downloading/file-downloader.service.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
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
            value: 'add', child: Card(child: Text('Add to playlist'))),
    PopupMenuItem<String>(
        value: 'download', child: Card(child: Text(FileDownloadService.containsFile(entry.audio!) ? 'Delete' : 'Download'))),
      ];

  buildPopupButton(context, Episode entry) => PopupMenuButton(
        child: Icon(Icons.more_vert, color: Theme.of(context).iconTheme.color),
        onSelected: (value) async {
          switch (value) {
            case 'download':
              await FileDownloadService.cacheOrDelete(entry.audio!);
              setState(() { });
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
          child: Card(
            elevation: 8.0,
            color: Theme.of(context).cardTheme.color,
            margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            child: Container(
              child: widget.direction == Axis.horizontal
                  ? makeHorizontalListTile(context, entry, playing)
                  : makeVerticalListTile(context, entry, playing),
            ),
          ),
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
                                          imageUrl:  entry.image ?? 'https://picsum.photos/200',
                                          cacheManager: CacheManager(
                                            Config(
                                              entry.image ?? 'https://picsum.photos/200',
                                              stalePeriod: const Duration(days: 2))),
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
    final remaining =
        Duration(seconds: (entry.audioLengthSec! - entry.playTime!).toInt());
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      leading: SizedBox(
        width: 60,
        height: 60,
        child: Stack(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                    child: CachedNetworkImage(
                  imageUrl: entry.image ?? 'https://picsum.photos/200',
                      cacheManager: CacheManager(
                          Config(
                              entry.image ?? 'https://picsum.photos/200',
                              stalePeriod: const Duration(days: 2))),
                  fit: BoxFit.fill,
                  placeholder: (_, __) =>
                      const Center(child: CircularProgressIndicator()),
                  // progressIndicatorBuilder: (context, url, downloadProgress) =>
                  //     CircularProgressIndicator(value: downloadProgress.progress),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ))),
            Positioned.fill(
                child: Center(
                    child: Card(
                        color: Theme.of(context).dialogTheme.backgroundColor,
                        child: Icon(
                            audioHandler.isListeningEpisode(
                                        widget.episode.id) &&
                                    playing
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 30)))),
          ],
        ),
      ),
      title: Text(
        entry.title!,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            removeAllHtmlTags(entry.description!),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: const TextStyle(color: Colors.white),
          ),
          Row(
            children: [
              IconButton(onPressed: (() async {
                await FileDownloadService.cacheOrDelete(entry.audio!);
                setState(() { });
              }), icon: Icon(FileDownloadService.containsFile(entry.audio!) ? Icons.cloud_done : Icons.cloud_download_outlined), color: FileDownloadService.containsFile(entry.audio!) ? Colors.green : Colors.white),
              SizedBox(width: 10,),
              SizedBox(
                width: 55,
                child: Text(
                  (entry.playTime ?? 0) + 20 >= (entry.audioLengthSec ?? 0)
                      ? "Listened"
                      : formatTime(remaining.inSeconds),
                ),
              ),
              AbsorbPointer(
                  child: SizedBox(
                height: 25,
                width: 110,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                      thumbColor: Colors.transparent,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 0.0)),
                  child: Slider(
                      value: (entry.playTime?.toDouble() ?? 0),
                      onChanged: (double value) {},
                      min: 0,
                      max: entry.audioLengthSec?.toDouble() ?? 0),
                ),
              )),
            ],
          )
        ],
      ),
      trailing: buildPopupButton(context, entry),
      onTap: () async {
        widget.onPlayEpisode();
        // await audioHandler
        //     .updateEpisodeQueue(List.generate(1, (index) => entry));
      },
    );
  }

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  @override
  Widget build(BuildContext context) {
    return widget.episode == null
        ? SizedBox() :
    FutureBuilder(
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
          return const Center(
              child: CircularProgressIndicator());
        }
      },
      future: FileDownloadService.getFile(widget.episode.audio!),
    );
  }
}
