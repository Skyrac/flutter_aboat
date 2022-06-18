import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:talkaboat/models/playlist/playlist.model.dart';
import 'package:talkaboat/screens/playlist-detail.screen.dart';
import 'package:talkaboat/services/user/user.service.dart';

import '../injection/injector.dart';
import 'login.screen.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final userService = getIt<UserService>();
  final playlistCreationController = TextEditingController();

  popupMenu(BuildContext context, Playlist entry) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'rename',
          child: Card(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                Icon(
                  Icons.edit,
                  size: 20,
                  color: Theme.of(context).iconTheme.color,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text('Rename'),
                )
              ])),
        ),
        PopupMenuItem<String>(
          value: 'copy',
          child: Card(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                Icon(
                  Icons.copy,
                  size: 20,
                  color: Theme.of(context).iconTheme.color,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text('Copy'),
                )
              ])),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Card(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                Icon(
                  Icons.delete,
                  size: 20,
                  color: Theme.of(context).iconTheme.color,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text('Delete'),
                )
              ])),
        ),
      ];

  buildPopupButton(context, Playlist entry) => PopupMenuButton(
        child: Card(
            child: Icon(Icons.more_vert,
                color: Theme.of(context).iconTheme.color)),
        onSelected: (value) async {
          switch (value) {
            case "delete":
              if (await userService.removePlaylist(entry.playlistId!)) {
                setState(() {});
              }
              break;
          }
        },
        itemBuilder: (BuildContext context) {
          return popupMenu(context, entry);
        },
      );

  createLoginButton() => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Card(
              child: InkWell(
                onTap: (() {
                  Navigator.push(
                      context,
                      PageTransition(
                          alignment: Alignment.bottomCenter,
                          curve: Curves.bounceOut,
                          type: PageTransitionType.fade,
                          duration: const Duration(milliseconds: 300),
                          reverseDuration: const Duration(milliseconds: 200),
                          child: LoginScreen(() => setState(() {}))));
                }),
                child: SizedBox(
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Text(
                        "Login",
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    )),
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: '',
                    onPressed: () {
                      showAlert(context);
                    },
                  ),
                )
              ],
            ),
            body: userService.isConnected
                ? createPlaylistView()
                : createLoginButton()));
  }

  createPlaylistView() => FutureBuilder(
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
              // Extracting data from snapshot object
              final data = snapshot.data as List<Playlist>;
              if (data.isNotEmpty) {
                return buildPlaylistListView(data);
              }
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
        future: userService.getPlaylists(),
      );

  buildPlaylistListView(List<Playlist> data) => ListView.builder(
      itemCount: data.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        final item = data[index];
        return buildPlaylistTile(context, item);
      });

  buildPlaylistTile(context, Playlist entry) => ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Card(
          child: InkWell(
            onTap: (() {
              Navigator.push(
                  context,
                  PageTransition(
                      alignment: Alignment.bottomCenter,
                      curve: Curves.bounceOut,
                      type: PageTransitionType.rightToLeftWithFade,
                      duration: const Duration(milliseconds: 500),
                      reverseDuration: const Duration(milliseconds: 400),
                      child: PlaylistDetailScreen(playlist: entry)));
            }),
            child: ListTile(
              leading: Container(
                height: 60,
                width: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                      imageUrl: entry.image == null || entry.image!.isEmpty
                          ? 'https://picsum.photos/200'
                          : entry.image!,
                      placeholder: (_, __) =>
                          const Center(child: CircularProgressIndicator()),
                      // progressIndicatorBuilder: (context, url, downloadProgress) =>
                      //     CircularProgressIndicator(value: downloadProgress.progress),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      fit: BoxFit.cover),
                ),
              ),
              title: Text(entry.name!),
              subtitle: Text("Tracks: ${entry.tracks?.length}"),
              trailing: buildPopupButton(context, entry),
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
                      if (await userService
                          .createPlaylist(playlistCreationController.text)) {
                        setState(() {
                          playlistCreationController.text = "";
                          Navigator.pop(context);
                        });
                      }
                    }),
                    child: Text("Create")),
                TextButton(
                    onPressed: (() {
                      Navigator.pop(context);
                    }),
                    child: Text("Cancel"))
              ],
            ));
  }
}
