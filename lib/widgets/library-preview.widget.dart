import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../models/podcasts/podcast.model.dart';
import '../screens/podcast-detail.screen.dart';

class LibraryPreviewWidget extends StatelessWidget {
  const LibraryPreviewWidget(this.escapeWithNav, {Key? key, required this.podcast}) : super(key: key);
  final Podcast podcast;
  final Function escapeWithNav;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 80,
        width: MediaQuery.of(context).size.width * 0.5 - 16,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Card(
              child: InkWell(
                onTap: (() {
                  Navigator.push(
                      context,
                      PageTransition(
                          alignment: Alignment.bottomCenter,
                          curve: Curves.bounceOut,
                          type: PageTransitionType.rightToLeftWithFade,
                          duration: const Duration(milliseconds: 500),
                          reverseDuration: const Duration(milliseconds: 500),
                          child: PodcastDetailScreen(escapeWithNav, podcastSearchResult: podcast)));
                }),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: podcast.image!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                        // progressIndicatorBuilder: (context, url, downloadProgress) =>
                        //     CircularProgressIndicator(value: downloadProgress.progress),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Text(
                            podcast.title!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: Theme.of(context).textTheme.bodyLarge,
                          )),
                    )
                  ],
                ),
              ),
            )));
  }
}
