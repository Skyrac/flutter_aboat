import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/live/live-session.model.dart';
import 'package:Talkaboat/screens/livestream.screen.dart';
import 'package:Talkaboat/services/live/live-session.service.dart';
import 'package:Talkaboat/utils/scaffold_wave.dart';
import 'package:Talkaboat/widgets/searchbar.widget.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class LiveUsersBottomSheet extends StatefulWidget {
  const LiveUsersBottomSheet({super.key, required this.liveSession, required this.myUid});

  final LiveSession liveSession;
  final int myUid;

  @override
  State<LiveUsersBottomSheet> createState() => _LiveUsersBottomSheetState();
}

class _LiveUsersBottomSheetState extends State<LiveUsersBottomSheet> {
  final debouncer = Debouncer<String>(const Duration(milliseconds: 250), initialValue: "");
  final liveService = getIt<LiveSessionService>();

  @override
  Widget build(BuildContext context) {
    final canAddUsers =
        (widget.liveSession.configuration!.onlySuperhostCanAddHost && widget.liveSession.superHost == widget.myUid) ||
            (!widget.liveSession.configuration!.onlySuperhostCanAddHost && widget.liveSession.hosts.contains(widget.myUid));
    final canRemoveUsers = (widget.liveSession.configuration!.onlySuperhostCanRemoveHost &&
            widget.liveSession.superHost == widget.myUid) ||
        (!widget.liveSession.configuration!.onlySuperhostCanRemoveHost && widget.liveSession.hosts.contains(widget.myUid));
    return ScaffoldWave(
      physics: const NeverScrollableScrollPhysics(),
      appBar: AppBar(
        title: const Text("User"),
        backgroundColor: const Color.fromRGBO(29, 40, 58, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView(
          children: [
            const SizedBox(
              height: 20,
            ),
            SearchBar(
              initialSearch: "",
              placeholder: "Search for User ...",
              onChanged: (text) {
                debouncer.setValue(text);
              },
              paddingHorizontal: 0,
              shadowColor: const Color.fromRGBO(188, 140, 75, 1.0),
            ),
            Center(
              child: MaterialButton(
                  color: const Color.fromRGBO(99, 163, 253, 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  onPressed: () async {
                    Future.microtask(() async {
                      final nav = Navigator.of(context);
                      nav.pop(); // this Bottom Sheet
                      nav.pop(); // LivestreamScreen
                      nav.push(PageTransition(
                        alignment: Alignment.bottomCenter,
                        curve: Curves.bounceOut,
                        type: PageTransitionType.fade,
                        duration: const Duration(milliseconds: 300),
                        reverseDuration: const Duration(milliseconds: 200),
                        child: LivestreamScreen(
                          isHost: true,
                          session: widget.liveSession,
                        ),
                      ));
                    });
                  },
                  child: Text(
                    "Join Session",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(color: const Color.fromRGBO(0, 0, 0, 1)),
                  )),
            ),
            Text(
              "Hosts",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.liveSession.hosts
                  .map(
                    (x) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(children: [
                        Text(x.toString()),
                        const Spacer(),
                        x != widget.myUid && canRemoveUsers
                            ? MaterialButton(
                                onPressed: () {
                                  liveService.removeHost(x);
                                },
                                child: const Text("Remove"),
                              )
                            : const SizedBox()
                      ]),
                    ),
                  )
                  .toList(),
            ),
            Text(
              "User",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.liveSession.users
                  .map(
                    (x) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(children: [
                        Text(x.userName),
                        const Spacer(),
                        canAddUsers
                            ? MaterialButton(
                                onPressed: () {
                                  liveService.addHost(x.hashCode);
                                },
                                child: const Text("Add"),
                              )
                            : const SizedBox()
                      ]),
                    ),
                  )
                  .toList(),
            )
          ],
        ),
      ),
    );
  }
}
