import 'package:flutter/material.dart';

import '../themes/colors.dart';
import '../widgets/podcast-search.widget.dart';

class SearchAndFilterScreen extends StatefulWidget {
  const SearchAndFilterScreen({this.appBar, this.onlyGenre, Key? key}) : super(key: key);

  final AppBar? appBar;
  final int? onlyGenre;

  @override
  State<SearchAndFilterScreen> createState() => _SearchAndFilterScreenState();
}

class _SearchAndFilterScreenState extends State<SearchAndFilterScreen> {
  final _controller = TextEditingController();
  PodcastSearch? search;
  List<String> selectedLanguages = [];
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(color: Color.fromRGBO(15, 23, 41, 1.0)),
        child: Scaffold(
          appBar: widget.appBar ??
              AppBar(
                title: const Text('Search and Filter'),
              ),
          body: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20),
                child: InkWell(
                  onTap: (() {
                    search = PodcastSearch(selectedLanguages: selectedLanguages, genreIds: []);
                    // placeholder for our places search later
                    showSearch(
                      context: context,
                      // we haven't created AddressSearch class
                      // this should be extending SearchDelegate
                      delegate: search!,
                    );
                  }),
                  child: SizedBox(
                    height: 60,
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: DefaultColors.primaryColor,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        const Text("Start search...")
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(height: 60, thickness: 5, indent: 20, endIndent: 20, color: Colors.blueGrey),
              Text(
                "Filter",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              // Padding(
              //   padding: const EdgeInsets.all(20),
              //   child: ClipRRect(
              //     borderRadius: BorderRadius.circular(10),
              //     child: DropdownSearch<String>.multiSelection(
              //       items: podcastLanguages,
              //       selectedItems: selectedLanguages,
              //       clearButtonProps: ClearButtonProps(isVisible: true),
              //       dropdownDecoratorProps: DropDownDecoratorProps(
              //         dropdownSearchDecoration: InputDecoration(
              //           labelText: 'Languages',
              //           filled: true,
              //           fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              //         ),
              //       ),
              //       dropdownButtonProps: DropdownButtonProps(isVisible: true),
              //       dropdownBuilder: multiSelectedUsers,
              //       popupProps: PopupPropsMultiSelection.dialog(
              //           showSearchBox: true,
              //           showSelectedItems: true,
              //           searchFieldProps: TextFieldProps(
              //               decoration:
              //                   InputDecoration(hintText: "Search Language"))),
              //       onChanged: ((items) {
              //         selectedLanguages = items;
              //       }),
              //     ),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }

  Widget multiSelectedUsers(BuildContext context, List<String?> selectedItems) {
    return Wrap(
      children: selectedItems.map((e) {
        return Card(
          child: InkWell(
            onTap: (() {
              selectedItems.remove(e);
              selectedLanguages.remove(e);
              setState(() {});
            }),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                e!,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
