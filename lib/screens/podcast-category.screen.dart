import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/podcasts/podcast-genre.model.dart';
import 'package:Talkaboat/models/podcasts/podcast-rank.model.dart';
import 'package:Talkaboat/models/podcasts/podcast.model.dart';
import 'package:Talkaboat/models/search/search_result.model.dart';
import 'package:Talkaboat/screens/search.screen.dart';
import 'package:Talkaboat/services/audio/podcast.service.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/utils/scaffold_wave.dart';
import 'package:Talkaboat/widgets/podcasts/podcast-favorites.widget.dart';
import 'package:Talkaboat/widgets/podcasts/podcast-list-horizontal.widget.dart';
import 'package:Talkaboat/widgets/searchbar.widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen(this.category, {Key? key}) : super(key: key);

  final PodcastGenre category;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final podcastService = getIt<PodcastService>();
  final userService = getIt<UserService>();
  @override
  void dispose() {
    userService.selectedLanguage = null;
    ImageCache _imageCache = PaintingBinding.instance!.imageCache!;

    _imageCache.clear();

    _imageCache.clearLiveImages();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWave(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 40, 58, 1),
        title: Row(children: [
          Text(widget.category.name),
          Container(
            padding: const EdgeInsets.only(left: 5),
            height: 25,
            child: CachedNetworkImage(
                imageUrl: widget.category.imageUrl == null || widget.category.imageUrl!.isEmpty
                    ? 'https://picsum.photos/200'
                    : widget.category.imageUrl!,
                placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.cover),
          )
        ]),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: Future.wait([
            podcastService.getTopPodcastByGenre(10, widget.category.genreId),
            podcastService.search("", genre: widget.category.genreId, rank: Rank.NewComer),
            podcastService.search("", genre: widget.category.genreId, rank: Rank.Receiver),
            podcastService.search("", genre: widget.category.genreId, rank: Rank.Hodler),
          ]),
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    '${snapshot.error} occurred',
                    style: const TextStyle(fontSize: 18),
                  ),
                );
              }
              // Extracting data from snapshot object
              final allData = snapshot.data as List<List<SearchResult>>;
              final top10 = allData[0];
              final newcomers = allData[1];
              final receiver = allData[2];
              final hodler = allData[3];
              return buildLists(context, top10, newcomers, receiver, hodler);
            }
            return const Center(child: CircularProgressIndicator());
          }),
        ),
      ),
    );
  }

  Widget buildLists(
      BuildContext context, List<SearchResult> top10, List<SearchResult> newcomers, List<SearchResult> receivers, List<SearchResult> hodlers) {
    return Column(
      children: [
        SearchBar(
          placeholder: AppLocalizations.of(context)!.searchIn(widget.category.name),
          showLanguageDropdown: true,
          onChanged: (text, changedLanguage) => {
            if(changedLanguage) {
              setState(() { })
            }
          },
          onSubmitted: (text) {
            Navigator.push(
              context,
              buildSearchScreenTransition(
                  genreId: widget.category.genreId,
                  intitialValue: text,
                  imageUrl: widget.category.imageUrl,
                  title: widget.category.name),
            );
          },
        ),
        newcomers.isNotEmpty
            ? PodcastListHorizontal(
                data: newcomers,
                title: "Newcomer",
                multiplier: "x1.5",
                seeAllCb: (() {
                  Navigator.push(
                    context,
                    buildSearchScreenTransition(
                        genreId: widget.category.genreId,
                        rank: Rank.NewComer,
                        imageUrl: widget.category.imageUrl,
                        title: "Newcomer in ${widget.category.name}"),
                  );
                }),
              )
            : Container(),
        newcomers.isNotEmpty
            ? const SizedBox(
                height: 10,
              )
            : Container(),
        top10.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(children: [Text("Top 10", style: Theme.of(context).textTheme.titleLarge)]))
            : Container(),
        top10.isNotEmpty
            ? PodcastListFavoritesWidget(
                searchResults: top10,
              )
            : Container(),
        top10.isNotEmpty
            ? const SizedBox(
                height: 10,
              )
            : Container(),
        receivers.isNotEmpty
            ? PodcastListHorizontal(
                data: receivers,
                title: "Receivers",
                multiplier: "x1.25",
                seeAllCb: (() {
                  Navigator.push(
                    context,
                    buildSearchScreenTransition(
                        genreId: widget.category.genreId,
                        rank: Rank.Receiver,
                        imageUrl: widget.category.imageUrl,
                        title: "Receivers in ${widget.category.name}"),
                  );
                }),
              )
            : Container(),
        receivers.isNotEmpty
            ? const SizedBox(
                height: 10,
              )
            : Container(),
        hodlers.isNotEmpty
            ? PodcastListHorizontal(
                data: hodlers,
                title: "Hodlers",
                multiplier: "x1.1",
                seeAllCb: (() {
                  Navigator.push(
                    context,
                    buildSearchScreenTransition(
                        genreId: widget.category.genreId,
                        rank: Rank.Hodler,
                        imageUrl: widget.category.imageUrl,
                        title: "Hodlers in ${widget.category.name}"),
                  );
                }),
              )
            : Container(),
        hodlers.isNotEmpty
            ? const SizedBox(
                height: 10,
              )
            : Container(),
      ],
    );
  }
}
