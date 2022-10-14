import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/podcasts/podcast-genre.model.dart';
import 'package:Talkaboat/models/podcasts/podcast.model.dart';
import 'package:Talkaboat/screens/search.screen.dart';
import 'package:Talkaboat/services/audio/podcast.service.dart';
import 'package:Talkaboat/services/repositories/podcast.repository.dart';
import 'package:Talkaboat/widgets/podcast-favorites.widget.dart';
import 'package:Talkaboat/widgets/podcast-list.widget.dart';
import 'package:Talkaboat/widgets/searchbar.widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen(this.category, {Key? key}) : super(key: key);

  final PodcastGenre category;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final podcastService = getIt<PodcastService>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(color: Color.fromRGBO(15, 23, 41, 1.0)),
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(155 - 56),
            child: AppBar(
              backgroundColor: const Color.fromRGBO(29, 40, 58, 1),
              flexibleSpace: Container(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  width: MediaQuery.of(context).size.width,
                  "assets/images/wave.png",
                  fit: BoxFit.cover,
                ),
              ),
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
              //leading: Icon(Icons.arrow_back_ios),
            ),
          ),
          body: SingleChildScrollView(
            child: FutureBuilder(
              future: Future.wait([
                podcastService.getTopPodcastByGenre(10, widget.category.genreId),
                PodcastRepository.getRandomPodcast(10)
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
                  final allData = snapshot.data as List<List<Podcast>>;
                  final top10 = allData[0];
                  final newcomers = allData[1];
                  return buildLists(context, top10, newcomers);
                }
                return const Center(child: CircularProgressIndicator());
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLists(BuildContext context, List<Podcast> top10, List<Podcast> newcomers) {
    return Column(
      children: [
        SearchBar(
          placeholder: "Search in ${widget.category.name}",
          onSubmitted: (text) {
            Navigator.push(
              context,
              PageTransition(
                alignment: Alignment.bottomCenter,
                curve: Curves.bounceOut,
                type: PageTransitionType.fade,
                duration: const Duration(milliseconds: 300),
                reverseDuration: const Duration(milliseconds: 200),
                child: SearchScreen(
                  onlyGenre: widget.category.genreId,
                  initialValue: text,
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
                ),
              ),
            );
          },
        ),
        newcomers.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(10),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text("Newcomers", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(
                    width: 10,
                  ),
                  const Image(
                    image: AssetImage("assets/icons/icon_fire.png"),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  // TODO: bottom align this text
                  Text("Reward x1.5", style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: (() {
                            // TODO: navigate to full list
                            print("blab");
                          }),
                          child: Row(children: [
                            Text(
                              "See All",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const Icon(Icons.arrow_right_alt)
                          ])))
                ]))
            : Container(),
        newcomers.isNotEmpty
            ? SizedBox(
                height: 150,
                child: PodcastListWidget(searchResults: newcomers, direction: Axis.horizontal),
              )
            : Container(),
        const SizedBox(
          height: 10,
        ),
        top10.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(children: [Text("Top 10", style: Theme.of(context).textTheme.titleLarge)]))
            : Container(),
        top10.isNotEmpty
            ? PodcastListFavoritesWidget(
                searchResults: top10,
              )
            : Container()
      ],
    );
  }
}
