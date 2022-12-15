import 'dart:math';

import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/live/live-session.model.dart';
import 'package:Talkaboat/screens/livestream.screen.dart';
import 'package:Talkaboat/services/hubs/live/live-session.service.dart';
import 'package:Talkaboat/services/repositories/live-session.repository.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/utils/scaffold_wave.dart';
import 'package:Talkaboat/widgets/home-app-bar.widget.dart';
import 'package:Talkaboat/widgets/livesessiontile.widget.dart';
import 'package:Talkaboat/widgets/searchbar.widget.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:page_transition/page_transition.dart';

class LivestreamOverviewScreen extends StatefulWidget {
  const LivestreamOverviewScreen(this.escapeWithNav, {Key? key}) : super(key: key);
  final Function escapeWithNav;

  @override
  State<LivestreamOverviewScreen> createState() => _LivestreamOverviewScreenState();
}

class _LivestreamOverviewScreenState extends State<LivestreamOverviewScreen> {
  refresh() {
    setState(() {});
  }

  final liveSessionService = getIt<LiveSessionService>();
  final debouncer = Debouncer<String>(const Duration(milliseconds: 250), initialValue: "");

  static const _pageSize = 20;

  final PagingController<int, LiveSession> _pagingController = PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    debouncer.setValue("");
    debouncer.values.listen((val) {
      _pagingController.refresh();
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await LiveSessionRepository.getLiveSessions(debouncer.value, _pageSize, pageKey);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      debugPrint("$error");
      _pagingController.error = error;
    }
  }

  final ScrollController _controller = ScrollController();
  final userService = getIt<UserService>();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _pagingController.refresh();
      },
      child: ScaffoldWave(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60), child: HomeAppBarWidget(widget.escapeWithNav, refresh: refresh)),
        body: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: _controller.positions.isEmpty ? 0 : min(_controller.offset, 66),
              ),
              SearchBar(
                initialSearch: "",
                placeholder: "Search for Live-Session...",
                onChanged: (text) {
                  debouncer.setValue(text);
                },
                paddingHorizontal: 0,
                shadowColor: const Color.fromRGBO(188, 140, 75, 1.0),
              ),
              userService.isConnected
                  ? Center(
                      child: MaterialButton(
                        onPressed: () async {
                          TextEditingController textEditingController = TextEditingController();
                          String? roomName = await showDialog(
                              context: context,
                              builder: (context) => Container(
                                    width: 150,
                                    height: 150,
                                    color: Colors.black12,
                                    child: Stack(alignment: Alignment.center, children: [
                                      Positioned(
                                        top: 200,
                                        child: Container(
                                          width: 300,
                                          height: 260,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20),
                                              color: const Color.fromRGBO(48, 73, 123, 1)),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.only(top: 5),
                                                child: Center(
                                                    child: Text(
                                                  "Create Room",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleLarge
                                                      ?.copyWith(fontWeight: FontWeight.w700),
                                                )),
                                              ),
                                              const SizedBox(
                                                height: 7,
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 23.5),
                                                child: const Text("Please name your room"),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 22),
                                                alignment: Alignment.center,
                                                child: Card(
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                    child: Container(
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(10),
                                                        color: const Color.fromRGBO(29, 40, 58, 1),
                                                        boxShadow: const [
                                                          BoxShadow(
                                                            color: Color.fromRGBO(188, 140, 75, 1),
                                                            spreadRadius: 0,
                                                            blurRadius: 0,
                                                            offset: Offset(0, 1), // changes position of shadow
                                                          ),
                                                        ],
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(left: 10, right: 10),
                                                        child: TextField(
                                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                                color: const Color.fromRGBO(164, 202, 255, 1),
                                                              ),
                                                          controller: textEditingController,
                                                          onSubmitted: (text) {
                                                            Navigator.of(context).pop(text);
                                                          },
                                                          decoration: InputDecoration(
                                                            border: InputBorder.none,
                                                            alignLabelWithHint: true,
                                                            hintText: "Room Name",
                                                            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                                color: const Color.fromRGBO(135, 135, 135, 1),
                                                                fontStyle: FontStyle.italic),
                                                          ),
                                                        ),
                                                      ),
                                                    )),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              SizedBox(
                                                  width: MediaQuery.of(context).size.width,
                                                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                    RawMaterialButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop(textEditingController.text);
                                                      },
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          boxShadow: const [
                                                            BoxShadow(
                                                              color: Colors.black45,
                                                              spreadRadius: 1,
                                                              blurRadius: 5,
                                                              offset: Offset(0, 2),
                                                            ),
                                                          ],
                                                          borderRadius: BorderRadius.circular(15),
                                                          color: const Color.fromRGBO(99, 163, 253, 1),
                                                          border: Border.all(
                                                              color: const Color.fromRGBO(188, 140, 75, 0.25),
                                                              width: 1.0), //
                                                        ),
                                                        height: 40,
                                                        width: 150,
                                                        child: Center(
                                                          child: Text(
                                                            "Confirm",
                                                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                                                color: const Color.fromRGBO(15, 23, 41, 1),
                                                                fontWeight: FontWeight.w600),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    RawMaterialButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop(null);
                                                      },
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          boxShadow: const [
                                                            BoxShadow(
                                                              color: Colors.black45,
                                                              spreadRadius: 1,
                                                              blurRadius: 5,
                                                              offset: Offset(0, 2),
                                                            ),
                                                          ],
                                                          borderRadius: BorderRadius.circular(15),
                                                          color: const Color.fromRGBO(154, 0, 0, 1),
                                                          border: Border.all(
                                                              color: const Color.fromRGBO(188, 140, 75, 0.25),
                                                              width: 1.0), //
                                                        ),
                                                        height: 40,
                                                        width: 80,
                                                        child: Center(
                                                          child: Text(
                                                            "Cancel",
                                                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                                                color: const Color.fromRGBO(164, 202, 255, 1),
                                                                fontWeight: FontWeight.w600),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ]))
                                            ],
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ));
                          if (roomName != null) {
                            final response = await liveSessionService.openRoom(roomName);
                            if (response != null) {
                              liveSessionService.setSession(response);
                              widget.escapeWithNav(PageTransition(
                                alignment: Alignment.bottomCenter,
                                curve: Curves.bounceOut,
                                type: PageTransitionType.fade,
                                duration: const Duration(milliseconds: 300),
                                reverseDuration: const Duration(milliseconds: 200),
                                child: const LivestreamScreen(),
                              ));
                            }
                          }
                        },
                        color: const Color.fromRGBO(99, 163, 253, 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Text(
                          "Create Session",
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(color: const Color.fromRGBO(0, 0, 0, 1)),
                        ),
                      ),
                    )
                  : const SizedBox(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "Live Sessions",
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.left,
                ),
              ),
              Flexible(
                flex: 1,
                child: PagedListView<int, LiveSession>(
                  scrollController: _controller,
                  pagingController: _pagingController,
                  builderDelegate: PagedChildBuilderDelegate<LiveSession>(
                    itemBuilder: (context, item, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LiveSessionTile(session: item, escapeWithNav: widget.escapeWithNav),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
