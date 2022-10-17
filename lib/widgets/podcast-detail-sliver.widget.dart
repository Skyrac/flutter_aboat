import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/services/web3/token.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:share_plus/share_plus.dart';

import '../models/search/search_result.model.dart';
import '../screens/login.screen.dart';
import '../themes/colors.dart';
import 'bottom-sheets/claim.bottom-sheet.dart';

class PodcastDetailSliver extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final SearchResult podcast;

  PodcastDetailSliver({required this.expandedHeight, required this.podcast});

  final userService = getIt<UserService>();
  final tokenService = getIt<TokenService>();
  final donationAmountController = TextEditingController();
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    const size = 200;
    final top = expandedHeight / 1.1 - shrinkOffset / 3 - size;
    return Stack(
      fit: StackFit.expand,
      children: [
        buildBackground(shrinkOffset, context),

        buildAppBar(shrinkOffset),
        Positioned(
          top: top,
          left: 20,
          right: 20,
          child: buildFloating(shrinkOffset, context),
        ),
        // buildAppBar(shrinkOffset),
        // Container(
        //     height: 30,
        //     padding: EdgeInsets.fromLTRB(18, 58, 18, 8),
        //     alignment: Alignment.bottomCenter,
        //     child: DecoratedBox(
        //       decoration: BoxDecoration(
        //         // color: Colors.white.withOpacity(1.0),
        //         border: const Border(
        //             bottom:
        //                 BorderSide(color: Color.fromRGBO(164, 202, 255, 1))),
        //       ),
        //       child: const TabBar(
        //         labelColor: Color.fromRGBO(188, 140, 75, 1),
        //         indicatorColor: Color.fromRGBO(188, 140, 75, 1),
        //         unselectedLabelColor: Color.fromRGBO(164, 202, 255, 1),
        //         tabs: [
        //           Tab(text: "Episodes"),
        //           Tab(text: "Details"),
        //           Tab(text: "Community"),
        //         ],
        //       ),
        //     ))
        // Container(
        //   alignment: Alignment.bottomCenter,
        //   child: const TabBar(
        //     labelColor: Color.fromRGBO(188, 140, 75, 1),
        //     indicatorColor: Color.fromRGBO(188, 140, 75, 1),
        //     unselectedLabelColor: Color.fromRGBO(164, 202, 255, 1),
        //     tabs: [
        //       Tab(text: "Episodes"),
        //       Tab(text: "Details"),
        //       Tab(text: "Community"),
        //     ],
        //   ),
        // )
      ],
    );
  }

  double appear(double shrinkOffset) => shrinkOffset / expandedHeight;

  double disappear(double shrinkOffset) => 1 - shrinkOffset / expandedHeight;

  Widget buildAppBar(double shrinkOffset) => PreferredSize(
        preferredSize: Size.fromHeight(expandedHeight),
        child: AppBar(
            leading: SizedBox(),
            // backgroundColor:
            //     DefaultColors.secondaryColorAlphaBlendStrong.shade900,
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(expandedHeight),
              child: Container(
                padding: EdgeInsets.fromLTRB(18, 5, 18, 10),
                child: Material(
                  borderRadius: BorderRadius.circular(20),
                  color: Color.fromRGBO(29, 40, 58, 0.8),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(18, 8, 18, 8),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.0),
                        border: const Border(
                            bottom: BorderSide(
                                color: Color.fromRGBO(164, 202, 255, 1))),
                      ),
                      child: const TabBar(
                        labelColor: Color.fromRGBO(188, 140, 75, 1),
                        indicatorColor: Color.fromRGBO(188, 140, 75, 1),
                        unselectedLabelColor: Color.fromRGBO(164, 202, 255, 1),
                        tabs: [
                          Tab(text: "Episodes"),
                          Tab(text: "Details"),
                          Tab(text: "Community"),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )),
      );

  Widget buildBackground(double shrinkOffset, context) => Opacity(
      opacity: disappear(shrinkOffset),
      child: Stack(
        children: <Widget>[
          Container(
              padding: const EdgeInsets.only(left: 10.0),
              height: expandedHeight - 25,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(podcast.image!),
                  fit: BoxFit.cover,
                ),
              )),
        ],
      ));

  Widget buildFloating(double shrinkOffset, BuildContext context) => Opacity(
        opacity: disappear(shrinkOffset),
        child: SizedBox(
          height: 130,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // SizedBox(
              //   width: 240,
              //   child: ClipRRect(
              //       borderRadius: BorderRadius.circular(200),
              //       child: Card(
              //           child: buildButton(
              //               text: 'Donate',
              //               icon: Icons.money,
              //               onClick: () => {showDonationModal(context)}))),
              // ),
              // const SizedBox(
              //   height: 15,
              // ),
              Row(
                children: [
                  // Expanded(
                  //     child: Card(
                  //   child: buildButton(
                  //       text: 'Share',
                  //       icon: Icons.share,
                  //       onClick: () => {
                  //             //TODO: Geräte Abhängigkeit prüfen
                  //             Share.share(
                  //                 "Check the Podcast ${podcast.title} on Talkaboat.online mobile App! Start listening and earn while supporting new and upcoming podcasters.\n\n Download it now on \nAndroid: https://play.google.com/store/apps/details?id=com.aboat.talkaboat\n",
                  //                 subject:
                  //                     "Check this out! A Podcast on Talkaboat.online.")
                  //           }),
                  // )),
                  Expanded(
                    //S child: Card(
                    child: buildButton(
                        text: 'Ownership',
                        icon: Image.asset(
                          "assets/images/person.png",
                          width: 20,
                        ),
                        onClick: () => {
                              showModalBottomSheet(
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20))),
                                  context: context,
                                  builder: (context) =>
                                      ClaimBottomSheet(podcastId: podcast.id!))
                            }),
                    //)
                  ),
                  Expanded(
                    //Schild: Card(
                    child: buildButton(
                        text: 'Donate',
                        icon: Image.asset("assets/images/money.png", width: 28),
                        onClick: () => {showDonationModal(context)}),
                    //)
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget buildButton(
          {required String text,
          required Image icon,
          required Function onClick}) =>
      RawMaterialButton(
        child: Container(
          width: 140,
          height: 40,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color.fromRGBO(15, 23, 41, 1),
              border: Border.all(color: Color.fromRGBO(99, 163, 253, 1))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 12),
              Text(text,
                  style: TextStyle(
                      fontSize: 12, color: Color.fromRGBO(99, 163, 253, 1))),
            ],
          ),
        ),
        onPressed: () {
          onClick();
        },
      );

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight + 100;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;

  void showDonationModal(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).dialogBackgroundColor,
              title: Text('Donation for ${podcast.title}'),
              elevation: 8,
              content: userService.isConnected
                  ? TextField(
                      controller: donationAmountController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r"[0-9.,]")),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          try {
                            final text = newValue.text.replaceAll(",", ".");
                            if (text.isEmpty ||
                                double.parse(text) <=
                                    userService.availableToken) return newValue;
                          } catch (e) {}
                          return oldValue;
                        }),
                      ],
                      decoration: InputDecoration(
                          hintText: "Donation Amount",
                          labelText:
                              "Available ABOAT: ${userService.availableToken.toStringAsFixed(2)}",
                          labelStyle: Theme.of(context).textTheme.labelLarge,
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          border: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          )))
                  : SizedBox(
                      height: 140,
                      child: Column(
                        children: [
                          Text("Login to use this feature!"),
                          createLoginButton(context)
                        ],
                      ),
                    ),
              actions: [
                TextButton(
                    onPressed: (() {
                      if (donationAmountController.text.isEmpty) {
                        return;
                      }
                      tokenService.donate(podcast.id!,
                          double.parse(donationAmountController.text));
                      donationAmountController.text = "";
                      Navigator.pop(context);
                    }),
                    child: Text("Donate")),
                TextButton(
                    onPressed: (() {
                      Navigator.pop(context);
                    }),
                    child: Text("Cancel"))
              ],
            ));
  }

  createLoginButton(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Card(
              child: InkWell(
                onTap: (() {
                  Navigator.push(
                      context,
                      PageTransition(
                          alignment: Alignment.bottomCenter,
                          curve: Curves.bounceOut,
                          type: PageTransitionType.fade,
                          duration: const Duration(milliseconds: 300),
                          reverseDuration: const Duration(milliseconds: 200),
                          child: LoginScreen(() => Navigator.pop(context))));
                }),
                child: SizedBox(
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Text(
                        "Login",
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    )),
              ),
            ),
          ),
        ),
      );
}
