import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:talkaboat/models/podcasts/episode.model.dart';

import '../injection/injector.dart';
import '../services/audio/audio-handler.services.dart';

class EpisodeListWidget extends StatefulWidget {
  EpisodeListWidget({Key? key, required this.episodes, required this.direction})
      : super(key: key);
  final List<Episode?> episodes;
  final Axis direction;
  @override
  State<EpisodeListWidget> createState() => _EpisodeListWidgetState();
}

class _EpisodeListWidgetState extends State<EpisodeListWidget> {
  late final audioHandler = getIt<AudioPlayerHandler>();

  popupMenu(BuildContext context, Episode entry) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
            value: 'remove', child: Card(child: Text('Remove from Playlist'))),
      ];

  buildPopupButton(context, Episode entry) => PopupMenuButton(
        child: Card(
            child: Icon(Icons.more_vert,
                color: Theme.of(context).iconTheme.color)),
        onSelected: (value) async {
          switch (value) {
            case "add":
              break;
          }
          setState(() {});
        },
        itemBuilder: (BuildContext context) {
          return popupMenu(context, entry);
        },
      );

  Widget makeListBuilder(context, List<Episode?> data) => ListView.builder(
      itemCount: data.length,
      scrollDirection: widget.direction,
      itemBuilder: (BuildContext context, int index) {
        if (data[index] == null) {
          return const ListTile();
        }
        final item = data[index]!;
        return makeCard(context, item);
      });

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
            await audioHandler
                .updateEpisodeQueue(List.generate(1, (index) => entry));
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

  Widget makeVerticalListTile(context, Episode entry) => Center(
        child: ListTile(
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
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            entry.description!,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: const TextStyle(color: Colors.white),
          ),
          trailing: buildPopupButton(context, entry),
          onTap: () async {
            await audioHandler
                .updateEpisodeQueue(List.generate(1, (index) => entry));
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    return makeListBuilder(context, widget.episodes);
  }
}
