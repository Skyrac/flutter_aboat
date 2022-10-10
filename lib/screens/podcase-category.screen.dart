import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/podcasts/podcast-category.model.dart';
import 'package:Talkaboat/models/podcasts/podcast.model.dart';
import 'package:Talkaboat/services/audio/podcast.service.dart';
import 'package:Talkaboat/widgets/podcast-favorites.widget.dart';
import 'package:Talkaboat/widgets/searchbar.widget.dart';
import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen(this.category, {Key? key}) : super(key: key);

  final PodcastCategory category;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String search = "";
  final podcastService = getIt<PodcastService>();

  @override
  Widget build(BuildContext context) {
    print("build");
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
                  child: Image(
                    image: widget.category.image,
                    fit: BoxFit.cover,
                  ),
                )
              ]),
              //leading: Icon(Icons.arrow_back_ios),
            ),
          ),
          body: FutureBuilder(
            future: podcastService.getTopPodcastByGenre(10, widget.category.genreId),
            builder: ((context, snapshot) {
              print(snapshot.connectionState);
              if (snapshot.connectionState == ConnectionState.done) {
                print("done");
                print(snapshot.hasData);
                print(snapshot.data);
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      '${snapshot.error} occurred',
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                } else if (snapshot.hasData && snapshot.data != null) {
                  // Extracting data from snapshot object
                  final data = snapshot.data as List<Podcast>?;
                  if (data != null) {
                    return buildLists(context, data);
                  }
                }
              }
              return const Center(child: CircularProgressIndicator());
            }),
          ),
        ),
      ),
    );
  }

  Widget buildLists(BuildContext context, List<Podcast> podcasts) {
    return Column(
      children: [
        SearchBar(
          placeholder: "Search in ${widget.category.name}",
          onChanged: (text) {
            setState(() {
              search = text.toLowerCase();
            });
          },
        ),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(children: [Text("Top 10", style: Theme.of(context).textTheme.titleLarge)])),
        PodcastListFavoritesWidget(
          searchResults: podcasts,
        )
      ],
    );
  }
}
