import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/podcasts/podcast-genre.model.dart';
import 'package:Talkaboat/screens/podcast-category.screen.dart';
import 'package:Talkaboat/services/audio/podcast.service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class HomeScreenCategoriesTab extends StatefulWidget {
  const HomeScreenCategoriesTab({Key? key}) : super(key: key);

  @override
  State<HomeScreenCategoriesTab> createState() => _HomeScreenCategoriesTabState();
}

class _HomeScreenCategoriesTabState extends State<HomeScreenCategoriesTab> {
  final podcastService = getIt<PodcastService>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        buildSearchField(context),
        FutureBuilder(
          future: podcastService.getGenres(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    '${snapshot.error} occurred',
                    style: const TextStyle(fontSize: 18),
                  ),
                );
              } else if (snapshot.hasData && snapshot.data != null) {
                return buildCategoryList(context, snapshot.data!);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ]),
    );
  }

  String search = '';

  Widget buildSearchField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: const BoxDecoration(
              color: Color.fromRGBO(29, 40, 58, 1.0),
              border: Border(bottom: BorderSide(width: 2, color: Color.fromRGBO(188, 140, 75, 1.0)))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: TextField(
                onChanged: ((text) {
                  setState(() {
                    search = text.toLowerCase();
                  });
                }),
                decoration: const InputDecoration(
                    border: InputBorder.none, hintText: "Search for category...", suffixIcon: Icon(Icons.search)),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCategoryList(BuildContext context, List<PodcastGenre> data) {
    var filteredItems = data.where((element) => search == '' || element.name.toLowerCase().contains(search)).toList();

    return GridView.count(
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      shrinkWrap: true,
      crossAxisCount: 2,
      semanticChildCount: data.length,
      childAspectRatio: 170 / 70,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(filteredItems.length, (index) {
        final item = filteredItems[index];
        return makeCard(context, item, index);
      }),
    );
  }

  Widget makeCard(BuildContext context, PodcastGenre category, int index) {
    return SizedBox(
      width: 170,
      height: 70,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: const Color.fromRGBO(29, 40, 58, 1.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () async {
                await Navigator.of(context).push(PageTransition(
                    alignment: Alignment.bottomCenter,
                    curve: Curves.bounceOut,
                    type: PageTransitionType.rightToLeftWithFade,
                    duration: const Duration(milliseconds: 500),
                    reverseDuration: const Duration(milliseconds: 500),
                    child: CategoryScreen(category)));
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Center(
                      child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CachedNetworkImage(
                        imageUrl: category.imageUrl == null || category.imageUrl!.isEmpty
                            ? 'https://picsum.photos/200'
                            : category.imageUrl!,
                        placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                        fit: BoxFit.cover),
                  )),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          category.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.labelLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
