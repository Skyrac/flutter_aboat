import 'package:Talkaboat/models/podcasts/podcast.model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// TODO: should be possible as stateless
class PodcastListTileWidget extends StatefulWidget {
  const PodcastListTileWidget(this.podcast, {Key? key}) : super(key: key);
  final Podcast podcast;
  @override
  State<PodcastListTileWidget> createState() => _PodcastListTileWidgetState();
}

class _PodcastListTileWidgetState extends State<PodcastListTileWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: SizedBox(
        height: 90,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            print("outer");
          },
          child: Row(children: [
            SizedBox(
              height: 90,
              width: 90,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  child: CachedNetworkImage(
                    imageUrl: widget.podcast.image == null ? '' : widget.podcast.image!,
                    fit: BoxFit.fill,
                    placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                    // progressIndicatorBuilder: (context, url, downloadProgress) =>
                    //     CircularProgressIndicator(value: downloadProgress.progress),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    widget.podcast.title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    widget.podcast.description!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Spacer(),
                  Row(children: [
                    Text(
                      "${widget.podcast.totalEpisodes!} Episodes",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    ...(widget.podcast.totalEpisodes! < 5
                        ? [
                            Text(" - ",
                                maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall),
                            const Image(
                              image: AssetImage("assets/icons/icon_fire.png"),
                            ),
                            Text(" Reward x1.5",
                                maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall),
                          ]
                        : [])
                  ]),
                ]),
              ),
            ),
            SizedBox(
                height: 90,
                width: 40,
                child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: (() {
                      print("inner");
                    }),
                    child: const Center(child: Icon(Icons.more_vert)))),
          ]),
        ),
      ),
    );
  }
}
