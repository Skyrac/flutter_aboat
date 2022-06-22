import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:talkaboat/models/podcasts/episode.model.dart';
import 'package:talkaboat/screens/login.screen.dart';
import 'package:talkaboat/services/audio/audio-handler.services.dart';
import 'package:talkaboat/services/user/user.service.dart';

import '../injection/injector.dart';
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
      ];

  buildPopupButton(context, Episode entry) => PopupMenuButton(
        child: Icon(Icons.more_vert, color: Theme.of(context).iconTheme.color),
        onSelected: (value) async {
          switch (value) {
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

  Widget makeCard(context, Episode entry) => Card(
        elevation: 8.0,
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration:
                const BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
            child: widget.direction == Axis.horizontal
                ? makeHorizontalListTile(context, entry)
                : makeVerticalListTile(context, entry),
          ),
        ),
      );

  Widget makeHorizontalListTile(context, Episode entry) => Padding(
      padding: const EdgeInsets.all(10),
      child: InkWell(
          onTap: () async {
            widget.onPlayEpisode();
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
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                            height: 120,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: entry.image!,
                                  fit: BoxFit.fill,
                                  placeholder: (_, __) => const Center(
                                      child: CircularProgressIndicator()),
                                  // progressIndicatorBuilder: (context, url, downloadProgress) =>
                                  //     CircularProgressIndicator(value: downloadProgress.progress),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ],
                            ))),
                    Padding(
                        padding:
                            const EdgeInsets.only(left: 5, right: 5, top: 5),
                        child: Text(entry.title!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: Theme.of(context).textTheme.titleMedium))
                  ],
                ),
              ))));

  Widget makeVerticalListTile(context, Episode entry) => ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        leading: SizedBox(
          width: 60,
          height: 100,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                  child: CachedNetworkImage(
                imageUrl: entry.image == null ? '' : entry.image!,
                fit: BoxFit.fill,
                placeholder: (_, __) =>
                    const Center(child: CircularProgressIndicator()),
                // progressIndicatorBuilder: (context, url, downloadProgress) =>
                //     CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ))),
        ),
        title: Text(
          entry.title!,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          removeAllHtmlTags(entry.description!),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
        ),
        trailing: buildPopupButton(context, entry),
        onTap: () async {
          widget.onPlayEpisode();
          // await audioHandler
          //     .updateEpisodeQueue(List.generate(1, (index) => entry));
        },
      );

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  @override
  Widget build(BuildContext context) {
    return widget.episode == null
        ? SizedBox()
        : makeCard(context, widget.episode);
  }
}
