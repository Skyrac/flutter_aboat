import 'package:Talkaboat/screens/search.screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

import '../screens/settings/settings.screen.dart';

class HomeAppBarWidget extends StatelessWidget {
  const HomeAppBarWidget({Key? key, this.refresh}) : super(key: key);
  final Function? refresh;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromRGBO(29, 40, 58, 1),
      leading: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Image.asset(
          "assets/images/aboat1.png",
        ),
      ),
      leadingWidth: 45,
      titleSpacing: 10,
      flexibleSpace: Container(
        alignment: Alignment.bottomCenter,
        child: Image.asset(
          width: MediaQuery.of(context).size.width,
          "assets/images/wave.png",
          fit: BoxFit.cover,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 55),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.0),
              border: const Border(bottom: BorderSide(color: Color.fromRGBO(164, 202, 255, 1))),
            ),
            child: const TabBar(
                labelColor: Color.fromRGBO(188, 140, 75, 1),
                indicatorColor: Color.fromRGBO(188, 140, 75, 1),
                unselectedLabelColor: Color.fromRGBO(164, 202, 255, 1),
                tabs: [
                  Tab(text: "Suggested"),
                  Tab(text: "Categories"),
                  Tab(text: "News"),
                ]),
          ),
        ),
      ),
      title: Text(
        "Talkaboat",
        style: GoogleFonts.inter(
            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color.fromRGBO(99, 163, 253, 1))),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: IconButton(
            icon: Image.asset(
              "assets/images/search.png",
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
                      child: const SearchScreen()));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: IconButton(
            icon: Image.asset(
              "assets/images/wallet.png",
              width: 35,
              height: 30,
              fit: BoxFit.cover,
            ),
            tooltip: '',
            onPressed: () {},
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            icon: Image.asset(
              "assets/images/settings.png",
              width: 35,
              height: 35,
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
