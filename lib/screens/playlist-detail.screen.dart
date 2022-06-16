import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:talkaboat/injection/injector.dart';
import 'package:talkaboat/models/playlist/playlist.model.dart';
import 'package:talkaboat/services/audio/audio-handler.services.dart';
import 'package:talkaboat/services/user/user.service.dart';

import '../models/podcasts/episode.model.dart';
import '../themes/colors.dart';

class PlaylistDetailScreen extends StatefulWidget {
  const PlaylistDetailScreen({Key? key, required this.playlist})
      : super(key: key);
  final Playlist playlist;
  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  final userService = getIt<UserService>();
  final audioHandler = getIt<AudioPlayerHandler>();
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 80,
                    width: 80,
                    child: CachedNetworkImage(
                        imageUrl: widget.playlist.image == null ||
                                widget.playlist.image!.isEmpty
                            ? 'https://picsum.photos/200'
                            : widget.playlist.image!,
                        placeholder: (_, __) =>
                            const Center(child: CircularProgressIndicator()),
                        // progressIndicatorBuilder: (context, url, downloadProgress) =>
                        //     CircularProgressIndicator(value: downloadProgress.progress),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        fit: BoxFit.cover),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.playlist.name!,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Row(children: [
                      Text(
                        "Tracks: ${widget.playlist.tracks!.length}",
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const Divider(
                        height: 20,
                        thickness: 10,
                        indent: 20,
                        endIndent: 5,
                        color: Colors.deepOrange,
                      ),
                      Text(
                        "Created: ${widget.playlist.getDateTime()}",
                        style: Theme.of(context).textTheme.labelMedium,
                      )
                    ])
                  ],
                )
              ],
            ),
          ),
        ),
      ));

  createTrackView(BuildContext context) => ReorderableListView.builder(
      onReorder: (oldIndex, newIndex) async {
        if (newIndex == oldIndex) {
          return;
        }
        if (newIndex > oldIndex) newIndex--;
        final track = widget.playlist.tracks!.removeAt(oldIndex);
        widget.playlist.tracks!.insert(newIndex, track);
        setState(() {});
        await userService.changePlaylistPosition(
            widget.playlist.playlistId!, track.playlistTrackId!, newIndex);
        setState(() {});
      },
      shrinkWrap: true,
      itemCount: widget.playlist.tracks!.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        final entry = widget.playlist.tracks![index];
        final episode = entry.episode!;
        return createEpisodeWidget(context, episode, index);
      });

  createEpisodeWidget(BuildContext context, Episode episode, int index) =>
      Padding(
        key: ValueKey(episode),
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Card(
            child: SizedBox(
                height: 80,
                width: MediaQuery.of(context).size.width - 100,
                child: Center(
                  child: InkWell(
                    onTap: (() async {
                      await audioHandler.updateEpisodeQueue(
                          widget.playlist.tracks!
                              .map((track) => track.episode!)
                              .toList(),
                          index: index);
                    }),
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
                  ),
                )),
          ),
        ),
      );
}
