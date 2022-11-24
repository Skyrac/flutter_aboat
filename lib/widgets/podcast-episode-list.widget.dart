import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/podcasts/episode.model.dart';
import 'package:Talkaboat/services/audio/audio-handler.services.dart';
import 'package:Talkaboat/services/audio/podcast.service.dart';
import 'package:Talkaboat/widgets/episode-preview.widget.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PodcastEpisodeList extends StatefulWidget {
  const PodcastEpisodeList({super.key, required this.episodes, required this.escapeWithNav, this.controller});

  final List<Episode> episodes;
  final Function escapeWithNav;
  final ScrollController? controller;

  @override
  State<PodcastEpisodeList> createState() => _PodcastEpisodeListState();
}

class _PodcastEpisodeListState extends State<PodcastEpisodeList> {
  final podcastService = getIt<PodcastService>();
  final audioPlayer = getIt<AudioPlayerHandler>();
  final PagingController<int, Episode> _pagingController = PagingController(firstPageKey: 0);

  final _pageSize = 5;

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

  Widget buildPagedEpisodes(List<Episode> data) => PagedListView<int, Episode>(
      pagingController: _pagingController,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      builderDelegate: PagedChildBuilderDelegate<Episode>(
        itemBuilder: (context, item, index) {
          return EpisodePreviewWidget(
              item, Axis.vertical, () => {selectEpisode(index, data)}, () => setState(() {}), widget.escapeWithNav);
        },
      ));

  Widget buildEpisodes(List<Episode> data) => ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          var episode = data[index];
          var episodeIndex = index;
          return EpisodePreviewWidget(episode, Axis.vertical, () => {selectEpisode(episodeIndex, data)},
              () => setState(() {}), widget.escapeWithNav);
        },
        itemCount: data.length, // 1000 list items
      );

  @override
  Widget build(BuildContext context) {
    return buildPagedEpisodes(widget.episodes);
  }
}
