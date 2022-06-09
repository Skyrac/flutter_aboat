import 'package:flutter/material.dart';
import 'package:talkaboat/models/podcasts/episode.model.dart';
import 'package:talkaboat/themes/colors.dart';

class EpisodePreviewWidget extends StatelessWidget {
  EpisodePreviewWidget(this.episode, this.setEpisode);
  Episode episode;
  Function setEpisode;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: InkWell(
            onTap: () {
              setEpisode(episode);
            },
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                            height: 200,
                            width: 200,
                            child: Image.network(episode.Image,
                                fit: BoxFit.cover))),
                    Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Text(episode.title,
                            style: TextStyle(
                                color: DefaultColors.primaryColor,
                                fontSize: 24))),
                    Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Text(episode.description,
                            style: TextStyle(
                                color: DefaultColors.primaryColor,
                                fontSize: 18)))
                  ],
                ))));
  }
}
