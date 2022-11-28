import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/services/web3/token.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/podcasts/episode.model.dart';

class PodcastEpisodeSliver extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final TabController? controller;
  final Episode episode;

  PodcastEpisodeSliver({required this.expandedHeight, required this.episode, this.controller});

  final userService = getIt<UserService>();
  final tokenService = getIt<TokenService>();
  final donationAmountController = TextEditingController();

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    const size = 200;
    final top = expandedHeight / 1.1 - shrinkOffset / 3 - size;
    return Stack(
      fit: StackFit.expand,
      children: [
        buildBackground(shrinkOffset, context),
        buildAppBar(shrinkOffset, context),
      ],
    );
  }

  double appear(double shrinkOffset) => shrinkOffset / expandedHeight;

  double disappear(double shrinkOffset) => 1 - shrinkOffset / expandedHeight;

  Widget buildAppBar(double shrinkOffset, context) => PreferredSize(
        preferredSize: Size.fromHeight(expandedHeight),
        child: AppBar(
            leading: const SizedBox(),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(expandedHeight),
              child: Container(
                padding: Localizations.localeOf(context).toString() == "de"
                    ? const EdgeInsets.fromLTRB(10, 5, 10, 10)
                    : const EdgeInsets.fromLTRB(18, 5, 18, 10),
                child: Material(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromRGBO(29, 40, 58, 0.92),
                  child: Container(
                    padding: Localizations.localeOf(context).toString() == "de"
                        ? const EdgeInsets.symmetric(vertical: 8, horizontal: 6)
                        : const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.0),
                        border: const Border(bottom: BorderSide(color: Color.fromRGBO(164, 202, 255, 1))),
                      ),
                      child: TabBar(
                        controller: controller,
                        labelColor: const Color.fromRGBO(188, 140, 75, 1),
                        indicatorColor: const Color.fromRGBO(188, 140, 75, 1),
                        unselectedLabelColor: const Color.fromRGBO(164, 202, 255, 1),
                        tabs: [
                          Tab(text: AppLocalizations.of(context)!.details),
                          Tab(text: AppLocalizations.of(context)!.podcast),
                          Tab(text: AppLocalizations.of(context)!.community),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )),
      );

  Widget buildBackground(double shrinkOffset, context) => Opacity(
      opacity: disappear(shrinkOffset),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Container(
                margin: const EdgeInsets.only(top: 40),
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: NetworkImage(episode.image!),
                    fit: BoxFit.cover,
                  ),
                )),
          ),
        ],
      ));

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight + 100;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
