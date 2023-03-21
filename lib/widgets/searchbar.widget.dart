import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/themes/colors_new.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../injection/injector.dart';
import '../services/audio/podcast.service.dart';

class SearchBar extends StatefulWidget {
  const SearchBar(
      {this.paddingHorizontal,
      this.placeholder,
      this.onChanged,
      this.onSubmitted,
      this.shadowColor,
      this.initialSearch,
        this.showLanguageDropdown,
      Key? key})
      : super(key: key);

  final String? placeholder;
  final void Function(String text, bool changedLanguage)? onChanged;
  final void Function(String text)? onSubmitted;
  final Color? shadowColor;
  final String? initialSearch;
  final double? paddingHorizontal;
  final bool? showLanguageDropdown;

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class LanguageModel {
  LanguageModel({required this.Name, required this.Value}) {}

  final String Name;
  final String? Value;


}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _editingController = TextEditingController();
  final podcastService = getIt<PodcastService>();
  final userService = getIt<UserService>();
  late List<LanguageModel> list = List.empty();
  LanguageModel? dropdownValue;
  @override
  void initState() {
    super.initState();
    _editingController.text = widget.initialSearch ?? "";
  }

  @override
  Widget build(BuildContext context) {
    if(list.length == 0) {
      list = <LanguageModel>[
        LanguageModel(Name: AppLocalizations.of(context)!.defaultLanguage, Value: null),
        LanguageModel(Name: AppLocalizations.of(context)!.de, Value: "de"),
        LanguageModel(Name: AppLocalizations.of(context)!.en, Value: "en"),
        LanguageModel(Name: AppLocalizations.of(context)!.fr, Value: "fr"),
        LanguageModel(Name: AppLocalizations.of(context)!.es, Value: "es")
      ];
      switch(userService.selectedLanguage) {
        case "de": dropdownValue = list[1]; break;
        case "en": dropdownValue = list[2]; break;
        case "fr": dropdownValue = list[3]; break;
        case "es": dropdownValue = list[4]; break;
        default: dropdownValue = list[0]; break;
      }
    }
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.paddingHorizontal ?? 70, vertical: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                  color: const Color.fromRGBO(29, 40, 58, 1.0),
                  border: Border(
                      bottom: BorderSide(width: 2, color: widget.shadowColor ?? const Color.fromRGBO(188, 140, 75, 1.0)))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Center(
                  child: TextField(
                    controller: _editingController,
                    onChanged: ((text) {
                      if (widget.onChanged != null) {
                        widget.onChanged!(text, false);
                      }
                    }),
                    onSubmitted: ((text) {
                      if (widget.onChanged != null) {
                        widget.onChanged!(text, false);
                      }
                      if (widget.onSubmitted != null) {
                        widget.onSubmitted!(text);
                      }
                    }),
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: widget.placeholder, suffixIcon: const Icon(Icons.search)),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
            ),
          ),
        ),
        getLanguageDropdown(context)
      ],
    );
  }

  Widget getLanguageDropdown(BuildContext context) {
    final showLanguageWidget = widget.showLanguageDropdown != null && widget.showLanguageDropdown!;
    if(!showLanguageWidget) {
      return Container();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Language"),
          SizedBox(width: 20),
          DropdownButton<LanguageModel>(
            value: dropdownValue,
            icon: const Icon(
                Icons.arrow_downward, color: NewDefaultColors.primaryColorBase),
            elevation: 16,
            style: const TextStyle(color: NewDefaultColors.primaryColorBase),
            underline: Container(
              height: 2,
              color: NewDefaultColors.primaryColorBase,
            ),
            onChanged: (LanguageModel? selectedLanguage) {
              // This is called when the user selects an item.

              userService.selectedLanguage = selectedLanguage?.Value;
              if (widget.onChanged != null) {
                widget.onChanged!(_editingController.text, true);
              }
              setState(() {
                dropdownValue = selectedLanguage!;
              });
            },
            items: list.map<DropdownMenuItem<LanguageModel>>((
                LanguageModel value) {
              return DropdownMenuItem<LanguageModel>(
                value: value,
                child: Text(value.Name),
              );
            }).toList(),
          )
      ],
    );
  }
}
