import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/quests/quest.model.dart';
import 'package:Talkaboat/services/ads/ad-manager.service.dart';
import 'package:Talkaboat/services/quests/quest.service.dart';
import 'package:Talkaboat/themes/colors_new.dart';
import 'package:Talkaboat/utils/Snackbar_Creator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/quests/quest-reward.model.dart';

class QuestListWidget extends StatefulWidget {
  const QuestListWidget(
      {Key? key, required this.direction, this.trailing})
      : super(key: key);
  final Axis direction;
  final Function? trailing;
  @override
  State<QuestListWidget> createState() => _QuestListWidgetState();
}

class _QuestListWidgetState extends State<QuestListWidget> {
  final questService = getIt<QuestService>();
  final double height = 200;
  final double width = 160;

  Widget makeListBuilder(context, List<Quest> data) => ListView.builder(
      itemCount: data.length + (questService.remainingQuests > 0 ? 1 : 0),
      scrollDirection: widget.direction,
      itemBuilder: (BuildContext context, int index) {
        if (index - 1 == -1) {
          var item = Quest();
          item.name = AppLocalizations.of(context)?.unlockQuest ??
              "Unlock Quest by watching ad";
          return makeAdCard(context, item);
        } else {
          final item = data[index - 1];
          return item.progress! >= item.requirement!
              ? makeFinishedCard(context, item)
              : makeCard(context, item);
        }
      });

  Widget makeAdCard(context, Quest quest) => Stack(children: [
        // Stack to shrink the box to size
        Card(
          elevation: 0.0,
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: NewDefaultColors.secondaryColorAlphaBlend,
          child: Container(
            child: makeUnlock(context, quest),
          ),
        ),
      ]);

  Widget makeFinishedCard(context, Quest quest) => Stack(children: [
        // Stack to shrink the box to size
        Card(
          elevation: 4.0,
          shadowColor: const Color.fromRGBO(188, 140, 75, 1.0),
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: NewDefaultColors.secondaryColorAlphaBlend,
          child: InkWell(
            borderRadius: BorderRadius.circular(10.0),
            onTap: () async {
              await finishTask(quest);
            },
            child: SizedBox(
              width: width,
              height: height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                      padding: EdgeInsets.only(top: 20, bottom: 10),
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: Center(
                          child: Icon(
                            Icons.check_circle_outline,
                            color: Color.fromRGBO(188, 140, 75, 1.0),
                            size: 40,
                          ),
                        ),
                      )),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: SizedBox(
                          height: 70,
                          child: Center(
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                Text(AppLocalizations.of(context)!.completed,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                Text(quest.name!,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.titleMedium)
                              ])))),
                ],
              ),
            ),
          ),
        ),
      ]);

  Widget makeCard(context, Quest quest) => Stack(children: [
        Card(
          shadowColor: const Color.fromRGBO(99, 163, 253, 1.0),
          elevation: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: NewDefaultColors.secondaryColorAlphaBlend,
          child: Container(
            child: widget.direction == Axis.horizontal
                ? makeHorizontalListTile(context, quest)
                : makeVerticalListTile(context, quest),
          ),
        ),
      ]);

  finishTask(Quest quest) async {
    if (quest.progress! >= quest.requirement! &&
        await questService.finishQuest(quest)) {
      setState(() {});
    }
  }

  Widget makeUnlock(context, Quest quest) => InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: () async {
          ShowSnackBar(context, AppLocalizations.of(context)!.loadingAd);
          AdManager.showQuestAd((String result) async => {
                if (result.isEmpty)
                  {
                    await Future.delayed(const Duration(seconds: 2)),
                    setState(() {})
                  }
                else
                  {ShowSnackBar(context, result)}
              });
        },
        child: SizedBox(
          width: width,
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                  padding: EdgeInsets.all(10),
                  child: SizedBox(
                    height: 65,
                    child: Center(
                      child: Icon(Icons.add),
                    ),
                  )),
              Padding(
                  padding: const EdgeInsets.only(
                      left: 10, right: 10, bottom: 10, top: 0),
                  child: SizedBox(
                    height: 65,
                    child: Center(
                        child: Text(quest.name!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium)),
                  )),
            ],
          ),
        ),
      );

  Widget makeHorizontalListTile(context, Quest quest) => InkWell(
      borderRadius: BorderRadius.circular(10.0),
      onTap: () async {
        await finishTask(quest);
      },
      child: SizedBox(
        width: width,
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.all(10),
                child: Text(quest.name!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.titleMedium)),
            Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, bottom: 10, top: 0),
                child: Text(quest.description!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 5,
                    style: Theme.of(context).textTheme.labelMedium)),
            Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(AppLocalizations.of(context)?.reward ?? "Rewards",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.titleMedium),
                    for (var element in quest.rewards!)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("+ ${element.amount}",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.labelMedium),
                          Text(element.getName(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.labelMedium),
                        ],
                      )
                  ],
                )),
            const Expanded(child: SizedBox()),
            Column(
              children: [
                Center(
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                          "${quest.progress!.toStringAsFixed(2)} of ${quest.requirement!.toStringAsFixed(2)}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.labelSmall)),
                ),
                Center(
                  child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 0, bottom: 10),
                      child: AbsorbPointer(
                          child: SizedBox(
                        height: 15,
                        width: width,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                              thumbColor: Colors.transparent,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 0.0)),
                          child: Slider(
                              value: (quest.progress?.toDouble() ?? 0),
                              onChanged: (double value) {},
                              min: 0,
                              max: quest.requirement?.toDouble() ?? 0),
                        ),
                      ))),
                )
              ],
            )
          ],
        ),
      ));

  List<Widget> makeRewardList(context, List<QuestReward>? rewards) {
    debugPrint("$rewards");
    final widgets = List<Row>.empty(growable: true);
    if (rewards == null) {
      return widgets;
    }
    return <Widget>[
      for (var element in rewards)
        Row(
          children: [
            Text("${element.amount}",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: Theme.of(context).textTheme.labelMedium),
            Text(element.getName(),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: Theme.of(context).textTheme.labelMedium),
          ],
        )
    ];
  }

  Widget makeVerticalListTile(context, Quest entry) => ListTile(
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
        onTap: () async {},
      );

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            children: [
              Text(AppLocalizations.of(context)!.tasks,
                  style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                  onPressed: () {
                    setState(() {});
                  },
                  icon: const Icon(Icons.refresh))
            ],
          )),
      SizedBox(
          height: 224,
          child: FutureBuilder(
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
                  return makeListBuilder(context, snapshot.data as List<Quest>);
                }
              }
              return const Center(child: CircularProgressIndicator());
            },
            future: questService.getOpenQuests(),
          ))
    ]);
  }
}
