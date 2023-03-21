import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/services/web3/token.service.dart';
import 'package:Talkaboat/widgets/login-button.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/search/search_result.model.dart';
import '../bottom-sheets/claim.bottom-sheet.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PodcastDetailSliver extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final SearchResult podcast;
  final TabController? controller;

  PodcastDetailSliver({required this.expandedHeight, required this.podcast, this.controller});

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
        buildAppBar(shrinkOffset, context),
        Container(
          padding: const EdgeInsets.only(bottom: 100),
          child: buildFloating(shrinkOffset, context),
        )
      ],
    );
  }

  double appear(double shrinkOffset) => shrinkOffset / expandedHeight;

  double disappear(double shrinkOffset) => 1 - shrinkOffset / expandedHeight;

  Widget buildAppBar(double shrinkOffset, context) => PreferredSize(
        preferredSize: Size.fromHeight(expandedHeight),
        child: AppBar(
            leading: const SizedBox(),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(expandedHeight),
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                child: Material(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromRGBO(29, 40, 58, 0.92),
                  child: Container(
                    padding: Localizations.localeOf(context).toString() == "de"
                        ? const EdgeInsets.symmetric(vertical: 8, horizontal: 6)
                        : const EdgeInsets.all(8),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.0),
                        border: const Border(bottom: BorderSide(color: Color.fromRGBO(164, 202, 255, 1))),
                      ),
                      child: TabBar(
                        controller: controller,
                        labelColor: const Color.fromRGBO(188, 140, 75, 1),
                        indicatorColor: const Color.fromRGBO(188, 140, 75, 1),
                        unselectedLabelColor: const Color.fromRGBO(164, 202, 255, 1),
                        tabs: [
                          Tab(text: AppLocalizations.of(context)!.episodes),
                          Tab(text: AppLocalizations.of(context)!.details),
                          Tab(text: AppLocalizations.of(context)!.community),
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
                borderRadius: BorderRadius.circular(20),
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
              Row(
                children: [
                  Expanded(
                    child: buildButton(
                        text: AppLocalizations.of(context)!.ownership,
                        icon: Image.asset(
                          "assets/images/person.png",
                          width: 20,
                        ),
                        onClick: () => {
                              showModalBottomSheet(
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                                  context: context,
                                  builder: (context) => ClaimBottomSheet(podcastId: podcast.id!))
                            }),
                  ),
                  Expanded(
                    child: buildButton(
                        text: AppLocalizations.of(context)!.donate,
                        icon: Image.asset("assets/images/money.png", width: 28),
                        onClick: () => {showDonationModal(context)}),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget buildButton({required String text, required Image icon, required void Function()? onClick}) => RawMaterialButton(
        onPressed: onClick,
        child: Container(
          width: 140,
          height: 40,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromRGBO(15, 23, 41, 1),
              border: Border.all(color: const Color.fromRGBO(99, 163, 253, 1))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 12),
              Text(text, style: const TextStyle(fontSize: 12, color: Color.fromRGBO(99, 163, 253, 1))),
            ],
          ),
        ),
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
              title: Text(AppLocalizations.of(context)!.donationForPoscast(podcast.title)),
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
                          } catch (e) {
                            debugPrint("$e");
                          }
                          return oldValue;
                        }),
                      ],
                      decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.donationAmount,
                          labelText:
                              AppLocalizations.of(context)!.availableABOAT(userService.availableToken.toStringAsFixed(2)),
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
                          Text(AppLocalizations.of(context)!.loginToUseThisFeature),
                          const Center(child: LoginButton())
                        ],
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
                    child: Text(AppLocalizations.of(context)!.donate)),
                TextButton(
                    onPressed: (() {
                      Navigator.pop(context);
                    }),
                    child: Text(AppLocalizations.of(context)!.cancel))
              ],
            ));
  }
}
