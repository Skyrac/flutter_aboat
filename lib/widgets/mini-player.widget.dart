import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../injection/injector.dart';
import '../models/podcasts/episode.model.dart';
import '../themes/colors.dart';

class MiniPlayerWidget extends StatefulWidget {
  MiniPlayerWidget({Key? key, required this.episode}) : super(key: key);
  final Episode? episode;
  AudioPlayer audioPlayer = getIt<AudioPlayer>();

  Future<bool> togglePlayState() async {
    //TODO: Add Start Time
    if (audioPlayer.playerState.playing) {
      await audioPlayer.pause();
      return false;
    } else {
      await audioPlayer.setUrl(episode!.audio);
      await audioPlayer.play();
      return true;
    }
  }

  Future<void> pausePlayer() async {
    await audioPlayer.pause();
  }

  @override
  State<MiniPlayerWidget> createState() => _MiniPlayerWidgetState();
}

class _MiniPlayerWidgetState extends State<MiniPlayerWidget> {
  Episode? currentEpisode;
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    if (widget.episode == null) {
      return SizedBox();
    }
    Size deviceSize = MediaQuery.of(context).size;
    return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: DefaultColors.secondaryColor,
        width: deviceSize.width,
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.network(widget.episode!.Image, fit: BoxFit.cover),
            Text(
              widget.episode!.title,
              style: TextStyle(color: Colors.white),
            ),
            IconButton(
                onPressed: () {
                  isPlaying = !isPlaying;
                  widget.togglePlayState();
                  setState(() {});
                },
                icon: isPlaying
                    ? Icon(Icons.pause, color: Colors.white)
                    : Icon(Icons.play_arrow, color: Colors.white))
          ],
        ));
  }
}
