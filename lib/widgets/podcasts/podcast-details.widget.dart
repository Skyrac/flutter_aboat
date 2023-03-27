import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/services/audio/podcast.service.dart';
import 'package:Talkaboat/utils/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PodcastDetails extends StatefulWidget {
  const PodcastDetails({super.key, required this.podcastId});

  final int podcastId;

  @override
  State<PodcastDetails> createState() => _PodcastDetailsState();
}

class _PodcastDetailsState extends State<PodcastDetails> {
  final podcastService = getIt<PodcastService>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: podcastService.getPodcastDetails(widget.podcastId, "asc", -1),
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
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    height: 40,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalizations.of(context)!.general,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color.fromRGBO(99, 163, 253, 1),
                          ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      SizedBox(
                        width: 30,
                        child: Text(
                          AppLocalizations.of(context)!.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: 250,
                        child: Text(
                          snapshot.data!.title!,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ]),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.episodes,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text("${snapshot.data!.totalEpisodes ?? 0}")
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalizations.of(context)!.authors,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 0, 10),
                    alignment: Alignment.topLeft,
                    child: Text(
                      snapshot.data!.publisher!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color.fromRGBO(99, 163, 253, 0.5),
                          ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(bottom: 7),
                    child: Text(
                      AppLocalizations.of(context)!.categories,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  buildCategoryBadges(context, snapshot.data!.genres!),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      AppLocalizations.of(context)!.description,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color.fromRGBO(99, 163, 253, 1),
                          ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      removeAllHtmlTags(snapshot.data!.description!),
                      textAlign: TextAlign.left,
                      textDirection: TextDirection.ltr,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: const Color.fromRGBO(99, 163, 253, 1)),
                    ),
                  )
                ],
              ),
            );
          } else {
            return const Center(
              child: Text(
                'No data found for this podcast. Please try again later!',
                style: TextStyle(fontSize: 18),
              ),
            );
          }
        }
        return const SizedBox();
      },
    );
  }
}
