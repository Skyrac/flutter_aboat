import 'package:Talkaboat/models/podcasts/podcast.model.dart';
import 'package:Talkaboat/navigator_keys.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../../injection/injector.dart';
import '../../models/search/search_result.model.dart';
import '../../screens/login.screen.dart';
import '../../screens/podcast-detail.screen.dart';
import '../../services/user/user.service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PodcastListFavoritesWidget extends StatefulWidget {
  const PodcastListFavoritesWidget({Key? key, required this.searchResults, this.trailing, this.checkUpdate})
      : super(key: key);
  final List<SearchResult?> searchResults;
  final Function? trailing;
  final bool? checkUpdate;
  @override
  State<PodcastListFavoritesWidget> createState() => _PodcastListFavoritesWidgetState();
}

class _PodcastListFavoritesWidgetState extends State<PodcastListFavoritesWidget> {
  final userService = getIt<UserService>();

  @override
  void dispose() {
    ImageCache _imageCache = PaintingBinding.instance!.imageCache!;

    _imageCache.clear();

    _imageCache.clearLiveImages();
    super.dispose();
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

  Widget makeListBuilder(context, List<SearchResult?> data) => GridView.count(
      crossAxisCount: 2,
      semanticChildCount: data.length,
      childAspectRatio: 175 / 65,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(data.length, (index) {
        if (data[index] == null) {
          return const ListTile();
        } else {
          final item = data[index]!;
          return makeCard(context, item);
        }
      }));

  Widget makeCard(context, SearchResult entry) => Stack(children: [
        makeVerticalListTile(context, entry),
        widget.checkUpdate != null && widget.checkUpdate!
            ? userService.unseenPodcastNotifcationUpdates(entry.id!)
                ? const Positioned(right: 20, top: 10, child: Icon(Icons.notifications_active, size: 20, color: Colors.red))
                : const SizedBox()
            : const SizedBox(),
      ]);

  Widget makeVerticalListTile(context, SearchResult entry) => SizedBox(
      width: 175,
      height: 65,
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        leading: SizedBox(
          width: 60,
          height: 60,
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
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          AppLocalizations.of(context)!.episodesParam(entry.totalEpisodes ?? 0),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        trailing: widget.trailing == null ? null : widget.trailing!(context, entry),
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
      ));

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: (widget.searchResults.length / 2.0).round() * (65 + 10),
        child: makeListBuilder(context, widget.searchResults));
  }
}
