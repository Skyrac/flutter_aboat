import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../injection/injector.dart';

import '../models/playlist/playlist.model.dart';
import '../models/playlist/track.model.dart';
import '../services/audio/audio-handler.services.dart';
import '../services/user/user.service.dart';
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
  popupMenu(BuildContext context, Track entry) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
            value: 'remove', child: Card(child: Text('Remove from Playlist'))),
      ];

  buildPopupButton(context, Track entry) => PopupMenuButton(
        child: Card(
            child: Icon(Icons.more_vert,
                color: Theme.of(context).iconTheme.color)),
        onSelected: (value) async {
          switch (value) {
            case "remove":
              await userService.removeFromPlaylistByTrackId(
                  entry.playlistId!, entry.playlistTrackId!);
              break;
          }
          setState(() {});
        },
        itemBuilder: (BuildContext context) {
          return popupMenu(context, entry);
        },
      );

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
            child: SizedBox(
              height: size.height,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Flex(
                  direction: Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [createHeader(context), createTrackView(context)],
                ),
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
                    ]),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: Center(
                      child: Icon(
                        Icons.play_arrow_rounded,
                        size: 40,
                      ),
                    ),
                    onPressed: (() async {
                      await audioHandler.updateEpisodeQueue(
                          widget.playlist.tracks!
                              .map((track) => track.episode!)
                              .toList(),
                          index: 0);
                    }),
                  ),
                )
              ],
            ),
          ),
        ),
      ));

  createTrackView(BuildContext context) => Expanded(
        child: ReorderableListView.builder(
            onReorder: (oldIndex, newIndex) async {
              if (newIndex == oldIndex) {
                return;
              }
              if (newIndex > oldIndex) newIndex--;
              final track = widget.playlist.tracks!.removeAt(oldIndex);
              widget.playlist.tracks!.insert(newIndex, track);
              setState(() {});
              await userService.changePlaylistPosition(
                  widget.playlist.playlistId!,
                  track.playlistTrackId!,
                  newIndex);
              setState(() {});
            },
            itemCount: widget.playlist.tracks!.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              final entry = widget.playlist.tracks![index];
              final episode = entry.episode!;
              return createEpisodeWidgets(context, entry, index);
            }),
      );

  createEpisodeWidget(BuildContext context, Track track, int index) => ListTile(
        trailing: buildPopupButton(context, track),
        leading: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
                imageUrl: track.episode!.image == null ||
                        track.episode!.image!.isEmpty
                    ? 'https://picsum.photos/200'
                    : track.episode!.image!,
                placeholder: (_, __) =>
                    const Center(child: CircularProgressIndicator()),
                // progressIndicatorBuilder: (context, url, downloadProgress) =>
                //     CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.cover),
          ),
        ),
        title: Text(
          track.episode!.title!,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        subtitle: Text(
          track.episode!.podcast!.title!,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      );

  createEpisodeWidgets(BuildContext context, Track track, int index) => Padding(
        key: ValueKey(track),
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
                      trailing: buildPopupButton(context, track),
                      leading: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                              imageUrl: track.episode!.image == null ||
                                      track.episode!.image!.isEmpty
                                  ? 'https://picsum.photos/200'
                                  : track.episode!.image!,
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
                        track.episode!.title!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      subtitle: Text(
                        track.episode!.podcast!.title!,
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
