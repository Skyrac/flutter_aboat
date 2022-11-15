import 'package:Talkaboat/models/live/live-session.model.dart';
import 'package:flutter/material.dart';

class LiveSessionTile extends StatelessWidget {
  const LiveSessionTile({super.key, required this.session});

  final LiveSession session;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        color: const Color.fromRGBO(29, 40, 58, 1.0),
        height: 60,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () async {
              print("show livestream");
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Column(
                  children: [
                    Text(
                      session.configuration!.roomName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.labelMedium,
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      session.configuration!.roomName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                const Spacer(),
                const Text(
                  "|",
                  overflow: TextOverflow.clip,
                  maxLines: 1,
                  style: TextStyle(color: Color.fromARGB(255, 99, 163, 253), fontWeight: FontWeight.w600, fontSize: 20),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10), child: Image.asset("assets/images/arrow-right.png"))
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
