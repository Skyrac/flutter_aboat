import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/screens/search.screen.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:flutter/material.dart';

import '../utils/scaffold_wave.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final userService = getIt<UserService>();

  @override
  Widget build(BuildContext context) {
    if(userService.currentView.label == ContentViews.Videos) {
      return ScaffoldWave(body: buildNotImplementedYet(context),
          appBar: buildAppBar());
    }
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
      appBar: buildAppBar()
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: const Color.fromRGBO(29, 40, 58, 1),
      title: const Text("Favorites"),
    );
  }

  Widget buildNotImplementedYet(BuildContext context) {
    return Column(children: [
      SizedBox(height: 66,),
      Text("Feature not yet implemented as '${userService.currentView.label.value}' is in alpha!")
    ],);
  }
}
