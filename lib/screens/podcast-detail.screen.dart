import 'package:flutter/material.dart';
import 'package:talkaboat/models/search/search_result.model.dart';

import '../themes/colors.dart';

class PodcastDetailScreen extends StatelessWidget {
  final SearchResult? podcastSearchResult;
  const PodcastDetailScreen({Key? key, this.podcastSearchResult})
      : super(key: key);

  Widget topContent(context) => Stack(
        children: <Widget>[
          Container(
              padding: const EdgeInsets.only(left: 10.0),
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(podcastSearchResult!.image!),
                  fit: BoxFit.cover,
                ),
              )),
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            padding: const EdgeInsets.all(40.0),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: DefaultColors.secondaryColorAlphaBlend.shade900),
            child: Center(
              child: Text(podcastSearchResult!.title!),
            ),
          ),
          Positioned(
            left: 8.0,
            top: 60.0,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
          )
        ],
      );
  @override
  Widget build(BuildContext context) {
    print(podcastSearchResult!.id);
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        DefaultColors.primaryColor.shade900,
        DefaultColors.secondaryColor.shade900,
        DefaultColors.secondaryColor.shade900
      ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Column(
        children: [topContent(context)],
      ),
    ));
  }
}
