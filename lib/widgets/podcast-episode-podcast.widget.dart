import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/podcasts/podcast.model.dart';
import 'package:Talkaboat/services/audio/podcast.service.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/widgets/podcast-list.widget.dart';
import 'package:flutter/material.dart';

class PodcastEpisodePodcast extends StatefulWidget {
  const PodcastEpisodePodcast({super.key, required this.podcastId});

  final int podcastId;

  @override
  State<PodcastEpisodePodcast> createState() => _PodcastEpisodePodcastState();
}

class _PodcastEpisodePodcastState extends State<PodcastEpisodePodcast> {
  final podcastService = getIt<PodcastService>();
  final userService = getIt<UserService>();

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
              final podcast = snapshot.data;
              // Extracting data from snapshot object
              return Container(
                  padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                  height: 105,
                  width: MediaQuery.of(context).size.width,
                  child: PodcastListWidget(
                    searchResults: [podcast!],
                    direction: Axis.vertical,
                  ));
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
        });
  }

  buildPopupButton(context, Podcast entry) => PopupMenuButton(
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Color.fromRGBO(188, 140, 75, 1)),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        constraints: const BoxConstraints.expand(width: 196, height: 110),
        color: const Color.fromRGBO(15, 23, 41, 1),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 30, 14, 30),
          child: Image.asset(
            "assets/images/options.png",
            width: 6,
          ),
        ),
        onSelected: (value) async {
          switch (value) {
            case "add_to_avorites":
              await userService.addToFavorites(widget.podcastId);
              break;
            case "remove_to_avorites":
              await userService.removeFromFavorites(widget.podcastId);
              break;
          }
        },
        itemBuilder: (BuildContext context) {
          return popupMenu(context, entry);
        },
      );

  popupMenu(BuildContext context, Podcast entry) {
    if (!userService.isConnected) {
      return <PopupMenuItem<String>>[];
    }
    return [
      !userService.isInFavorites(entry.id!)
          ? PopupMenuItem<String>(
              value: 'add_to_avorites',
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(29, 40, 58, 0.97),
                    border: Border.all(color: const Color.fromRGBO(188, 140, 75, 0.25)),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.favorite,
                      size: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text('Add to favorites'),
                    ),
                  ],
                ),
              ),
            )
          : PopupMenuItem<String>(
              value: 'remove_to_avorites',
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(29, 40, 58, 0.97),
                    border: Border.all(color: const Color.fromRGBO(188, 140, 75, 0.25)),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.favorite,
                      size: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text('Remove from favorites'),
                    ),
                  ],
                ),
              ),
            ),
    ];
  }

  Future<Podcast?> getPodcast(int? podcastId) {
    if (podcastId != null) {
      return podcastService.getPodcastDetails(podcastId, "asc", 1);
    }
    return Future.value(null);
  }
}
