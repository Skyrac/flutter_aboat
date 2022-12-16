import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/live/live-session.model.dart';
import 'package:Talkaboat/screens/livestream.screen.dart';
import 'package:Talkaboat/services/hubs/live/live-session.service.dart';
import 'package:Talkaboat/services/repositories/live-session.repository.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class LiveSessionTile extends StatelessWidget {
  LiveSessionTile({super.key, required this.session, required this.escapeWithNav});

  final LiveSession session;
  final Function escapeWithNav;
  final liveService = getIt<LiveSessionService>();

  @override
  Widget build(BuildContext context) {
    final userService = getIt<UserService>();
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
              debugPrint("show livestream");
              debugPrint("$session");
              if (session.configuration!.superhostName == userService.userInfo?.userName) {
                LiveSessionRepository.closeRoom(session.guid);
              } else {
                liveService.setSession(session);
                escapeWithNav(PageTransition(
                  alignment: Alignment.bottomCenter,
                  curve: Curves.bounceOut,
                  type: PageTransitionType.fade,
                  duration: const Duration(milliseconds: 300),
                  reverseDuration: const Duration(milliseconds: 200),
                  child: LivestreamScreen(escapeWithNav: escapeWithNav),
                ));
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.configuration!.superhostName ?? "",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.labelMedium,
                      textAlign: TextAlign.left,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        session.configuration!.roomName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.left,
                      ),
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
