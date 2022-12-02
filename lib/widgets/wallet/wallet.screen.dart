import 'package:Talkaboat/screens/settings/earnings.screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../../injection/injector.dart';
import '../../services/downloading/file-downloader.service.dart';
import '../../services/user/user.service.dart';
import '../../themes/colors.dart';
import '../../utils/modal.widget.dart';
import '../../utils/scaffold_wave.dart';
import '../../widgets/settings-app-bar.widget.dart';
import '../login-button.widget.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key, this.refresh}) : super(key: key);
  final Function? refresh;
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final userService = getIt<UserService>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: ScaffoldWave(
            appBar: AppBar(
              title: const Text("Wallet"),
              backgroundColor: const Color.fromRGBO(29, 40, 58, 1),
            ),
            body: userService.isConnected
                ? Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Column(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        height: 80,
                        width: 380,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Color.fromRGBO(99, 163, 253, 0.5))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text("Aboat Token", style: Theme.of(context).textTheme.labelLarge),
                            Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Available"),
                                    Text("15,033,253.00 ABOAT"),
                                  ],
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Locked"),
                                    Text("105,000,253.53 ABOAT"),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      walletButton("Earning History", () {
                        print("Earning History");
                      }, Colors.white, "assets/images/wallet_button.png"),
                      walletButton("Claim", () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomDialogBox();
                            });
                        print("Claim");
                      }, Colors.white, "assets/images/wallet_button.png"),
                      walletButton("Connect new wallet", () {
                        print("Connect new wallet");
                      }, Colors.white, "assets/images/wallet_button.png"),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        // height: 80,
                        width: 380,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Color.fromRGBO(99, 163, 253, 0.5))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text("Wallets", style: Theme.of(context).textTheme.labelLarge),
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("0xDjhas...hjbb"),
                                      IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () {
                                            print("delete");
                                            showAlert(context);
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Color.fromRGBO(154, 0, 0, 1),
                                            size: 28,
                                          )),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("0xDjhas...hjbb"),
                                    IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          print("delete");
                                          showAlert(context);
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Color.fromRGBO(154, 0, 0, 1),
                                          size: 28,
                                        )),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      walletButton("Manage Custodial Wallet", () {
                        print("Manage Custodial Wallet");
                      }, Color.fromRGBO(70, 70, 70, 1), "assets/images/wallet_button2.png"),
                    ]),
                  )
                : const Center(child: LoginButton())));
  }

  Widget walletButton(String textButton, VoidCallback func, Color textColor, String imageLink) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: RawMaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onPressed: func,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          height: 45,
          width: 380,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color.fromRGBO(29, 40, 58, 1),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.25),
                spreadRadius: -0.2,
                blurRadius: 0,
                offset: Offset(0, 4), // changes position of shadow
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(textButton, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: textColor)),
              Image.asset(
                imageLink,
                width: 35,
                height: 30,
                fit: BoxFit.cover,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget CustomDialogBox() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 0,
      backgroundColor: Colors.blue,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 20, top: 15, right: 20, bottom: 20),
          // margin: EdgeInsets.only(top: 30),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Color.fromRGBO(48, 73, 123, 1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "Claim ABOAT",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "widget.descriptions",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 22,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: RawMaterialButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "widget.text",
                      style: TextStyle(fontSize: 18),
                    )),
              ),
            ],
          ),
        ),
        // Positioned(
        //   left: 5,
        //   right: 5,
        //   child: CircleAvatar(
        //     backgroundColor: Colors.transparent,
        //     radius: 10,
        //     child: ClipRRect(borderRadius: BorderRadius.all(Radius.circular(10)), child: Image.asset("assets/model.jpeg")),
        //   ),
        // ),
      ],
    );
  }

  showAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
              backgroundColor: const Color.fromRGBO(48, 73, 123, 1),
              title: Align(alignment: Alignment.center, child: const Text("Remove Wallet")),
              elevation: 8,
              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
              content: Container(
                  height: 50,
                  alignment: Alignment.center,
                  child: Text("Are you sure that you want to remove the wallet {{wallet-address}} from your account?")),
              actions: [
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: RawMaterialButton(
                    onPressed: (() {}),
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
                        border: Border.all(color: const Color.fromRGBO(188, 140, 75, 0.25), width: 1.0), //
                      ),
                      height: 40,
                      width: 150,
                      child: Center(
                        child: Text(
                          "Remove",
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: const Color.fromRGBO(164, 202, 255, 1), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: RawMaterialButton(
                    onPressed: (() {
                      Navigator.pop(context);
                    }),
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
                        border: Border.all(color: const Color.fromRGBO(188, 140, 75, 0.25), width: 1.0), //
                      ),
                      height: 40,
                      width: 80,
                      child: Center(
                        child: Text(
                          "Cancel",
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: const Color.fromRGBO(15, 23, 41, 1), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 15,
                )
              ],
            ));
  }
}
