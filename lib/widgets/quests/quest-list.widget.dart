import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/quests/quest.model.dart';
import 'package:Talkaboat/services/ads/ad-manager.service.dart';
import 'package:Talkaboat/services/quests/quest.service.dart';
import 'package:Talkaboat/themes/colors_new.dart';
import 'package:Talkaboat/utils/Snackbar_Creator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class QuestListWidget extends StatefulWidget {
  const QuestListWidget({Key? key, required this.direction, this.trailing, this.checkUpdate}) : super(key: key);
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
        if (index - 1 == -1) {
          var item = Quest();
          item.name = "Watch ad to unlock quest";
          return makeAdCard(context, item);
        } else {
          final item = data[index - 1];
          return makeCard(context, item);
        }
      });

  Widget makeAdCard(context, Quest quest) => Stack(children: [
        // Stack to shrink the box to size
        Card(
          elevation: 0.0,
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: NewDefaultColors.secondaryColorAlphaBlend,
          child: Container(
            child: makeUnlock(context, quest),
          ),
        ),
      ]);

  Widget makeCard(context, Quest quest) => Stack(children: [
        Card(
          shadowColor: quest.progress != null && quest.progress! >= quest.requirement!
              ? Colors.green
              : const Color.fromRGBO(99, 163, 253, 1.0),
          elevation: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: NewDefaultColors.secondaryColorAlphaBlend,
          child: Container(
            child: widget.direction == Axis.horizontal
                ? makeHorizontalListTile(context, quest)
                : makeVerticalListTile(context, quest),
          ),
        ),
      ]);

  finishTask(Quest quest) async {
    if (quest.progress! >= quest.requirement! && await questService.finishQuest(quest)) {
      setState(() {});
    }
  }

  Widget makeUnlock(context, Quest quest) => InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: () async {
          ShowSnackBar(context, "Loading ad...");
          AdManager.showQuestAd((String result) async => {
                if (result.isEmpty)
                  {await Future.delayed(const Duration(seconds: 2)), setState(() {})}
                else
                  {ShowSnackBar(context, result)}
              });
        },
        child: SizedBox(
          width: 140,
          height: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                  padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 0),
                  child: SizedBox(
                    height: 65,
                    child: Center(
                        child: Text(quest.name!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
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
        width: 140,
        height: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.all(10),
                child: Text(quest.name!,
                    overflow: TextOverflow.ellipsis, maxLines: 2, style: Theme.of(context).textTheme.titleSmall)),
            Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 0),
                child: Text(quest.description!,
                    overflow: TextOverflow.ellipsis, maxLines: 3, style: Theme.of(context).textTheme.bodySmall)),
            const Expanded(child: SizedBox()),
            quest.progress! >= quest.requirement!
                ? Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                      color: NewDefaultColors.primaryColor,
                      child: InkWell(
                          onTap: () async {
                            await finishTask(quest);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.clean_hands, color: NewDefaultColors.secondaryColorBase),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Finish",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(color: NewDefaultColors.secondaryColorBase),
                                )
                              ],
                            ),
                          )),
                    ),
                  )
                : Column(
                    children: [
                      Center(
                        child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text("${quest.progress!.toStringAsFixed(2)} of ${quest.requirement!.toStringAsFixed(2)}",
                                overflow: TextOverflow.ellipsis, maxLines: 2, style: Theme.of(context).textTheme.bodySmall)),
                      ),
                      Center(
                        child: Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 10),
                            child: AbsorbPointer(
                                child: SizedBox(
                              height: 15,
                              width: 140,
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                    thumbColor: Colors.transparent,
                                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0.0)),
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

  Widget makeVerticalListTile(context, Quest entry) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        leading: SizedBox(
          width: 60,
          height: 100,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                  child: CachedNetworkImage(
                imageUrl: '',
                fit: BoxFit.fill,
                placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                // progressIndicatorBuilder: (context, url, downloadProgress) =>
                //     CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ))),
        ),
        title: Text(
          entry.name!,
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
        onTap: () async {},
      );

  @override
  Widget build(BuildContext context) {
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
            return makeListBuilder(context, snapshot.data as List<Quest>);
          }
        }
        return const Center(child: CircularProgressIndicator());
      },
      future: questService.getOpenQuests(),
    );
  }
}
