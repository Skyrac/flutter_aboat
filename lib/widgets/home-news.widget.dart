import 'package:Talkaboat/themes/colors_new.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tweet_ui/embedded_tweet_view.dart';
import 'package:tweet_ui/models/api/v2/tweet_v2.dart';
import 'package:tweet_ui/models/viewmodels/tweet_vm.dart';

import '../injection/injector.dart';
import '../services/user/user.service.dart';

class HomeNewsScreenWidget extends StatefulWidget {
  const HomeNewsScreenWidget({Key? key}) : super(key: key);

  @override
  State<HomeNewsScreenWidget> createState() => _HomeNewsScreenWidgetState();
}

class _HomeNewsScreenWidgetState extends State<HomeNewsScreenWidget> {
  final userService = getIt<UserService>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        FutureBuilder(
          future: userService.getNews(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    '${snapshot.error} occurred',
                    style: const TextStyle(fontSize: 18),
                  ),
                );
              } else if (snapshot.hasData && snapshot.data != null) {
                return Column(children: List.generate(snapshot.data!.length, (index){
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: EmbeddedTweetView.fromTweetV2(snapshot.data![index],
                      backgroundColor: NewDefaultColors.secondaryColor.shade700,
                      darkMode: true,
                      videoHighQuality: false,
                        createdDateDisplayFormat: DateFormat("EEE, MMM d, ''yy")
                    ),
                  );
                }));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ]),
    );
  }
}
