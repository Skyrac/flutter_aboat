import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/services/hubs/live/live-session.service.dart';
import 'package:Talkaboat/services/repositories/live-session.repository.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/utils/scaffold_wave.dart';
import 'package:Talkaboat/widgets/searchbar.widget.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';

class LiveUsersBottomSheet extends StatefulWidget {
  const LiveUsersBottomSheet({super.key});

  @override
  State<LiveUsersBottomSheet> createState() => _LiveUsersBottomSheetState();
}

class _LiveUsersBottomSheetState extends State<LiveUsersBottomSheet> {
  final debouncer = Debouncer<String>(const Duration(milliseconds: 250), initialValue: "");
  final liveService = getIt<LiveSessionService>();
  final userService = getIt<UserService>();

  @override
  Widget build(BuildContext context) {
    return ScaffoldWave(
      physics: const NeverScrollableScrollPhysics(),
      appBar: AppBar(
        title: const Text("User"),
        backgroundColor: const Color.fromRGBO(29, 40, 58, 1),
      ),
      body: FutureBuilder(
          future: LiveSessionRepository.getRoom(liveService.currentSession!.guid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError || !snapshot.hasData) {
                return const Center(
                  child: Text(
                    'An error occurred',
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }
              final session = snapshot.data!;
              Future.microtask(() => liveService.setSession(session));

              final hostUsernames = session.hosts.map((x) => x.userName);
              final canAddUsers = session.configuration!.onlySuperhostCanAddHost
                  ? session.superHost == userService.userInfo!.userId
                  : !session.configuration!.onlySuperhostCanAddHost &&
                      hostUsernames.contains(userService.userInfo!.userName);
              final canRemoveUsers = session.configuration!.onlySuperhostCanRemoveHost
                  ? session.superHost == userService.userInfo!.userId
                  : !session.configuration!.onlySuperhostCanRemoveHost &&
                      hostUsernames.contains(userService.userInfo!.userName);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ListView(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    SearchBar(
                      initialSearch: "",
                      placeholder: "Search for User ...",
                      onChanged: (text, changedLanguage) {
                        debouncer.setValue(text);
                      },
                      paddingHorizontal: 0,
                      shadowColor: const Color.fromRGBO(188, 140, 75, 1.0),
                    ),
                    ...(hostUsernames.contains(userService.userInfo?.userName)
                        ? [
                            Text(
                              "Hosts Requests",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            AnimatedBuilder(
                                animation: liveService,
                                builder: ((context, child) => Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: liveService.hostRequest
                                          .map(
                                            (x) => Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 5),
                                              child: Row(children: [
                                                Text(x),
                                                const Spacer(),
                                                MaterialButton(
                                                  onPressed: () {
                                                    liveService.acceptHostRequest(x);
                                                  },
                                                  child: const Text("Accept"),
                                                ),
                                                const SizedBox(width: 5),
                                                MaterialButton(
                                                  onPressed: () {
                                                    liveService.rejectHostRequest(x);
                                                  },
                                                  child: const Text("Reject"),
                                                )
                                              ]),
                                            ),
                                          )
                                          .toList(),
                                    ))),
                          ]
                        : [
                            Center(
                              child: MaterialButton(
                                  color: const Color.fromRGBO(99, 163, 253, 1),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  onPressed: () {
                                    liveService.requestToJoin();
                                  },
                                  child: Text(
                                    "Request Session",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(color: const Color.fromRGBO(0, 0, 0, 1)),
                                  )),
                            )
                          ]),
                    Text(
                      "Hosts",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: session.hosts
                          .map(
                            (x) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(children: [
                                Text(x.userName),
                                const Spacer(),
                                x.userName != userService.userInfo!.userName && canRemoveUsers
                                    ? MaterialButton(
                                        onPressed: () {
                                          liveService.removeHost(x.userName, liveService.currentSession!.guid);
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
                      children: session.users
                          .where((x) => !hostUsernames.contains(x.userName))
                          .map(
                            (x) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(children: [
                                Text(x.userName),
                                const Spacer(),
                                /*canAddUsers
                                    ? MaterialButton(
                                        onPressed: () {
                                          liveService.addHost(x.userName, liveService.currentSession!.guid);
                                        },
                                        child: const Text("Add"),
                                      )
                                    : const SizedBox()*/
                              ]),
                            ),
                          )
                          .toList(),
                    )
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }
}
