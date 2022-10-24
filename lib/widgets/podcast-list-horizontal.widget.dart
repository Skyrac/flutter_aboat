import 'package:Talkaboat/models/podcasts/podcast.model.dart';
import 'package:Talkaboat/widgets/podcast-list.widget.dart';
import 'package:flutter/material.dart';

class PodcastListHorizontal extends StatelessWidget {
  const PodcastListHorizontal({this.data, this.future, this.title, this.multiplier, this.seeAllCb, Key? key})
      : super(key: key);

  final Future<List<Podcast>>? future;
  final List<Podcast>? data;
  final String? title;
  final String? multiplier;
  final void Function()? seeAllCb;

  Widget? buildList(BuildContext context) {
    assert(future != null || data != null);
    if (future != null) {
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
              return PodcastListWidget(direction: Axis.horizontal, searchResults: snapshot.data!);
            }
            // TODO: display a nice text
            return Center(
              child: Text(
                'snapshot.hasData: ${snapshot.hasData} snapshot.data: ${snapshot.data != null} snapshot.data!.isNotEmpty: ${snapshot.data!.isNotEmpty}',
                style: const TextStyle(fontSize: 18),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
        future: future!,
      );
    }

    if (data != null) {
      return PodcastListWidget(direction: Axis.horizontal, searchResults: data!);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> flame = multiplier != null
        ? <Widget>[
            const SizedBox(
              width: 10,
            ),
            const Image(
              image: AssetImage("assets/icons/icon_fire.png"),
            ),
            const SizedBox(
              width: 10,
            ),
            // TODO: bottom align this text
            Text("Reward $multiplier", style: Theme.of(context).textTheme.titleMedium)
          ]
        : [Container()];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      title != null
          ? Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(title!, style: Theme.of(context).textTheme.titleLarge),
                ...flame,
                const Spacer(),
                seeAllCb != null
                    ? InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: (() {
                          seeAllCb!();
                        }),
                        child: Row(
                          children: [
                            Text(
                              "See All",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const Icon(Icons.arrow_right_alt)
                          ],
                        ),
                      )
                    : Container(),
              ]))
          : Container(),
      SizedBox(
        height: 150,
        child: buildList(context),
      )
    ]);
  }
}
