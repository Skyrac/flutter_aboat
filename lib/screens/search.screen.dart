import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/podcasts/podcast.model.dart';
import 'package:Talkaboat/services/audio/podcast.service.dart';
import 'package:Talkaboat/widgets/podcast-list.widget.dart';
import 'package:Talkaboat/widgets/searchbar.widget.dart';
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
          body: SingleChildScrollView(
            child: Column(
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
                      return FutureBuilder(
                        future: podcastService.search(
                          snapshot.data! as String,
                        ),
                        builder: (context, snapshot) {
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
                            }
                            // Extracting data from snapshot object
                            final data = snapshot.data as List<Podcast>;
                            return SizedBox(
                                height: 1000,
                                child: PodcastListWidget(
                                  searchResults: data,
                                  direction: Axis.vertical,
                                  scrollPhysics: const NeverScrollableScrollPhysics(),
                                ));
                          }
                          return const Center(child: CircularProgressIndicator());
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
      ),
    );
  }

  AppBar buildAppbar() {
    return AppBar();
  }
}
