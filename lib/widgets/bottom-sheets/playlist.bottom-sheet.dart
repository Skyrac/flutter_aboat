import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../injection/injector.dart';
import '../../models/playlist/playlist.model.dart';
import '../../models/podcasts/episode.model.dart';
import '../../services/user/user.service.dart';
import '../../utils/scaffold_wave.dart';

class PlaylistBottomSheet extends StatefulWidget {
  const PlaylistBottomSheet({Key? key, required this.episodeToAdd}) : super(key: key);
  final Episode episodeToAdd;

  @override
  State<PlaylistBottomSheet> createState() => _PlaylistBottomSheetState();
}

class _PlaylistBottomSheetState extends State<PlaylistBottomSheet> {
  final playlistCreationController = TextEditingController();
  final userService = getIt<UserService>();
  final playlistSearchController = TextEditingController();
  String search = '';
  @override
  Widget build(BuildContext context) {
    return ScaffoldWave(
      physics: const NeverScrollableScrollPhysics(),
      appBar: AppBar(
        title: const Text("Playlists"),
        backgroundColor: const Color.fromRGBO(29, 40, 58, 1),
        actions: [
          userService.isConnected
              ? Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: '',
                    onPressed: () {
                      showAlert(context);
                    },
                  ),
                )
              : const SizedBox()
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: const BoxDecoration(
                    color: Color.fromRGBO(29, 40, 58, 1.0),
                    border: Border(bottom: BorderSide(width: 2, color: Color.fromRGBO(188, 140, 75, 1.0)))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                    child: TextField(
                      controller: playlistSearchController,
                      onChanged: ((text) {
                        setState(() {
                          search = text.toLowerCase();
                        });
                      }),
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: "Search Playlist...", suffixIcon: Icon(Icons.search)),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [IconButton(onPressed: (() {}), icon: const Icon(Icons.sort))],
          ),
          FutureBuilder(
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      '${snapshot.error} occurred',
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                } else if (snapshot.hasData) {
                  // Extracting data from snapshot object
                  return buildPlaylistListView(context, widget.episodeToAdd);
                }
                return const Center(
                  child: Text("No playlists found. Create a new playlist!"),
                );
              }
              return userService.playlists.isNotEmpty
                  ? buildPlaylistListView(context, widget.episodeToAdd)
                  : const Center(child: Text("No playlists found. Create a new playlist!"));
            },
            future: userService.getPlaylists(),
          ),
        ],
      ),
    );
  }

  buildPlaylistListView(BuildContext context, Episode episodeToAdd) {
    var items = <Widget>[];
    for (final entry in userService.playlists.where(
        (element) => playlistSearchController.text.isEmpty || element.name!.contains(playlistSearchController.text))) {
      items.add(buildPlaylistTile(context, entry, episodeToAdd));
    }
    return SingleChildScrollView(
      child: Column(
        children: items,
      ),
    );
  }

  buildPlaylistTile(context, Playlist entry, Episode episodeToAdd) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 25),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: (() async {
              entry.containsEpisode(episodeToAdd.episodeId!)
                  ? await userService.removeFromPlaylistByEpisodeId(entry.playlistId!, episodeToAdd.episodeId!)
                  : await userService.addToPlaylist(entry.playlistId!, episodeToAdd.episodeId!);
              setState(() {});
            }),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              child: SizedBox(
                  height: 90,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        entry.containsEpisode(episodeToAdd.episodeId!)
                            ? const Icon(
                                Icons.playlist_remove,
                                size: 30,
                              )
                            : const Icon(
                                Icons.playlist_add,
                                size: 30,
                              ),
                        VerticalDivider(
                          width: 30,
                          thickness: 2,
                          indent: 10,
                          endIndent: 10,
                          color: entry.containsEpisode(episodeToAdd.episodeId!) ? Colors.green : Colors.deepOrange,
                        ),
                        SizedBox(
                            height: 90,
                            width: 90,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                  imageUrl: entry.image == null || entry.image!.isEmpty
                                      ? 'https://picsum.photos/200'
                                      : entry.image!,
                                  placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                                  // progressIndicatorBuilder: (context, url, downloadProgress) =>
                                  //     CircularProgressIndicator(value: downloadProgress.progress),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                  fit: BoxFit.cover),
                            )),
                        const SizedBox(width: 10),
                        Flexible(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${entry.name}",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                Text(
                                  "Tracks: ${entry.tracks!.length}",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Created: ${entry.getDateTime()}",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: Theme.of(context).textTheme.labelMedium,
                                )
                              ],
                            ))
                      ],
                    ),
                  )),
            ),
          ),
        ),
      );

  void showAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
              backgroundColor: const Color.fromRGBO(48, 73, 123, 1),
              title: const Text("New Playlist..."),
              elevation: 8,
              content: Container(
                height: 50,
                alignment: Alignment.center,
                child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromRGBO(29, 40, 58, 1),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(188, 140, 75, 1),
                            spreadRadius: 0,
                            blurRadius: 0,
                            offset: Offset(0, 1), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: TextField(
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color.fromRGBO(164, 202, 255, 1),
                              ),
                          controller: playlistCreationController,
                          onSubmitted: (text) {
                            Navigator.of(context).pop(text);
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            alignLabelWithHint: true,
                            hintText: "Name your new Playlist",
                            hintStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: const Color.fromRGBO(135, 135, 135, 1), fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                    )),
              ),
              actions: [
                RawMaterialButton(
                  onPressed: (() async {
                    if (await userService.createPlaylist(playlistCreationController.text)) {
                      setState(() {
                        playlistCreationController.text = "";
                        Navigator.pop(context);
                      });
                    }
                  }),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(15),
                      color: const Color.fromRGBO(99, 163, 253, 1),
                      border: Border.all(color: const Color.fromRGBO(188, 140, 75, 0.25), width: 1.0), //
                    ),
                    height: 40,
                    width: 150,
                    child: Center(
                      child: Text(
                        "Create",
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: const Color.fromRGBO(15, 23, 41, 1), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                RawMaterialButton(
                  onPressed: (() {
                    Navigator.pop(context);
                  }),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(15),
                      color: const Color.fromRGBO(154, 0, 0, 1),
                      border: Border.all(color: const Color.fromRGBO(188, 140, 75, 0.25), width: 1.0), //
                    ),
                    height: 40,
                    width: 80,
                    child: Center(
                      child: Text(
                        "Cancel",
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: const Color.fromRGBO(164, 202, 255, 1), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                )
              ],
            ));
  }
}
