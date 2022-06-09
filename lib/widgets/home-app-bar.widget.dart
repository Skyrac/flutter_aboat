import 'package:flutter/material.dart';

class HomeAppBarWidget extends StatelessWidget {
  const HomeAppBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Good morning'),
      actions: [
        Padding(
          child: Icon(Icons.settings),
          padding: EdgeInsets.only(right: 10),
        )
      ],
    );
  }
}
