import 'dart:convert';

import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/quests/quest.model.dart';
import 'package:Talkaboat/services/ads/ad-manager.service.dart';
import 'package:Talkaboat/services/quests/quest.service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:page_transition/page_transition.dart';

import '../../models/search/search_result.model.dart';

class QuestListWidget extends StatefulWidget {
  QuestListWidget(
      {Key? key,
        required this.direction,
        this.trailing, this.checkUpdate})
      : super(key: key);
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
          item.name = "Watch ad to unlock";
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

  finishTask(Quest quest) async {
    if(quest.progress! >= quest.requirement! && await questService.finishQuest(quest)) {
        setState(() {});
    }
  }

  Widget makeHorizontalListTile(context, Quest quest, bool isUnlock) => Padding(
      padding: const EdgeInsets.all(10),
      child: Stack(children: [
        InkWell(
            onTap: () async {
              if(isUnlock) {
                AdManager.showQuestAd(() async =>
                {
                  await Future.delayed(Duration(seconds: 2)),
                  setState(() { })
                });
              } else {
                await finishTask(quest);
              }
            },
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 190,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isUnlock ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                              height: 150,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  isUnlock ?
                                  Icon(Icons.add) :
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
                              ))) : SizedBox(),
                      Padding(
                          padding:
                          const EdgeInsets.only(left: 5, right: 5, top: 5),
                          child: Text(quest.name!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.titleMedium)),
                      Padding(
                          padding:
                          const EdgeInsets.only(left: 5, right: 5, top: 5),
                          child: Text(quest.description!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                              style: Theme.of(context).textTheme.bodyMedium)),
                      Padding(
                          padding:
                          const EdgeInsets.only(left: 5, right: 5, top: 10),
                          child: Text("Rewards:",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.titleSmall)),
                      for(var reward in quest.rewards!)
                        Padding(
                            padding:
                            const EdgeInsets.only(left: 10, right: 5, top: 5),
                            child: Text("- ${reward.amount!.toStringAsFixed(0)} ${reward.getName()}" ,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: Theme.of(context).textTheme.bodySmall)),
                      Expanded(child: SizedBox()),
                      quest.progress! >= quest.requirement! ?
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Card(
                          child: InkWell(
                            onTap: () async {
                              await finishTask(quest);
                            } ,
                              child:
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.clean_hands),
                                    SizedBox(width: 10,),
                                    Text("Finish")
                                  ],)
                          ),
                        ),
                      ) :
                      Column(children: [
                        Center(
                          child: Padding(
                              padding:
                              const EdgeInsets.only(top: 20),
                              child: Text(quest.progress!.toStringAsFixed(2) + " of " + quest.requirement!.toStringAsFixed(2) ,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: Theme.of(context).textTheme.bodySmall)),
                        ),
                        Center(
                          child: Padding(
                              padding:
                              const EdgeInsets.only(left: 5, right: 5, top: 10),
                              child: AbsorbPointer(
                                  child: SizedBox(
                                    height: 15,
                                    width: 200,
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                          thumbColor: Colors.transparent,
                                          thumbShape:
                                          const RoundSliderThumbShape(enabledThumbRadius: 0.0)),
                                      child: Slider(
                                          value: (quest.progress?.toDouble() ?? 0),
                                          onChanged: (double value) {},
                                          min: 0,
                                          max: quest.requirement?.toDouble() ?? 0),
                                    ),
                                  ))),
                        )
                          ],)

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
    print("Build it");
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${snapshot.error} occurred',
                style: const TextStyle(fontSize: 18),
              ),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            // Extracting data from snapshot object
            print("Snapshot received");
            return makeListBuilder(context, snapshot.data as List<Quest>);
          }
        }
        return const Center(child: CircularProgressIndicator());
      },
      future: questService.getOpenQuests(),
    );
  }
}
