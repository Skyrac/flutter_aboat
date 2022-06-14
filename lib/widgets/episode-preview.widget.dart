import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:talkaboat/models/podcasts/episode.model.dart';
import 'package:talkaboat/services/audio/audio-handler.services.dart';
import 'package:talkaboat/themes/colors.dart';

import '../injection/injector.dart';

class EpisodePreviewWidget extends StatelessWidget {
  EpisodePreviewWidget(this.episode, this.direction, this.onPlayEpisode,
      {Key? key})
      : super(key: key);
  Episode episode;
  Axis direction;
  Function onPlayEpisode;
  late final audioHandler = getIt<AudioPlayerHandler>();
  Widget makeCard(context, Episode entry) => Card(
        elevation: 8.0,
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration:
                const BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
            child: direction == Axis.horizontal
                ? makeHorizontalListTile(context, entry)
                : makeVerticalListTile(context, entry),
          ),
        ),
      );

  Widget makeHorizontalListTile(context, Episode entry) => Padding(
      padding: const EdgeInsets.all(10),
      child: InkWell(
          onTap: () async {
            onPlayEpisode();
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
        trailing: const Icon(Icons.keyboard_arrow_right,
            color: Colors.white, size: 30.0),
        onTap: () async {
          onPlayEpisode();
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
    return episode == null ? SizedBox() : makeCard(context, episode);
    Padding(
        padding: const EdgeInsets.all(10),
        child: InkWell(
            onTap: () async {
              await audioHandler
                  .updateEpisodeQueue(List.generate(1, (index) => episode));
            },
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                              height: 200,
                              child: CachedNetworkImage(
                                imageUrl: episode.image!,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => const Center(
                                    child: CircularProgressIndicator()),
                                // progressIndicatorBuilder: (context, url, downloadProgress) =>
                                //     CircularProgressIndicator(value: downloadProgress.progress),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ))),
                      Padding(
                          padding:
                              const EdgeInsets.only(left: 5, right: 5, top: 5),
                          child: Text(episode.title!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                  color: DefaultColors.primaryColor,
                                  fontSize: 24))),
                      // Padding(
                      //     padding: const EdgeInsets.only(left: 5, right: 5),
                      //     child: Text(episode.description!,
                      //
                      //         style: TextStyle(
                      //             color: DefaultColors.primaryColor,
                      //             fontSize: 18)))
                    ],
                  ),
                ))));
  }
}
