import 'package:Talkaboat/screens/search.screen.dart';
import 'package:Talkaboat/widgets/wallet/wallet.screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import '../screens/settings/settings.screen.dart';
import '../services/user/user.service.dart';
import '../injection/injector.dart';



class HomeAppBarWidget extends StatefulWidget {
  HomeAppBarWidget({Key? key, this.refresh, this.bottom}) : super(key: key);
  final Function? refresh;
  final PreferredSizeWidget? bottom;

  @override
  State<HomeAppBarWidget> createState() => _HomeAppBarWidgetState();
}

class _HomeAppBarWidgetState extends State<HomeAppBarWidget> {
  final userService = getIt<UserService>();

  void _onItemSelected(CurrentContentData item) {
    userService.changeSelectedView(item);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromRGBO(29, 40, 58, 1),
      leading: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Image.asset(
          "assets/images/aboat1.png",
        ),
      ),
      leadingWidth: 35,
      titleSpacing: 10,
      bottom: widget.bottom,
      title: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          "Talkaboat",
          style: GoogleFonts.inter(
              textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color.fromRGBO(99, 163, 253, 1))),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 5),
          child: PopupMenuButton<CurrentContentData>(
            itemBuilder: (BuildContext context) {
              return userService.menuItems.map((CurrentContentData item) {
                return PopupMenuItem<CurrentContentData>(
                  value: item,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(item.icon, color: item.color),
                      Text(item.label.value),
                    ],
                  ),
                );
              }).toList();
            },
            onSelected: _onItemSelected,
            icon: Stack(children: [
              Icon(userService.currentView.icon, color: userService.currentView.color),
              Positioned(
                right: -5,
                bottom: -6,
                child: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.lightBlueAccent,
                  size: 16,
                ),
              ),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 5),
          child: IconButton(
            icon: Image.asset(
              "assets/images/search.png",
              width: 24,
              height: 24,
              fit: BoxFit.cover,
            ),
            tooltip: '',
            onPressed: () {
              Navigator.push(
                  context,
                  PageTransition(
                      alignment: Alignment.bottomCenter,
                      curve: Curves.bounceOut,
                      type: PageTransitionType.rightToLeftWithFade,
                      duration: const Duration(milliseconds: 500),
                      reverseDuration: const Duration(milliseconds: 500),
                      child: const SearchScreen()));
            },
          ),
        ),
        userService.isConnected
            ? Padding(
                padding: const EdgeInsets.only(right: 5),
                child: IconButton(
                  icon: Image.asset(
                    "assets/images/wallet.png",
                    width: 23,
                    height: 20,
                    fit: BoxFit.cover,
                  ),
                  tooltip: '',
                  onPressed: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            alignment: Alignment.bottomCenter,
                            curve: Curves.bounceOut,
                            type: PageTransitionType.rightToLeftWithFade,
                            duration: const Duration(milliseconds: 500),
                            reverseDuration: const Duration(milliseconds: 500),
                            child: const WalletScreen()));
                  },
                ),
              )
            : const SizedBox(),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            icon: Image.asset(
              "assets/images/settings.png",
              width: 30,
              height: 30,
              fit: BoxFit.cover,
            ),
            tooltip: '',
            onPressed: () {
              Navigator.push(
                  context,
                  PageTransition(
                      alignment: Alignment.bottomCenter,
                      curve: Curves.bounceOut,
                      type: PageTransitionType.rightToLeftWithFade,
                      duration: const Duration(milliseconds: 500),
                      reverseDuration: const Duration(milliseconds: 500),
                      child: SettingsScreen(refresh: widget.refresh)));
            },
          ),
        )
      ],
    );
  }
}
