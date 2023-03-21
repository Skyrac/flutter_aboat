import 'package:Talkaboat/screens/playlist-detail.screen.dart';
import 'package:Talkaboat/utils/scaffold_wave.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../injection/injector.dart';
import '../models/playlist/playlist.model.dart';
import '../services/user/user.service.dart';
import '../widgets/login-button.widget.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final userService = getIt<UserService>();
  final playlistCreationController = TextEditingController();

  @override
  void dispose() {
    ImageCache _imageCache = PaintingBinding.instance!.imageCache!;

    _imageCache.clear();

    _imageCache.clearLiveImages();
    super.dispose();
  }

  popupMenu(context, Playlist entry) => <PopupMenuEntry<String>>[
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

  buildPopupButton(context, Playlist entry) => PopupMenuButton(
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Color.fromRGBO(188, 140, 75, 1)),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        constraints: const BoxConstraints.expand(width: 196, height: 160),
        color: const Color.fromRGBO(15, 23, 41, 1),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 32, 14, 32),
          child: Image.asset(
            "assets/images/options.png",
          ),
        ),
        onSelected: (value) async {
          switch (value) {
            case "delete":
              if (await userService.removePlaylist(entry.playlistId!)) {
                setState(() {});
              }
              break;
            case "copy":
              if (await userService.copyPlaylist(entry)) {
                setState(() {});
              }
              break;
          }
        },
        itemBuilder: (BuildContext context) {
          return popupMenu(context, entry);
        },
      );

  @override
  Widget build(BuildContext context) {
    if(userService.currentView.label == ContentViews.Videos) {
      return ScaffoldWave(body: buildNotImplementedYet(context),
          appBar: buildAppBar());
    }
    return SafeArea(
        child: ScaffoldWave(
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
            body: userService.isConnected ? createPlaylistView() : const Center(child: LoginButton())));
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: const Color.fromRGBO(29, 40, 58, 1),
      title: const Text("Playlists"),
    );
  }

  Widget buildNotImplementedYet(BuildContext context) {
    return Column(children: [
      SizedBox(height: 66,),
      Text("Feature not yet implemented as '${userService.currentView.label.value}' is in alpha!")
    ],);
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
          } else {
            return const Center(child: CircularProgressIndicator());
          }
          return Center(
              child: Text(
            "You don't have any Playlists. Press + in the top right corner to create one.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ));
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

  buildPlaylistTile(context, Playlist entry) => Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 90,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
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
              child: Row(children: [
                SizedBox(
                  height: 90,
                  width: 90,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      child: CachedNetworkImage(
                        imageUrl: entry.image == null || entry.image!.isEmpty ? 'https://picsum.photos/200' : entry.image!,
                        fit: BoxFit.fill,
                        placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
                Expanded(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              entry.name!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            Text("Tracks: ${entry.tracks?.length}"),
                          ]),
                    ),
                    SizedBox(
                      height: 90,
                      width: 40,
                      child: buildPopupButton(context, entry),
                    )
                  ],
                ))
              ]),
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
              title: Text(AppLocalizations.of(context)!.newPlaylist),
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
                      AppLocalizations.of(context)!.create,
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: const Color.fromRGBO(15, 23, 41, 1), fontWeight: FontWeight.w600),
                    )),
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
                      AppLocalizations.of(context)!.cancel,
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: const Color.fromRGBO(164, 202, 255, 1), fontWeight: FontWeight.w600),
                    )),
                  ),
                ),
              ],
            ));
  }
}
