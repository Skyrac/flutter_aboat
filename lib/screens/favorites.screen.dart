import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/screens/search.screen.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/common.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final userService = getIt<UserService>();

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      Provider.of<SelectEpisodePage>(context, listen: false).changeFalse();
    });
    userService.SetLastFavoritesNotifcationUpdate();
    return SearchScreen(
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
