import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/podcasts/podcast.model.dart';
import 'package:Talkaboat/services/audio/podcast.service.dart';
import 'package:Talkaboat/widgets/podcast-list-tile.widget.dart';
import 'package:Talkaboat/widgets/podcast-list.widget.dart';
import 'package:Talkaboat/widgets/searchbar.widget.dart';
import 'package:Talkaboat/widgets/infinite-scrolling-list.widget.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({this.appBar, this.onlyGenre, Key? key}) : super(key: key);

  final AppBar? appBar;
  final int? onlyGenre;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final podcastService = getIt<PodcastService>();
  final debouncer = Debouncer<String>(const Duration(milliseconds: 200), initialValue: "");

  @override
  void initState() {
    super.initState();
    debouncer.setValue("");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(color: Color.fromRGBO(15, 23, 41, 1.0)),
        child: Scaffold(
          appBar: widget.appBar ?? buildAppbar(),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SearchBar(
                placeholder: "",
                onChanged: (text) {
                  print(text);
                  debouncer.setValue(text);
                },
              ),
              StreamBuilder(
                stream: debouncer.values,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active && snapshot.hasData) {
                    print("stream");
                    print(snapshot.data);
                    return InfiniteScrollingList<Podcast>(
                      fetch: ((amount, offset) {
                        return podcastService.search(snapshot.data! as String, amount: amount, offset: offset);
                      }),
                      builder: (context, item) {
                        return Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Stack(children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: PodcastListTileWidget(item),
                              ),
                            ]));
                      },
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  AppBar buildAppbar() {
    return AppBar();
  }
}
