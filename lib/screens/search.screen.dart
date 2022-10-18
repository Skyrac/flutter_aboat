import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/podcasts/podcast-rank.model.dart';
import 'package:Talkaboat/models/podcasts/podcast.model.dart';
import 'package:Talkaboat/services/audio/podcast.service.dart';
import 'package:Talkaboat/utils/scaffold_wave.dart';
import 'package:Talkaboat/widgets/podcast-list-tile.widget.dart';
import 'package:Talkaboat/widgets/searchbar.widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:page_transition/page_transition.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({this.appBar, this.onlyGenre, this.initialValue, this.onlyRank, Key? key}) : super(key: key);

  final AppBar? appBar;
  final int? onlyGenre;
  final PodcastRank? onlyRank;
  final String? initialValue;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final podcastService = getIt<PodcastService>();
  final debouncer = Debouncer<String>(const Duration(milliseconds: 250), initialValue: "");

  static const _pageSize = 20;

  final PagingController<int, Podcast> _pagingController = PagingController(firstPageKey: 0);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
    debouncer.setValue(widget.initialValue ?? "");
    debouncer.values.listen((val) {
      _pagingController.refresh();
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await podcastService.search(debouncer.value,
          amount: _pageSize, offset: pageKey, genre: widget.onlyGenre, rank: widget.onlyRank);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      print(error);
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWave(
      appBar: widget.appBar ?? buildAppbar(),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SearchBar(
            initialSearch: widget.initialValue,
            placeholder: "",
            onChanged: (text) {
              debouncer.setValue(text);
            },
            shadowColor: const Color.fromRGBO(99, 163, 253, 1.0),
          ),
          Flexible(
            flex: 1,
            child: PagedListView<int, Podcast>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<Podcast>(
                itemBuilder: (context, item, index) => Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: PodcastListTileWidget(item),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  AppBar buildAppbar() {
    return AppBar(
      backgroundColor: const Color.fromRGBO(29, 40, 58, 1),
      title: const Text("Search"),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}

PageTransition buildSearchScreenTransition(
    {String? intitialValue, int? genreId, PodcastRank? rank, String? title, String? imageUrl}) {
  return PageTransition(
    alignment: Alignment.bottomCenter,
    curve: Curves.bounceOut,
    type: PageTransitionType.fade,
    duration: const Duration(milliseconds: 300),
    reverseDuration: const Duration(milliseconds: 200),
    child: SearchScreen(
      onlyGenre: genreId,
      onlyRank: rank,
      initialValue: intitialValue,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 40, 58, 1),
        title: Row(children: [
          Text(title ?? ""),
          Container(
            padding: const EdgeInsets.only(left: 5),
            height: 25,
            child: CachedNetworkImage(
                imageUrl: imageUrl == null || imageUrl.isEmpty ? 'https://picsum.photos/200' : imageUrl,
                placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.cover),
          )
        ]),
      ),
    ),
  );
}
