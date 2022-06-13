import 'package:flutter/material.dart';

import '../widgets/podcast-search.widget.dart';

class SearchAndFilterScreen extends StatefulWidget {
  const SearchAndFilterScreen({Key? key}) : super(key: key);

  @override
  State<SearchAndFilterScreen> createState() => _SearchAndFilterScreenState();
}

class _SearchAndFilterScreenState extends State<SearchAndFilterScreen> {
  final _controller = TextEditingController();
  PodcastSearch? search = null;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    print("deactivate");
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search and Filter'),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: _controller,
            onTap: () {
              search = PodcastSearch();
              // placeholder for our places search later
              showSearch(
                context: context,
                // we haven't created AddressSearch class
                // this should be extending SearchDelegate
                delegate: search!,
              );
            },
            // with some styling
            decoration: InputDecoration(
              icon: Container(
                margin: EdgeInsets.only(left: 20),
                width: 10,
                height: 10,
                child: Icon(
                  Icons.home,
                ),
              ),
              hintText: "Search podcasts...",
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(left: 8.0, top: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}
