import 'package:Talkaboat/models/podcasts/podcast.model.dart';
import 'package:Talkaboat/navigator_keys.dart';
import 'package:Talkaboat/widgets/podcast-list-tile.widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:page_transition/page_transition.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../injection/injector.dart';
import '../models/search/search_result.model.dart';
import '../screens/login.screen.dart';
import '../screens/podcast-detail.screen.dart';
import '../services/user/user.service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PodcastListWidget extends StatefulWidget {
  const PodcastListWidget(
      {Key? key, required this.searchResults, required this.direction, this.trailing, this.checkUpdate, this.scrollPhysics})
      : super(key: key);
  final List<SearchResult> searchResults;
  final Axis direction;
  final Function? trailing;
  final bool? checkUpdate;
  final ScrollPhysics? scrollPhysics;
  @override
  State<PodcastListWidget> createState() => _PodcastListWidgetState();
}

class _PodcastListWidgetState extends State<PodcastListWidget> {
  final userService = getIt<UserService>();
  final PagingController<int, SearchResult> _pagingController = PagingController(firstPageKey: 0);

  final _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      debugPrint("fetch $pageKey");
      final newItems = widget.searchResults.skip(pageKey).take(_pageSize).toList();
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      debugPrint("$error");
      _pagingController.error = error;
    }
  }

  popupMenu(BuildContext context, SearchResult entry) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'toggleLibrary',
          child: userService.isInFavorites(entry.id!)
              ? Card(child: Text(AppLocalizations.of(context)!.removeFromLibrary))
              : Card(child: Text(AppLocalizations.of(context)!.addToLibrary)),
        ),
      ];

  buildPopupButton(context, entry) => PopupMenuButton(
        child: Card(child: Icon(Icons.more_vert, color: Theme.of(context).iconTheme.color)),
        onSelected: (value) async {
          switch (value) {
            case "toggleLibrary":
              if (!userService.isConnected) {
                NavigatorKeys.navigatorKeyMain.currentState!.push(PageTransition(
                    alignment: Alignment.bottomCenter,
                    curve: Curves.bounceOut,
                    type: PageTransitionType.rightToLeftWithFade,
                    duration: const Duration(milliseconds: 500),
                    reverseDuration: const Duration(milliseconds: 500),
                    child: LoginScreen(true, refreshParent: () => setState(() {}))));
              } else {
                await userService.toggleFavoritesEntry(entry.id);
              }
              break;
          }
        },
        itemBuilder: (BuildContext context) {
          return popupMenu(context, entry);
        },
      );

  Widget makePagedList(context, List<SearchResult> data) => PagedListView<int, SearchResult>(
      pagingController: _pagingController,
      scrollDirection: widget.direction,
      physics: widget.scrollPhysics,
      builderDelegate: PagedChildBuilderDelegate<SearchResult>(itemBuilder: (context, item, index) {
        return widget.direction == Axis.horizontal ? makeHorizontalCard(context, item) : makeVerticalCard(context, item);
      }));

  Widget makeListBuilder(context, List<SearchResult?> data) => ListView.builder(
      itemCount: data.length,
      scrollDirection: widget.direction,
      physics: widget.scrollPhysics,
      itemBuilder: (BuildContext context, int index) {
        if (data[index] == null) {
          return const ListTile();
        }
        final item = data[index]!;
        return widget.direction == Axis.horizontal ? makeHorizontalCard(context, item) : makeVerticalCard(context, item);
      });

  Widget makeHorizontalCard(context, SearchResult entry) => Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(color: const Color.fromRGBO(99, 163, 253, 0.5), child: makeHorizontalListTile(context, entry)),
        ),
        widget.checkUpdate != null && widget.checkUpdate!
            ? userService.unseenPodcastNotifcationUpdates(entry.id!)
                ? const Positioned(right: 20, top: 10, child: Icon(Icons.notifications_active, size: 20, color: Colors.red))
                : const SizedBox()
            : const SizedBox(),
      ]));

  Widget makeVerticalCard(context, SearchResult entry) => Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            child: makeVerticalListTile(context, entry),
          ),
        ),
        widget.checkUpdate != null && widget.checkUpdate!
            ? userService.unseenPodcastNotifcationUpdates(entry.id!)
                ? const Positioned(right: 20, top: 10, child: Icon(Icons.notifications_active, size: 20, color: Colors.red))
                : const SizedBox()
            : const SizedBox(),
      ]));

  Widget makeHorizontalListTile(context, SearchResult entry) => InkWell(
      borderRadius: BorderRadius.circular(10),
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
      child: Padding(
          padding: const EdgeInsets.all(10),
          child: Stack(children: [
            Center(
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
                                  cacheManager: CacheManager(Config(entry.image ?? 'https://picsum.photos/200',
                                      stalePeriod: const Duration(days: 2))),
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
                                  style: Theme.of(context).textTheme.titleMedium)))
                    ],
                  )),
            ),
            /*Positioned(
            right: 0,
            top: 0,
            child: widget.trailing == null ? buildPopupButton(context, entry) : widget.trailing!(context, entry)),*/
          ])));

  Widget makeVerticalListTile(context, SearchResult entry) => PodcastListTileWidget(
        entry as Podcast,
      );

  @override
  Widget build(BuildContext context) {
    return makePagedList(context, widget.searchResults);
  }
}
