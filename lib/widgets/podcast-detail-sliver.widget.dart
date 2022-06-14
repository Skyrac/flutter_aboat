import 'package:flutter/material.dart';

import '../models/search/search_result.model.dart';
import '../themes/colors.dart';

class PodcastDetailSliver extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final SearchResult podcast;

  const PodcastDetailSliver(
      {required this.expandedHeight, required this.podcast});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    const size = 60;
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
          child: buildFloating(shrinkOffset),
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

  Widget buildFloating(double shrinkOffset) => Opacity(
        opacity: disappear(shrinkOffset),
        child: Card(
          child: Row(
            children: [
              Expanded(child: buildButton(text: 'Share', icon: Icons.share)),
              Expanded(child: buildButton(text: 'Like', icon: Icons.thumb_up)),
            ],
          ),
        ),
      );

  Widget buildButton({
    required String text,
    required IconData icon,
  }) =>
      TextButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Text(text, style: TextStyle(fontSize: 20)),
          ],
        ),
        onPressed: () {},
      );

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight + 30;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
