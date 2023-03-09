import 'package:Talkaboat/screens/search.screen.dart';
import 'package:Talkaboat/widgets/wallet/wallet.screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import '../screens/settings/settings.screen.dart';
import '../services/user/user.service.dart';
import '../injection/injector.dart';

class HomeAppBarWidget extends StatelessWidget {
  HomeAppBarWidget({Key? key, this.refresh, this.bottom}) : super(key: key);
  final Function? refresh;
  final PreferredSizeWidget? bottom;
  final userService = getIt<UserService>();

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
      bottom: bottom,
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
                    width: 25,
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
                      child: SettingsScreen(refresh: refresh)));
            },
          ),
        )
      ],
    );
  }
}
