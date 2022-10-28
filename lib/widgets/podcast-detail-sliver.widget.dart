import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/services/web3/token.service.dart';
import 'package:Talkaboat/widgets/login-button.widget.dart';
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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
      ],
    );
  }

  double appear(double shrinkOffset) => shrinkOffset / expandedHeight;

  double disappear(double shrinkOffset) => 1 - shrinkOffset / expandedHeight;

  Widget buildAppBar(double shrinkOffset) => AppBar(
        title: Text(podcast.title!),
        backgroundColor: DefaultColors.secondaryColorAlphaBlendStrong.shade900,
        centerTitle: true,
      );

  Widget buildBackground(double shrinkOffset, context) => Opacity(
      opacity: disappear(shrinkOffset),
      child: Stack(
        children: <Widget>[
          Container(
              padding: const EdgeInsets.only(left: 10.0),
              height: expandedHeight,
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
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 240,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(200),
                    child: Card(
                        child: buildButton(text: 'Donate', icon: Icons.money, onClick: () => {showDonationModal(context)}))),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Expanded(
                      child: Card(
                    child: buildButton(
                        text: 'Share',
                        icon: Icons.share,
                        onClick: () => {
                              //TODO: Geräte Abhängigkeit prüfen
                              Share.share(
                                  "Check the Podcast ${podcast.title} on Talkaboat.online mobile App! Start listening and earn while supporting new and upcoming podcasters.\n\n Download it now on \nAndroid: https://play.google.com/store/apps/details?id=com.aboat.talkaboat\n",
                                  subject: "Check this out! A Podcast on Talkaboat.online.")
                            }),
                  )),
                  Expanded(
                      child: Card(
                    child: buildButton(
                        text: 'Claim',
                        icon: Icons.rv_hookup,
                        onClick: () => {
                              showModalBottomSheet(
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                                  context: context,
                                  builder: (context) => ClaimBottomSheet(podcastId: podcast.id!))
                            }),
                  )),
                ],
              ),
            ],
          ),
        ),
      );

  Widget buildButton({required String text, required IconData icon, required Function onClick}) => TextButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Text(text, style: const TextStyle(fontSize: 20)),
          ],
        ),
        onPressed: () {
          onClick();
        },
      );

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight + 30;

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
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r"[0-9.,]")),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          try {
                            final text = newValue.text.replaceAll(",", ".");
                            if (text.isEmpty || double.parse(text) <= userService.availableToken) return newValue;
                          } catch (e) {}
                          return oldValue;
                        }),
                      ],
                      decoration: InputDecoration(
                          hintText: "Donation Amount",
                          labelText: "Available ABOAT: ${userService.availableToken.toStringAsFixed(2)}",
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
                        children: const [Text("Login to use this feature!"), Center(child: LoginButton())],
                      ),
                    ),
              actions: [
                TextButton(
                    onPressed: (() {
                      if (donationAmountController.text.isEmpty) {
                        return;
                      }
                      tokenService.donate(podcast.id!, double.parse(donationAmountController.text));
                      donationAmountController.text = "";
                      Navigator.pop(context);
                    }),
                    child: const Text("Donate")),
                TextButton(
                    onPressed: (() {
                      Navigator.pop(context);
                    }),
                    child: const Text("Cancel"))
              ],
            ));
  }
}
