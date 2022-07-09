import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/search/search_result.model.dart';
import '../themes/colors.dart';
import 'bottom-sheets/claim.bottom-sheet.dart';

class PodcastDetailSliver extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final SearchResult podcast;

  const PodcastDetailSliver(
      {required this.expandedHeight, required this.podcast});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    const size = 200;
    final top = expandedHeight / 1.1 - shrinkOffset / 3 - size;
    return Stack(
      fit: StackFit.expand,
      children: [
        buildBackground(shrinkOffset, context),
        buildAppBar(shrinkOffset),
        Positioned(
          top: top,
          left: 20,
          right: 20,
          child: buildFloating(shrinkOffset, context),
        ),
      ],
    );
  }

  double appear(double shrinkOffset) => shrinkOffset / expandedHeight;

  double disappear(double shrinkOffset) => 1 - shrinkOffset / expandedHeight;

  Widget buildAppBar(double shrinkOffset) => AppBar(
        title: Text(podcast.title!),
        backgroundColor: DefaultColors.secondaryColorAlphaBlend.shade900,
        centerTitle: true,
      );

  Widget buildBackground(double shrinkOffset, context) => Opacity(
      opacity: disappear(shrinkOffset),
      child: Stack(
        children: <Widget>[
          Container(
              padding: const EdgeInsets.only(left: 10.0),
              height: expandedHeight,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(podcast.image!),
                  fit: BoxFit.cover,
                ),
              )),
          Container(
            height: expandedHeight,
            padding: const EdgeInsets.all(40.0),
            child: Center(
              child: Text(
                "",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
        ],
      ));

  Widget buildFloating(double shrinkOffset, BuildContext context) => Opacity(
        opacity: disappear(shrinkOffset),
        child: SizedBox(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 240,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(200),
                    child: Card(
                        child: buildButton(
                            text: 'Donate',
                            icon: Icons.money,
                            onClick: () => {}))),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Expanded(
                      child: buildButton(
                          text: 'Share', icon: Icons.share, onClick: () => {
                            //TODO: Geräte Abhängigkeit prüfen
                            Share.share("Check the Podcast ${podcast.title} on Talkaboat.online mobile App! Start listening and earn while supporting new and upcoming podcasters.\n\n Download it now on \nAndroid: https://play.google.com/store/apps/details?id=com.aboat.talkaboat\n", subject: "Check this out! A Podcast on Talkaboat.online.")
                      })),
                  Expanded(
                      child: buildButton(
                          text: 'Claim',
                          icon: Icons.rv_hookup,
                          onClick: () => {
                                showModalBottomSheet(
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20))),
                                    context: context,
                                    builder: (context) =>
                                        ClaimBottomSheet(podcastId: podcast.id!))
                              })),
                ],
              ),
            ],
          ),
        ),
      );

  Widget buildButton(
          {required String text,
          required IconData icon,
          required Function onClick}) =>
      TextButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Text(text, style: TextStyle(fontSize: 20)),
          ],
        ),
        onPressed: () {
          onClick();
        },
      );

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight + 30;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
