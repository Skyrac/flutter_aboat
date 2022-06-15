import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:talkaboat/models/playlist/playlist.model.dart';

import '../themes/colors.dart';

class PlaylistDetailScreen extends StatefulWidget {
  const PlaylistDetailScreen({Key? key, required this.playlist})
      : super(key: key);
  final Playlist playlist;
  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.width,
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        DefaultColors.primaryColor.shade900,
        DefaultColors.secondaryColor.shade900,
        DefaultColors.secondaryColor.shade900
      ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [createHeader(context), createTrackView(context)],
              ),
            ),
          ),
          appBar: AppBar(
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(
                  icon: const Icon(Icons.more_vert),
                  tooltip: '',
                  onPressed: () {},
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  createHeader(BuildContext context) => ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Card(
        child: SizedBox(
          height: 120,
          child: Row(
            children: [],
          ),
        ),
      ));

  createTrackView(BuildContext context) => ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: widget.playlist.tracks!.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        final entry = widget.playlist.tracks![index];
        final episode = entry.episode!;
        print(episode.image);
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Card(
              child: SizedBox(
                  height: 80,
                  width: MediaQuery.of(context).size.width - 100,
                  child: Center(
                    child: ListTile(
                      leading: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                              imageUrl: episode.image == null ||
                                      episode.image!.isEmpty
                                  ? 'https://picsum.photos/200'
                                  : episode.image!,
                              placeholder: (_, __) => const Center(
                                  child: CircularProgressIndicator()),
                              // progressIndicatorBuilder: (context, url, downloadProgress) =>
                              //     CircularProgressIndicator(value: downloadProgress.progress),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              fit: BoxFit.cover),
                        ),
                      ),
                      title: Text(
                        episode.title!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      subtitle: Text(
                        episode.podcast!.title!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  )),
            ),
          ),
        );
        Container(
          height: 60,
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                  imageUrl: episode.image == null || episode.image!.isEmpty
                      ? 'https://picsum.photos/200'
                      : episode.image!,
                  placeholder: (_, __) =>
                      const Center(child: CircularProgressIndicator()),
                  // progressIndicatorBuilder: (context, url, downloadProgress) =>
                  //     CircularProgressIndicator(value: downloadProgress.progress),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover),
            ),
            title: Text(
              episode.title!,
            ),
          ),
        );
      });
}
