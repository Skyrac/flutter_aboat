import 'package:Talkaboat/screens/search.screen.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../injection/injector.dart';
import '../models/rewards/reward.model.dart';
import '../services/audio/audio-handler.services.dart';
import '../services/state/state.service.dart';
import '../services/user/user.service.dart';

class PlayerControlWidget extends StatefulWidget {
  const PlayerControlWidget({Key? key}) : super(key: key);

  @override
  State<PlayerControlWidget> createState() => _PlayerControlWidgetState();
}

class _PlayerControlWidgetState extends State<PlayerControlWidget> with SingleTickerProviderStateMixin {
  late final audioHandler = getIt<AudioPlayerHandler>();
  late AnimationController _controller;
  final userService = getIt<UserService>();
  final stateService = getIt<StateService>();
  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );
    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        StreamBuilder<PlaybackState>(
          stream: audioHandler.playbackState,
          builder: (context, snapshot) {
            final playbackState = snapshot.data;
            final processingState = playbackState?.processingState;
            final playing = playbackState?.playing;
            if (processingState == AudioProcessingState.loading || processingState == AudioProcessingState.buffering) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                width: 20.0,
                height: 20.0,
                child: const CircularProgressIndicator(),
              );
            } else if (playing != true) {
              return IconButton(
                color: const Color.fromRGBO(99, 163, 253, 1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.play_arrow),
                iconSize: 34.0,
                onPressed: audioHandler.play,
              );
            } else {
              return IconButton(
                color: const Color.fromRGBO(99, 163, 253, 1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.pause),
                iconSize: 34.0,
                onPressed: audioHandler.pause,
              );
            }
          },
        ),
        StreamBuilder<PlaybackState>(
          stream: audioHandler.playbackState,
          builder: (context, snapshot) {
            final playbackState = snapshot.data;
            final processingState = playbackState?.processingState;
            final playing = playbackState?.playing;
            if (processingState == AudioProcessingState.loading || processingState == AudioProcessingState.buffering) {
              return Container(
                margin: const EdgeInsets.all(0.0),
                width: 10.0,
                height: 10.0,
                child: const CircularProgressIndicator(),
              );
            } else if (playing == true && userService.isConnected) {
              _controller.repeat();
            } else {
              _controller.stop();
            }
            return Container(
              padding: const EdgeInsets.only(right: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamBuilder<Reward>(
                      stream: userService.rewardStream(),
                      builder: (context, snapshot) {
                        return Text(
                          "${snapshot.data == null || snapshot.data!.total == null ? 0 : snapshot.data?.total?.round()}",
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 10, color: Colors.white),
                        );
                      }),
                  const SizedBox(
                    width: 5,
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    iconSize: 14.0,
                    icon: RotationTransition(
                      turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
                      child: const Image(width: 14, image: AssetImage('assets/images/aboat.png')),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          PageTransition(
                              alignment: Alignment.bottomCenter,
                              curve: Curves.bounceOut,
                              type: PageTransitionType.rightToLeftWithFade,
                              duration: const Duration(milliseconds: 500),
                              reverseDuration: const Duration(milliseconds: 500),
                              child: const SearchScreen()));
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
