import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:talkaboat/screens/settings.screen.dart';
import 'package:talkaboat/services/user/user.service.dart';

import '../injection/injector.dart';
import 'login.screen.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final userService = getIt<UserService>();

  createLoginButton() => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Card(
              child: InkWell(
                onTap: (() {
                  Navigator.push(
                      context,
                      PageTransition(
                          alignment: Alignment.bottomCenter,
                          curve: Curves.bounceOut,
                          type: PageTransitionType.fade,
                          duration: const Duration(milliseconds: 300),
                          reverseDuration: const Duration(milliseconds: 200),
                          child: LoginScreen(() => setState(() {}))));
                }),
                child: SizedBox(
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Text(
                        "Login",
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    )),
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: '',
                    onPressed: () {
                      showAlert(context);
                      return;
                      Navigator.push(
                          context,
                          PageTransition(
                              alignment: Alignment.bottomCenter,
                              curve: Curves.bounceOut,
                              type: PageTransitionType.rightToLeftWithFade,
                              duration: const Duration(milliseconds: 500),
                              reverseDuration:
                                  const Duration(milliseconds: 500),
                              child: const SettingsScreen()));
                    },
                  ),
                )
              ],
            ),
            body: userService.isConnected ? SizedBox() : createLoginButton()));
  }

  void showAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).dialogBackgroundColor,
              title: const Text("New Playlist..."),
              elevation: 8,
              content: TextField(
                  decoration: InputDecoration(
                      hintText: "Name your new Playlist",
                      labelText: "Playlist-Name",
                      labelStyle: Theme.of(context).textTheme.labelLarge,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ))),
              actions: [
                TextButton(
                    onPressed: (() {
                      print("created");
                      Navigator.pop(context);
                    }),
                    child: Text("Create")),
                TextButton(
                    onPressed: (() {
                      print("Cancelled");
                      Navigator.pop(context);
                    }),
                    child: Text("Cancel"))
              ],
            ));
  }
}
