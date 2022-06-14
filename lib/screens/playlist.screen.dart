import 'package:flutter/material.dart';
import 'package:talkaboat/services/user/user.service.dart';

import '../injection/injector.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final userService = getIt<UserService>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Text('Playlist',
            style: TextStyle(fontSize: 40, color: Colors.white)));
  }
}
