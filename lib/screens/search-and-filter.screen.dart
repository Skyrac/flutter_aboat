import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:talkaboat/themes/colors.dart';
import 'package:talkaboat/utils/podcast-languages.const.dart';

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
          Padding(
            padding: const EdgeInsets.all(20),
            child: InkWell(
              onTap: (() {
                search = PodcastSearch();
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
                    SizedBox(
                      width: 20,
                    ),
                    Text("Start search...")
                  ],
                ),
              ),
            ),
          ),
          Divider(
              height: 60,
              thickness: 5,
              indent: 20,
              endIndent: 20,
              color: Colors.blueGrey),
          Text(
            "Filter",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: DropdownSearch<String>.multiSelection(
                items: podcastLanguages,
                clearButtonProps: ClearButtonProps(isVisible: true),
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: 'Languages',
                    filled: true,
                    fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  ),
                ),
                validator: (List<String>? items) {
                  if (items == null || items.isEmpty)
                    return 'required filed';
                  else if (items.length > 3)
                    return 'only 1 to 3 items are allowed';
                  return null;
                },
                dropdownButtonProps: DropdownButtonProps(isVisible: true),
                dropdownBuilder: multiSelectedUsers,
                popupProps: PopupPropsMultiSelection.dialog(
                    showSearchBox: true,
                    showSelectedItems: true,
                    searchFieldProps: TextFieldProps(
                        decoration:
                            InputDecoration(hintText: "Search Language"))),
                onChanged: print,
              ),
            ),
          )
        ],
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
