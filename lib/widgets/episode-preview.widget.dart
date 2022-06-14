import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:talkaboat/models/podcasts/episode.model.dart';
import 'package:talkaboat/services/audio/audio-handler.services.dart';
import 'package:talkaboat/themes/colors.dart';

import '../injection/injector.dart';

class EpisodePreviewWidget extends StatelessWidget {
  EpisodePreviewWidget(this.episode, {Key? key}) : super(key: key);
  Episode episode;
  late final audioHandler = getIt<AudioPlayerHandler>();
  @override
  Widget build(BuildContext context) {
    return episode == null
        ? SizedBox()
        : Padding(
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
                              padding: const EdgeInsets.only(
                                  left: 5, right: 5, top: 5),
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
