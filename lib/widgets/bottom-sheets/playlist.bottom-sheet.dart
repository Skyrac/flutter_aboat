import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../injection/injector.dart';
import '../../models/playlist/playlist.model.dart';
import '../../models/podcasts/episode.model.dart';
import '../../services/user/user.service.dart';
import '../../themes/colors.dart';

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
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.8,
      snap: true,
      expand: false,
      builder: (context, controller) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(width: 0, color: Colors.transparent),
                gradient: LinearGradient(colors: [
                  DefaultColors.primaryColor.shade900,
                  DefaultColors.secondaryColor.shade900,
                  DefaultColors.secondaryColor.shade900
                ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            padding: const EdgeInsets.all(16),
            child: ListView(
              controller: controller,
              children: [
                TextButton(
                    onPressed: (() {
                      showAlert(context);
                    }),
                    child: Row(
                      children: const [Icon(Icons.create), SizedBox(width: 10), Text("Create new Playlist")],
                    )),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                    controller: playlistSearchController,
                    onChanged: ((_) {
                      setState(() {});
                    }),
                    decoration: InputDecoration(
                        hintText: "",
                        labelText: "Search Playlist...",
                        suffixIcon: IconButton(
                          onPressed: playlistSearchController.clear,
                          icon: const Icon(Icons.clear),
                        ),
                        labelStyle: Theme.of(context).textTheme.labelLarge,
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ))),
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
            )),
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

  buildPlaylistTile(context, Playlist entry, Episode episodeToAdd) => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Card(
          child: InkWell(
            onTap: (() async {
              entry.containsEpisode(episodeToAdd.episodeId!)
                  ? await userService.removeFromPlaylistByEpisodeId(entry.playlistId!, episodeToAdd.episodeId!)
                  : await userService.addToPlaylist(entry.playlistId!, episodeToAdd.episodeId!);
              setState(() {});
            }),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
              child: SizedBox(
                  height: 60,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        entry.containsEpisode(episodeToAdd.episodeId!) ? const Icon(Icons.remove) : const Icon(Icons.add),
                        VerticalDivider(
                          width: 30,
                          thickness: 2,
                          indent: 10,
                          endIndent: 10,
                          color: entry.containsEpisode(episodeToAdd.episodeId!) ? Colors.green : Colors.deepOrange,
                        ),
                        SizedBox(
                            height: 50,
                            width: 50,
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
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Row(children: [
                                  Text(
                                    "Tracks: ${entry.tracks!.length}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
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
                                    "Created: ${entry.getDateTime()}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: Theme.of(context).textTheme.labelMedium,
                                  )
                                ]),
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
              backgroundColor: Theme.of(context).dialogBackgroundColor,
              title: const Text("New Playlist..."),
              elevation: 8,
              content: TextField(
                  controller: playlistCreationController,
                  decoration: InputDecoration(
                      hintText: "Name your new Playlist",
                      labelText: "Playlist-Name",
                      labelStyle: Theme.of(context).textTheme.labelLarge,
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ))),
              actions: [
                TextButton(
                    onPressed: (() async {
                      if (await userService.createPlaylist(playlistCreationController.text)) {
                        setState(() {
                          playlistCreationController.text = "";
                          Navigator.pop(context);
                        });
                      }
                    }),
                    child: const Text("Create")),
                TextButton(
                    onPressed: (() {
                      Navigator.pop(context);
                    }),
                    child: const Text("Cancel"))
              ],
            ));
  }
}
