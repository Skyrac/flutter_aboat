import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../injection/injector.dart';

import '../models/playlist/playlist.model.dart';
import '../models/playlist/track.model.dart';
import '../services/audio/audio-handler.services.dart';
import '../services/user/user.service.dart';
import '../themes/colors.dart';
import '../utils/scaffold_wave.dart';

class PlaylistDetailScreen extends StatefulWidget {
  const PlaylistDetailScreen({Key? key, required this.playlist}) : super(key: key);
  final Playlist playlist;
  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  final userService = getIt<UserService>();
  final audioHandler = getIt<AudioPlayerHandler>();

  popupMenu(BuildContext context, Track entry) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'remove',
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
                  Icons.playlist_remove,
                  size: 20,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text('Remove from Playlist'),
                ),
              ],
            ),
          ),
        ),
      ];

  buildPopupButton(context, Track entry) => PopupMenuButton(
        color: const Color.fromRGBO(15, 23, 41, 1.0),
        offset: const Offset(-40.0, 0.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 34, 14, 34),
          child: Image.asset(
            "assets/images/options.png",
          ),
        ),
        onSelected: (value) async {
          switch (value) {
            case "remove":
              await userService.removeFromPlaylistByTrackId(entry.playlistId!, entry.playlistTrackId!);
              break;
          }
          setState(() {});
        },
        itemBuilder: (BuildContext context) {
          return popupMenu(context, entry);
        },
      );

  popupMenuTop(context, Playlist entry) => <PopupMenuEntry<String>>[
        /*PopupMenuItem<String>(
            value: 'rename',
            child: Container(
                width: 176,
                height: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color.fromRGBO(29, 40, 58, 0.97),
                    border: Border.all(color: const Color.fromRGBO(188, 140, 75, 0.25))),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    const Icon(
                      Icons.edit,
                      color: Color.fromRGBO(99, 163, 253, 1),
                      size: 25,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text('Rename',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(color: const Color.fromRGBO(99, 163, 253, 1))),
                  ],
                ))),
        PopupMenuItem<String>(
            value: 'copy',
            child: Container(
                width: 176,
                height: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color.fromRGBO(29, 40, 58, 0.97),
                    border: Border.all(color: const Color.fromRGBO(188, 140, 75, 0.25))),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    const Icon(Icons.copy, color: Color.fromRGBO(99, 163, 253, 1), size: 25),
                    const SizedBox(
                      width: 10,
                    ),
                    Text('Copy',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(color: const Color.fromRGBO(99, 163, 253, 1))),
                  ],
                ))),*/
        PopupMenuItem<String>(
            value: 'delete',
            child: Container(
                width: 176,
                height: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color.fromRGBO(29, 40, 58, 0.97),
                    border: Border.all(color: const Color.fromRGBO(188, 140, 75, 0.25))),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    const Icon(Icons.delete, size: 25, color: Color.fromRGBO(99, 163, 253, 1)),
                    const SizedBox(
                      width: 10,
                    ),
                    Text('Delete',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(color: const Color.fromRGBO(99, 163, 253, 1))),
                  ],
                ))),
      ];

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
        child: ScaffoldWave(
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
            centerTitle: false,
            leadingWidth: 35,
            titleSpacing: 3,
            title: Text(
              widget.playlist.name!,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color.fromRGBO(99, 163, 253, 1),
                  ),
            ),
            backgroundColor: const Color.fromRGBO(29, 40, 58, 1),
            actions: [
              PopupMenuButton(
                shape: const RoundedRectangleBorder(
                  side: BorderSide(color: Color.fromRGBO(188, 140, 75, 1)),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                color: const Color.fromRGBO(15, 23, 41, 1),
                onSelected: (value) async {
                  switch (value) {
                    case "delete":
                      if (await userService.removePlaylist(widget.playlist.playlistId!)) {
                        setState(() {});
                      }
                      break;
                    case "copy":
                      if (await userService.copyPlaylist(widget.playlist)) {
                        setState(() {});
                      }
                      break;
                  }
                },
                itemBuilder: (BuildContext context) {
                  return popupMenuTop(context, widget.playlist);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  createHeader(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 100,
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: CachedNetworkImage(
                        imageUrl: widget.playlist.image == null || widget.playlist.image!.isEmpty
                            ? 'https://picsum.photos/200'
                            : widget.playlist.image!,
                        cacheManager: CacheManager(Config(
                            widget.playlist.image == null || widget.playlist.image!.isEmpty
                                ? 'https://picsum.photos/200'
                                : widget.playlist.image!,
                            stalePeriod: const Duration(days: 7))),
                        placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                        // progressIndicatorBuilder: (context, url, downloadProgress) =>
                        //     CircularProgressIndicator(value: downloadProgress.progress),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                        fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.playlist.name!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              "Tracks: ${widget.playlist.tracks!.length}",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "Created: ${widget.playlist.getDateTime()}",
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Container(
                          child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: IconButton(
                          color: const Color.fromRGBO(99, 163, 253, 1),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.play_arrow),
                          iconSize: 50.0,
                          onPressed: (() async {
                            await audioHandler.updateEpisodeQueue(
                                widget.playlist.tracks!.map((track) => track.episode!).toList(),
                                index: 0);
                          }),
                        ),
                      ))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

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
              await userService.changePlaylistPosition(widget.playlist.playlistId!, track.playlistTrackId!, newIndex);
              setState(() {});
            },
            itemCount: widget.playlist.tracks!.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              final entry = widget.playlist.tracks![index];
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
                imageUrl: track.episode!.image == null || track.episode!.image!.isEmpty
                    ? 'https://picsum.photos/200'
                    : track.episode!.image!,
                placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
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
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            child: SizedBox(
                height: 90,
                child: Center(
                  child: InkWell(
                    onTap: (() async {
                      await audioHandler.updateEpisodeQueue(widget.playlist.tracks!.map((track) => track.episode!).toList(),
                          index: index);
                    }),
                    child: Row(children: [
                      SizedBox(
                        height: 90,
                        width: 90,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            child: CachedNetworkImage(
                              imageUrl: track.episode!.image == null || track.episode!.image!.isEmpty
                                  ? 'https://picsum.photos/200'
                                  : track.episode!.image!,
                              fit: BoxFit.fill,
                              placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              fit: FlexFit.loose,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      track.episode!.title!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.labelLarge,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      track.episode!.podcast!.title!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 90,
                              width: 40,
                              child: buildPopupButton(context, track),
                            )
                          ],
                        ),
                      )
                    ]),
                  ),
                )),
          ),
        ),
      );
}
