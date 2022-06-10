import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:talkaboat/services/audio/audio-handler.services.dart';
import 'package:talkaboat/widgets/player-control.widget.dart';

import '../injection/injector.dart';
import '../models/podcasts/episode.model.dart';
import '../themes/colors.dart';

class MiniPlayerWidget extends StatefulWidget {
  MiniPlayerWidget({Key? key, required this.episode}) : super(key: key);
  final Episode? episode;

  @override
  State<MiniPlayerWidget> createState() => _MiniPlayerWidgetState();
}

class _MiniPlayerWidgetState extends State<MiniPlayerWidget> {
  Episode? currentEpisode;
  late final audioHandler = getIt<AudioPlayerHandler>();

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
        child: PlayerControlWidget());
  }
}
