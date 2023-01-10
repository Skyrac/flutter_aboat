import 'dart:math';

import 'package:Talkaboat/agora-example.dart';
import 'package:flutter/material.dart';

class Agora extends StatefulWidget {
  const Agora({super.key});

  @override
  State<Agora> createState() => _AgoraState();
}

class _AgoraState extends State<Agora> {
  @override
  Widget build(BuildContext context) {
    var rng = Random();
    return Scaffold(
        appBar: AppBar(title: const Text("Agora")),
        body: Column(
          children: [
            MaterialButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => AgoraExample(isHost: false, id: rng.nextInt(10000))));
                },
                child: const Text("Viewer")),
            MaterialButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => AgoraExample(isHost: true, id: rng.nextInt(10000))));
                },
                child: const Text("Broadcaster"))
          ],
        ));
  }
}
