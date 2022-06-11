import 'package:flutter/material.dart';

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
    final suggestions = query.isEmpty ? suggestions1 : [];
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (content, index) => ListTile(
          leading: Icon(Icons.arrow_left), title: Text(suggestions[index])),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return SizedBox();
  }
}