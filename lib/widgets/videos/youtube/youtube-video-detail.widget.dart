import 'package:Talkaboat/models/videos/youtube/youtube-video-simple.model.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/utils/scaffold_wave.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../injection/injector.dart';

class YouTubeVideoDetailScreen extends StatefulWidget {
  const YouTubeVideoDetailScreen({Key? key, required this.youTubeVideo}) : super(key: key);

  final YoutubeVideoSimple youTubeVideo;
  @override
  State<YouTubeVideoDetailScreen> createState() => _YouTubeVideoDetailScreenState();
}

class _YouTubeVideoDetailScreenState extends State<YouTubeVideoDetailScreen> {
  late YoutubePlayerController _controller;
  bool _showComments = false;
  final userService = getIt<UserService>();

  void _toggleComments() {
    setState(() {
      _showComments = !_showComments;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.youTubeVideo.id,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        // The player forces portraitUp after exiting fullscreen. This overrides the behaviour.
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      player:  YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
        onReady: () {
          print('Player is ready.');
        },
      ),
      builder: (context, player) =>  ScaffoldWave(
          height: 33,
          appBar: AppBar(
            centerTitle: false,
            leadingWidth: 35,
            titleSpacing: 3,
            backgroundColor: const Color.fromRGBO(29, 40, 58, 1),
            title: Text(
              widget.youTubeVideo.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color.fromRGBO(99, 163, 253, 1),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: IconButton(
                    icon: const Icon(Icons.share, color: Color.fromRGBO(99, 163, 253, 0.5), size: 36),
                    tooltip: '',
                    onPressed: () => {
                      //TODO: Geräte Abhängigkeit prüfen
                      Share.share(AppLocalizations.of(context)!.share(widget.youTubeVideo.title),
                          subject: AppLocalizations.of(context)!.share2)
                    }),
              ),
            ],
          ),
          body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 66),
          player,
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.youTubeVideo.title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  '${widget.youTubeVideo.author} • ${widget.youTubeVideo.duration}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                SizedBox(height: 16),
                InkWell(
                  onTap: _toggleComments,
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble_outline, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Comments',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                _showComments ? _buildCommentsSection() : SizedBox.shrink(),
              ],
            ),
          ),
        ],
      )),
    );
  }
  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '2 comments',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        _buildComment('User 1', 'This is a comment by user 1.'),
        _buildComment('User 2', 'This is a comment by user 2.'),
      ],
    );
  }

  Widget _buildComment(String author, String commentText) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            author,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(commentText),
        ],
      ),
    );
  }
}
