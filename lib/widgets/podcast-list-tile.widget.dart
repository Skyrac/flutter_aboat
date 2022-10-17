import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/podcasts/podcast.model.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// TODO: should be possible as stateless?
class PodcastListTileWidget extends StatefulWidget {
  const PodcastListTileWidget(this.podcast, {Key? key}) : super(key: key);
  final Podcast podcast;
  @override
  State<PodcastListTileWidget> createState() => _PodcastListTileWidgetState();
}

class _PodcastListTileWidgetState extends State<PodcastListTileWidget> {
  final userService = getIt<UserService>();

  popupMenu(BuildContext context, Podcast entry) {
    if (!userService.isConnected) {
      return [];
    }
    return [
      userService.isInFavorites(entry.id!)
          ? PopupMenuItem<String>(
              value: 'add_to_avorites',
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(29, 40, 58, 0.97),
                    border: Border.all(color: const Color.fromRGBO(188, 140, 75, 0.25)),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.favorite,
                      size: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text('Add to favorites'),
                    ),
                  ],
                ),
              ),
            )
          : PopupMenuItem<String>(
              value: 'remove_to_avorites',
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(29, 40, 58, 0.97),
                    border: Border.all(color: const Color.fromRGBO(188, 140, 75, 0.25)),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.favorite,
                      size: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text('Remove from favorites'),
                    ),
                  ],
                ),
              ),
            ),
    ];
  }

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
                child: PopupMenuButton(
                    itemBuilder: (BuildContext context) {
                      return popupMenu(context, widget.podcast);
                    },
                    onSelected: (value) async {
                      switch (value) {
                        case "add_to_avorites":
                          await userService.addToFavorites(widget.podcast.id!);
                          break;
                        case "remove_to_avorites":
                          await userService.removeFromFavorites(widget.podcast.id!);
                          break;
                      }
                    },
                    color: const Color.fromRGBO(15, 23, 41, 1.0),
                    offset: const Offset(-40.0, 0.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(child: Icon(Icons.more_vert)))),
          ]),
        ),
      ),
    );
  }
}
