import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:talkaboat/injection/injector.dart';
import 'package:talkaboat/screens/app.screen.dart';
import 'package:talkaboat/services/user/user.service.dart';
import 'package:talkaboat/themes/colors.dart';
import 'package:talkaboat/themes/default.theme.dart';

import 'configuration/dio.config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor:
          DefaultColors.primaryColor.shade900, // navigation bar color
      statusBarColor: DefaultColors.secondaryColor.shade900 // status bar color
      ));
  CachedNetworkImage.logLevel = CacheManagerLogLevel.debug;
  await configureDependencies();
  configDio();

  await getIt<UserService>().getCoreData();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: DefaultTheme.defaultTheme,
        debugShowCheckedModeBanner: false,
        home: AnimatedSplashScreen(
            duration: 2000,
            splash: const Image(
                width: 250, image: AssetImage('assets/images/talkaboat.png')),
            nextScreen: const AppScreen(title: 'Talkaboat'),
            splashTransition: SplashTransition.fadeTransition,
            pageTransitionType: PageTransitionType.fade,
            backgroundColor: DefaultColors.secondaryColor.shade900));
  }
}
//
// import 'dart:async';
//
// import 'package:audio_service/audio_service.dart';
// import 'package:flutter/material.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:talkaboat/services/audio/audio-handler.services.dart';
// import 'package:talkaboat/utils/common.dart';
//
// import 'injection/injector.dart';
//
// // You might want to provide this using dependency injection rather than a
// // global variable.
// late AudioPlayerHandler _audioHandler = getIt<AudioPlayerHandler>();
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await configureDependencies();
//   runApp(const MyApp());
// }
//
// /// The app widget
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Audio Service Demo',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const MainScreen(),
//     );
//   }
// }
//
// /// The main screen.
// class MainScreen extends StatelessWidget {
//   const MainScreen({Key? key}) : super(key: key);
//
//   Stream<Duration> get _bufferedPositionStream => _audioHandler.playbackState
//       .map((state) => state.bufferedPosition)
//       .distinct();
//   Stream<Duration?> get _durationStream =>
//       _audioHandler.mediaItem.map((item) => item?.duration).distinct();
//   Stream<PositionData> get _positionDataStream =>
//       Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
//           AudioService.position,
//           _bufferedPositionStream,
//           _durationStream,
//           (position, bufferedPosition, duration) => PositionData(
//               position, bufferedPosition, duration ?? Duration.zero));
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // MediaItem display
//             Expanded(
//               child: StreamBuilder<MediaItem?>(
//                 stream: _audioHandler.mediaItem,
//                 builder: (context, snapshot) {
//                   final mediaItem = snapshot.data;
//                   if (mediaItem == null) return const SizedBox();
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       if (mediaItem.artUri != null)
//                         Expanded(
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Center(
//                               child: Image.network('${mediaItem.artUri!}'),
//                             ),
//                           ),
//                         ),
//                       Text(mediaItem.album ?? '',
//                           style: Theme.of(context).textTheme.headline6),
//                       Text(mediaItem.title),
//                     ],
//                   );
//                 },
//               ),
//             ),
//             // Playback controls
//             ControlButtons(),
//             // A seek bar.
//             StreamBuilder<PositionData>(
//               stream: _positionDataStream,
//               builder: (context, snapshot) {
//                 final positionData = snapshot.data ??
//                     PositionData(Duration.zero, Duration.zero, Duration.zero);
//                 return SeekBar(
//                   duration: positionData.duration,
//                   position: positionData.position,
//                   onChangeEnd: (newPosition) {
//                     _audioHandler.seek(newPosition);
//                   },
//                 );
//               },
//             ),
//             const SizedBox(height: 8.0),
//             // Repeat/shuffle controls
//             Row(
//               children: [
//                 StreamBuilder<AudioServiceRepeatMode>(
//                   stream: _audioHandler.playbackState
//                       .map((state) => state.repeatMode)
//                       .distinct(),
//                   builder: (context, snapshot) {
//                     final repeatMode =
//                         snapshot.data ?? AudioServiceRepeatMode.none;
//                     const icons = [
//                       Icon(Icons.repeat, color: Colors.grey),
//                       Icon(Icons.repeat, color: Colors.orange),
//                       Icon(Icons.repeat_one, color: Colors.orange),
//                     ];
//                     const cycleModes = [
//                       AudioServiceRepeatMode.none,
//                       AudioServiceRepeatMode.all,
//                       AudioServiceRepeatMode.one,
//                     ];
//                     final index = cycleModes.indexOf(repeatMode);
//                     return IconButton(
//                       icon: icons[index],
//                       onPressed: () {
//                         _audioHandler.setRepeatMode(cycleModes[
//                             (cycleModes.indexOf(repeatMode) + 1) %
//                                 cycleModes.length]);
//                       },
//                     );
//                   },
//                 ),
//                 Expanded(
//                   child: Text(
//                     "Playlist",
//                     style: Theme.of(context).textTheme.headline6,
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//                 StreamBuilder<bool>(
//                   stream: _audioHandler.playbackState
//                       .map((state) =>
//                           state.shuffleMode == AudioServiceShuffleMode.all)
//                       .distinct(),
//                   builder: (context, snapshot) {
//                     final shuffleModeEnabled = snapshot.data ?? false;
//                     return IconButton(
//                       icon: shuffleModeEnabled
//                           ? const Icon(Icons.shuffle, color: Colors.orange)
//                           : const Icon(Icons.shuffle, color: Colors.grey),
//                       onPressed: () async {
//                         final enable = !shuffleModeEnabled;
//                         await _audioHandler.setShuffleMode(enable
//                             ? AudioServiceShuffleMode.all
//                             : AudioServiceShuffleMode.none);
//                       },
//                     );
//                   },
//                 ),
//               ],
//             ),
//             // Playlist
//             SizedBox(
//               height: 240.0,
//               child: StreamBuilder<QueueState>(
//                 stream: _audioHandler.queueState,
//                 builder: (context, snapshot) {
//                   final queueState = snapshot.data ?? QueueState.empty;
//                   final queue = queueState.queue;
//                   return ReorderableListView(
//                     onReorder: (int oldIndex, int newIndex) {
//                       if (oldIndex < newIndex) newIndex--;
//                       _audioHandler.moveQueueItem(oldIndex, newIndex);
//                     },
//                     children: [
//                       for (var i = 0; i < queue.length; i++)
//                         Dismissible(
//                           key: ValueKey(queue[i].id),
//                           background: Container(
//                             color: Colors.redAccent,
//                             alignment: Alignment.centerRight,
//                             child: const Padding(
//                               padding: EdgeInsets.only(right: 8.0),
//                               child: Icon(Icons.delete, color: Colors.white),
//                             ),
//                           ),
//                           onDismissed: (dismissDirection) {
//                             _audioHandler.removeQueueItemAt(i);
//                           },
//                           child: Material(
//                             color: i == queueState.queueIndex
//                                 ? Colors.grey.shade300
//                                 : null,
//                             child: ListTile(
//                               title: Text(queue[i].title),
//                               onTap: () => _audioHandler.skipToQueueItem(i),
//                             ),
//                           ),
//                         ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class ControlButtons extends StatelessWidget {
//   late AudioPlayerHandler audioHandler = getIt<AudioPlayerHandler>();
//
//   ControlButtons({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         IconButton(
//           icon: const Icon(Icons.volume_up),
//           onPressed: () {
//             showSliderDialog(
//               context: context,
//               title: "Adjust volume",
//               divisions: 10,
//               min: 0.0,
//               max: 1.0,
//               value: audioHandler.volume.value,
//               stream: audioHandler.volume,
//               onChanged: audioHandler.setVolume,
//             );
//           },
//         ),
//         StreamBuilder<QueueState>(
//           stream: audioHandler.queueState,
//           builder: (context, snapshot) {
//             final queueState = snapshot.data ?? QueueState.empty;
//             return IconButton(
//               icon: const Icon(Icons.skip_previous),
//               onPressed:
//                   queueState.hasPrevious ? audioHandler.skipToPrevious : null,
//             );
//           },
//         ),
//         StreamBuilder<PlaybackState>(
//           stream: audioHandler.playbackState,
//           builder: (context, snapshot) {
//             final playbackState = snapshot.data;
//             final processingState = playbackState?.processingState;
//             final playing = playbackState?.playing;
//             if (processingState == AudioProcessingState.loading ||
//                 processingState == AudioProcessingState.buffering) {
//               return Container(
//                 margin: const EdgeInsets.all(8.0),
//                 width: 64.0,
//                 height: 64.0,
//                 child: const CircularProgressIndicator(),
//               );
//             } else if (playing != true) {
//               return IconButton(
//                 icon: const Icon(Icons.play_arrow),
//                 iconSize: 64.0,
//                 onPressed: audioHandler.play,
//               );
//             } else {
//               return IconButton(
//                 icon: const Icon(Icons.pause),
//                 iconSize: 64.0,
//                 onPressed: audioHandler.pause,
//               );
//             }
//           },
//         ),
//         StreamBuilder<QueueState>(
//           stream: audioHandler.queueState,
//           builder: (context, snapshot) {
//             final queueState = snapshot.data ?? QueueState.empty;
//             return IconButton(
//               icon: const Icon(Icons.skip_next),
//               onPressed: queueState.hasNext ? audioHandler.skipToNext : null,
//             );
//           },
//         ),
//         StreamBuilder<double>(
//           stream: audioHandler.speed,
//           builder: (context, snapshot) => IconButton(
//             icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
//                 style: const TextStyle(fontWeight: FontWeight.bold)),
//             onPressed: () {
//               showSliderDialog(
//                 context: context,
//                 title: "Adjust speed",
//                 divisions: 10,
//                 min: 0.5,
//                 max: 1.5,
//                 value: audioHandler.speed.value,
//                 stream: audioHandler.speed,
//                 onChanged: audioHandler.setSpeed,
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
