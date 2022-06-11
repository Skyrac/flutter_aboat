import 'package:flutter/material.dart';
import 'package:talkaboat/models/podcasts/podcast.model.dart';

import '../themes/colors.dart';

class LibraryPreviewWidget extends StatelessWidget {
  const LibraryPreviewWidget({Key? key, required this.podcast})
      : super(key: key);
  final Podcast podcast;

  @override
  Widget build(BuildContext context) {
    return podcast == null ? SizedBox() : Container(
        child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
                color: Colors.blueGrey.shade400,
                child: Row(
                  children: [
                    Image.network(podcast.image == null ? '' : podcast.image!, fit: BoxFit.cover),
                    Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          podcast.title!,
                          style: TextStyle(color: DefaultColors.primaryColor),
                        ))
                  ],
                ))));
  }
}
