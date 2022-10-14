import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({this.placeholder, this.onChanged, this.onSubmitted, this.shadowColor, this.initialSearch, Key? key})
      : super(key: key);

  final String? placeholder;
  final void Function(String text)? onChanged;
  final void Function(String text)? onSubmitted;
  final Color? shadowColor;
  final String? initialSearch;

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _editingController.text = widget.initialSearch ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 10),
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
                    widget.onChanged!(text);
                  }
                }),
                onSubmitted: ((text) {
                  if (widget.onChanged != null) {
                    widget.onChanged!(text);
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
    );
  }
}
