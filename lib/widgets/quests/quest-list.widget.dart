import 'dart:convert';

import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/quests/quest.model.dart';
import 'package:Talkaboat/services/quests/quest.service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:page_transition/page_transition.dart';

import '../../models/search/search_result.model.dart';

class QuestListWidget extends StatefulWidget {
  QuestListWidget(
      {Key? key,
        required this.searchResults,
        required this.direction,
        this.trailing, this.checkUpdate})
      : super(key: key);
  final List<Quest> searchResults;
  final Axis direction;
  final Function? trailing;
  final bool? checkUpdate;
  @override
  State<QuestListWidget> createState() => _QuestListWidgetState();
}

class _QuestListWidgetState extends State<QuestListWidget> {
  final questService = getIt<QuestService>();

  Widget makeListBuilder(context, List<Quest> data) => ListView.builder(
      itemCount: data.length + (questService.remainingQuests > 0 ? 1 : 0),
      scrollDirection: widget.direction,
      itemBuilder: (BuildContext context, int index) {
        if(data.length <= index) {
          var item = Quest();
          item.name = "Unlock";
          return makeCard(context, item, true);
        }
        final item = data[index];
        return makeCard(context, item, false);
      });

  Widget makeCard(context,Quest entry, bool isUnlock) => Stack(
      children: [
        Card(
          elevation: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration:
              const BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
              child: widget.direction == Axis.horizontal
                  ? makeHorizontalListTile(context, entry, isUnlock)
                  : makeVerticalListTile(context, entry, isUnlock),
            ),
          ),
        ),
       ]
  );

  Widget makeHorizontalListTile(context, Quest entry, bool isUnlock) => Padding(
      padding: const EdgeInsets.all(10),
      child: Stack(children: [
        InkWell(
            onTap: () async {
            },
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                              height: 120,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl:  'https://picsum.photos/200',
                                    fit: BoxFit.cover,
                                    cacheManager: CacheManager(
                                        Config(
                                            'https://picsum.photos/200',
                                            stalePeriod: const Duration(days: 2))),
                                    placeholder: (_, __) => const Center(
                                        child: CircularProgressIndicator()),
                                    // progressIndicatorBuilder: (context, url, downloadProgress) =>
                                    //     CircularProgressIndicator(value: downloadProgress.progress),
                                    errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                  ),
                                ],
                              ))),
                      Padding(
                          padding:
                          const EdgeInsets.only(left: 5, right: 5, top: 5),
                          child: Text(entry.name!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.titleMedium))
                    ],
                  ),
                ))),

      ]));

  Widget makeVerticalListTile(context, Quest entry, bool isUnlock) => ListTile(
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
    leading: SizedBox(
      width: 60,
      height: 100,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
              child: CachedNetworkImage(
                imageUrl: '',
                fit: BoxFit.fill,
                placeholder: (_, __) =>
                const Center(child: CircularProgressIndicator()),
                // progressIndicatorBuilder: (context, url, downloadProgress) =>
                //     CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ))),
    ),
    title: Text(
      entry.name!,
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
      style:
      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    subtitle: Text(
      entry.description!,
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
      style: const TextStyle(color: Colors.white),
    ),
    trailing: widget.trailing == null
        ? const SizedBox()
        : widget.trailing!(context, entry),
    onTap: () async {

    },
  );

  @override
  Widget build(BuildContext context) {
    return makeListBuilder(context, widget.searchResults);
  }
}
