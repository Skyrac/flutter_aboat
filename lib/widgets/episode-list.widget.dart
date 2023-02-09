import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/podcasts/episode.model.dart';
import 'package:Talkaboat/services/audio/audio-handler.services.dart';
import 'package:Talkaboat/services/audio/podcast.service.dart';
import 'package:Talkaboat/widgets/episode-preview.widget.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class EpisodeList extends StatefulWidget {
  const EpisodeList({super.key, required this.episodes, this.controller});

  final List<Episode> episodes;
  final ScrollController? controller;

  @override
  State<EpisodeList> createState() => _EpisodeListState();
}

class _EpisodeListState extends State<EpisodeList> {
  final podcastService = getIt<PodcastService>();
  final audioPlayer = getIt<AudioPlayerHandler>();
  final PagingController<int, Episode> _pagingController = PagingController(firstPageKey: 0);

  final _pageSize = 10;

  int currentItems = 0;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      debugPrint("fetch2 $pageKey");
      final newItems = widget.episodes.skip(pageKey).take(_pageSize).toList();
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      debugPrint("$error");
      _pagingController.error = error;
    }
  }

  selectEpisode(int index, List<Episode> data) async {
    var selectedEpisode = data[index];
    if (audioPlayer.isListeningEpisode(selectedEpisode.episodeId)) {
      audioPlayer.togglePlaybackState();
    } else {
      await audioPlayer.updateEpisodeQueue(data, index: index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, Episode>(
        pagingController: _pagingController,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        builderDelegate: PagedChildBuilderDelegate<Episode>(
          itemBuilder: (context, item, index) {
            return EpisodePreviewWidget(
                item, Axis.vertical, () => {selectEpisode(index, widget.episodes)}, () => setState(() {}));
          },
        ));
  }
}
