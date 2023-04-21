import 'package:Talkaboat/models/podcasts/podcast.model.dart';
import 'package:Talkaboat/widgets/podcasts/podcast-list.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/search/search_result.model.dart';

class PodcastListHorizontal extends StatelessWidget {
  const PodcastListHorizontal({this.data, this.future, this.title, this.multiplier, this.seeAllCb, Key? key})
      : super(key: key);

  final Future<List<SearchResult>>? future;
  final List<SearchResult>? data;
  final String? title;
  final String? multiplier;
  final void Function()? seeAllCb;

  @override
  Widget build(BuildContext context) {
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
              if (snapshot.data!.isNotEmpty) {
                return buildView(context, snapshot.data!);
              }

              // request was successfull but we got no data - just show nothing
              return Container();
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
      return buildView(context, data!);
    }

    return Container();
  }

  Widget buildView(BuildContext context, List<SearchResult> data) {
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
            Text(AppLocalizations.of(context)!.rewardParam(multiplier), style: Theme.of(context).textTheme.titleMedium)
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
                              AppLocalizations.of(context)!.seeAll,
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
        child: PodcastListWidget(direction: Axis.horizontal, searchResults: data),
      )
    ]);
  }
}
