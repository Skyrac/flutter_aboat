import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/screens/search.screen.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key, required this.escapeWithNav}) : super(key: key);

  final Function escapeWithNav;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final userService = getIt<UserService>();

  @override
  Widget build(BuildContext context) {
    return SearchScreen(
      escapeWithNav: widget.escapeWithNav,
      customSearchFunc: ((text, amount, offset) async {
        return Future.value((await userService.getFavorites())
            .where((element) => element.title?.contains(text) ?? false)
            .skip(offset)
            .take(amount)
            .toList());
      }),
      refreshOnStateChange: true,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 40, 58, 1),
        title: const Text("Favorites"),
      ),
    );
  }
}
