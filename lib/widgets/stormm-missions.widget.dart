import 'package:Talkaboat/models/stormm/stormm-mission.model.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../injection/injector.dart';
import '../services/user/user.service.dart';
import '../themes/colors_new.dart';

class StormmMissionWidget extends StatefulWidget {
  const StormmMissionWidget({Key? key}) : super(key: key);

  @override
  State<StormmMissionWidget> createState() => _StormmMissionWidgetState();
}

class _StormmMissionWidgetState extends State<StormmMissionWidget> {

  final userService = getIt<UserService>();

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
              if (snapshot.data!.isNotEmpty) {
                return buildView(context, snapshot.data!);
              }

              // request was successfull but we got no data - just show nothing
              return Container();
            }
            // TODO: display a nice text
            return Center(
              child: Text(
                'snapshot.hasData: ${snapshot.hasData} snapshot.data: ${snapshot
                    .data != null} snapshot.data!.isNotEmpty: ${snapshot.data!
                    .isNotEmpty}',
                style: const TextStyle(fontSize: 18),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
        future: userService.getStormmMissions()
    );
  }

  Widget buildView(context, List<StormmMission> missions) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(10, 20, 0, 0),
            child: Text("S.T.O.R.M.M. Missions", style: Theme
                .of(context)
                .textTheme
                .titleLarge)),
        InkWell(
          onTap: () async =>
          {
            await launchUrl(Uri.parse("https://t.me/talkaboat"))
          },
          child: Card(
            shadowColor: const Color.fromRGBO(99, 163, 253, 1.0),
            elevation: 8.0,
            margin: const EdgeInsets.symmetric(
                horizontal: 10.0, vertical: 10.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            color: NewDefaultColors.secondaryColorAlphaBlend,
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text("Click here to join TG for a chance to earn \$ABOAT")),
          ),
        ),
        SizedBox(height: 280, child: makeListBuilder(context, missions)),
      ],
    );
  }

  Widget makeListBuilder(context, List<StormmMission> data) =>
      ListView.builder(
          itemCount: data.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) {
            final item = data[index];
            return makeCard(context, item);
          });

  Widget makeCard(context, StormmMission mission) =>
      Stack(children: [
        Card(
          shadowColor: const Color.fromRGBO(99, 163, 253, 1.0),
          elevation: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          color: NewDefaultColors.secondaryColorAlphaBlend,
          child: Container(
            child: InkWell(borderRadius: BorderRadius.circular(10.0),
                onTap: () async {
                  await launchUrl(Uri.parse(mission.url));
                },
                child: SizedBox(
                    width: 200,
                    height: 280,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text("Click to Like & Retweet\n\nSTORMM needs your assistance!\n\nMission:\n- ${mission.requiredLikes} remaining likes\n- ${mission.requiredRetweets} remaining retweets\n\nReward:\n- 5\$ Buyback of \$ABOAT\n- Chance to earn 2\$ worth \$ABOAT in Telegram")
                    )
                )
            ),
          ),
        )
      ]);
}

