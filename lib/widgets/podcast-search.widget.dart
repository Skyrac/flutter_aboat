import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/podcasts/podcast.model.dart';
import '../services/repositories/search.repository.dart';

class PodcastSearch extends SearchDelegate<String?> {
  @override
  String get searchFieldLabel => "Enter a web address";
  final suggestions1 = ["https://www.google.com"];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }



  @override
  Widget buildSuggestions(BuildContext context) {
    return query.length <= 1 ? Container() : FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${snapshot.error} occurred',
                style: TextStyle(fontSize: 18),
              ),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            // Extracting data from snapshot object
            final data = snapshot.data as List<String>;
            if(data.isNotEmpty) {
              return ListView.builder(itemCount: data.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (BuildContext context,int index){
                    return ListTile(
                        leading: Icon(Icons.list),
                        trailing: Text(data[index],
                          style: TextStyle(
                              color: Colors.green,fontSize: 15),)
                    );
                  });
            }
          }
        }
          return Container();
      },
      future: SearchRepository.searchSuggestion(query),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    print(query);
    return SizedBox();
  }
}