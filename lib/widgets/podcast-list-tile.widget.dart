import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/podcasts/podcast.model.dart';
import 'package:Talkaboat/screens/podcast-detail.screen.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/utils/common.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PodcastListTileWidget extends StatefulWidget {
  const PodcastListTileWidget(this.podcast, {this.stateChangeCb, Key? key}) : super(key: key);
  final Podcast podcast;
  final void Function()? stateChangeCb;
  @override
  State<PodcastListTileWidget> createState() => _PodcastListTileWidgetState();
}

class _PodcastListTileWidgetState extends State<PodcastListTileWidget> {
  final userService = getIt<UserService>();

  popupMenu(BuildContext context, Podcast entry) {
    if (!userService.isConnected) {
      return <PopupMenuItem<String>>[];
    }
    return [
      !userService.isInFavorites(entry.id!)
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
                  children: [
                    const Icon(
                      Icons.favorite,
                      size: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(AppLocalizations.of(context)!.addToFavorites),
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
                  children: [
                    const Icon(
                      Icons.favorite,
                      size: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(AppLocalizations.of(context)!.removeFromFavorites),
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
            Navigator.of(context).push(PageTransition(
                alignment: Alignment.bottomCenter,
                curve: Curves.bounceOut,
                type: PageTransitionType.rightToLeftWithFade,
                duration: const Duration(milliseconds: 500),
                reverseDuration: const Duration(milliseconds: 500),
                child: PodcastDetailScreen(podcastSearchResult: widget.podcast)));
          },
          child: Row(children: [
            SizedBox(
              height: 90,
              width: 90,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  child: CachedNetworkImage(
                    imageUrl: widget.podcast.image ?? '',
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
                    removeAllHtmlTags(widget.podcast.description!),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Spacer(),
                  Row(children: [
                    Text(
                      AppLocalizations.of(context)!.episodesParam(widget.podcast.totalEpisodes!),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    // TODO: use rank
                    ...(widget.podcast.totalEpisodes! < 5
                        ? [
                            Text(" - ",
                                maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall),
                            const Image(
                              image: AssetImage("assets/icons/icon_fire.png"),
                            ),
                            Text(" ${AppLocalizations.of(context)!.reward} x1.5",
                                maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall),
                          ]
                        : [])
                  ]),
                ]),
              ),
            ),
            !userService.isConnected
                ? const SizedBox()
                : SizedBox(
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
                              if (widget.stateChangeCb != null) {
                                widget.stateChangeCb!();
                              }
                              break;
                            case "remove_to_avorites":
                              await userService.removeFromFavorites(widget.podcast.id!);
                              if (widget.stateChangeCb != null) {
                                widget.stateChangeCb!();
                              }
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
