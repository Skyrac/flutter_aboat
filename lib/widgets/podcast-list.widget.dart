import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:page_transition/page_transition.dart';

import '../injection/injector.dart';
import '../models/search/search_result.model.dart';
import '../screens/login.screen.dart';
import '../screens/podcast-detail.screen.dart';
import '../services/user/user.service.dart';

class PodcastListWidget extends StatefulWidget {
  const PodcastListWidget({Key? key, required this.searchResults, required this.direction, this.trailing, this.checkUpdate})
      : super(key: key);
  final List<SearchResult?> searchResults;
  final Axis direction;
  final Function? trailing;
  final bool? checkUpdate;
  @override
  State<PodcastListWidget> createState() => _PodcastListWidgetState();
}

class _PodcastListWidgetState extends State<PodcastListWidget> {
  final userService = getIt<UserService>();
  popupMenu(BuildContext context, SearchResult entry) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'toggleLibrary',
          child: userService.isInLibrary(entry.id!)
              ? const Card(child: Text('Remove from Library'))
              : const Card(child: Text('Add to Library')),
        ),
      ];

  buildPopupButton(context, entry) => PopupMenuButton(
        child: Card(child: Icon(Icons.more_vert, color: Theme.of(context).iconTheme.color)),
        onSelected: (value) async {
          switch (value) {
            case "toggleLibrary":
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
                await userService.toggleLibraryEntry(entry.id);
              }
              break;
          }
        },
        itemBuilder: (BuildContext context) {
          return popupMenu(context, entry);
        },
      );

  Widget makeListBuilder(context, List<SearchResult?> data) => ListView.builder(
      itemCount: data.length,
      scrollDirection: widget.direction,
      itemBuilder: (BuildContext context, int index) {
        if (data[index] == null) {
          return const ListTile();
        }
        final item = data[index]!;
        return makeCard(context, item);
      });

  Widget makeCard(context, SearchResult entry) => Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            color: const Color.fromRGBO(99, 163, 253, 0.5),
            child: widget.direction == Axis.horizontal
                ? makeHorizontalListTile(context, entry)
                : makeVerticalListTile(context, entry),
          ),
        ),
        widget.checkUpdate != null && widget.checkUpdate!
            ? userService.unseenPodcastNotifcationUpdates(entry.id!)
                ? const Positioned(right: 20, top: 10, child: Icon(Icons.notifications_active, size: 20, color: Colors.red))
                : const SizedBox()
            : const SizedBox(),
      ]));

  Widget makeHorizontalListTile(context, SearchResult entry) => Padding(
      padding: const EdgeInsets.all(10),
      child: Stack(children: [
        Center(
            child: InkWell(
          onTap: () async {
            await userService.UpdatePodcastVisitDate(entry.id);
            setState(() {});
            Navigator.push(
                context,
                PageTransition(
                    alignment: Alignment.bottomCenter,
                    curve: Curves.bounceOut,
                    type: PageTransitionType.rightToLeftWithFade,
                    duration: const Duration(milliseconds: 500),
                    reverseDuration: const Duration(milliseconds: 500),
                    child: PodcastDetailScreen(podcastSearchResult: entry)));
          },
          child: SizedBox(
              width: 110,
              height: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            height: 90,
                            width: 90,
                            child: CachedNetworkImage(
                              imageUrl: entry.image ?? 'https://picsum.photos/200',
                              fit: BoxFit.cover,
                              cacheManager: CacheManager(
                                  Config(entry.image ?? 'https://picsum.photos/200', stalePeriod: const Duration(days: 2))),
                              placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                              // progressIndicatorBuilder: (context, url, downloadProgress) =>
                              //     CircularProgressIndicator(value: downloadProgress.progress),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                          ))),
                  Center(
                      child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(entry.title!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Theme.of(context).textTheme.titleMedium!.color!))))
                ],
              )),
        )),
        /*Positioned(
            right: 0,
            top: 0,
            child: widget.trailing == null ? buildPopupButton(context, entry) : widget.trailing!(context, entry)),*/
      ]));

  Widget makeVerticalListTile(context, SearchResult entry) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        leading: SizedBox(
          width: 60,
          height: 100,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                  child: CachedNetworkImage(
                imageUrl: entry.image == null ? '' : entry.image!,
                fit: BoxFit.fill,
                placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                // progressIndicatorBuilder: (context, url, downloadProgress) =>
                //     CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ))),
        ),
        title: Text(
          entry.title!,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          entry.description!,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
        ),
        trailing: widget.trailing == null ? const SizedBox() : widget.trailing!(context, entry),
        onTap: () async {
          await userService.UpdatePodcastVisitDate(entry.id);
          setState(() {});
          Navigator.push(
              context,
              PageTransition(
                  alignment: Alignment.bottomCenter,
                  curve: Curves.bounceOut,
                  type: PageTransitionType.rightToLeftWithFade,
                  duration: const Duration(milliseconds: 500),
                  reverseDuration: const Duration(milliseconds: 500),
                  child: PodcastDetailScreen(podcastSearchResult: entry)));
        },
      );

  @override
  Widget build(BuildContext context) {
    return makeListBuilder(context, widget.searchResults);
  }
}
