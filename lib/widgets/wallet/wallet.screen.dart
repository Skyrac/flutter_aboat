import 'dart:io';

import 'package:Talkaboat/widgets/wallet/wallet-buttons.dart';
import 'package:Talkaboat/widgets/wallet/wallet-modals.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../injection/injector.dart';
import '../../screens/settings/earnings.screen.dart';
import '../../services/user/user.service.dart';
import '../../utils/scaffold_wave.dart';
import '../login-button.widget.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key, this.refresh}) : super(key: key);
  final Function? refresh;
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final userService = getIt<UserService>();
  int? selectedChainId;

  final connector = WalletConnect(
    bridge: 'https://bridge.walletconnect.org',
    clientMeta: const PeerMeta(
      name: 'WalletConnect',
      description: 'WalletConnect Talkaboat App',
      url: 'https://talkaboat.online',
      icons: ['https://talkaboat.online/assets/images/aboat.png'],
    ),
  );

  @override
  void dispose() {
    if (connector.connected) {
      connector.killSession();
    }
    super.dispose();
  }

  // TODO: type this
  Future<List<dynamic>?> connectWallet(BuildContext context) async {
    if (!connector.connected) {
      try {
        String? uri;
        final session = await connector.createSession(onDisplayUri: (sessionUri) async {
          try {
            uri = sessionUri;
            await launchUrlString(uri!, mode: LaunchMode.externalApplication);
          } catch (e) {
            debugPrint(e.toString());
            showToast();
          }
        });
        debugPrint("session: $session");
        return [session, uri];
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    return null;
  }

  void showToast() => Fluttertoast.showToast(
        msg: "you need to install the wallet app!",
      );

  @override
  Widget build(BuildContext context) {
    final addresses = userService.userInfo?.addresses;
    return ScaffoldWave(
        appBar: AppBar(
          centerTitle: false,
          leadingWidth: 35,
          titleSpacing: 3,
          title: Text(
            "Wallet",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color.fromRGBO(99, 163, 253, 1),
                ),
          ),
          backgroundColor: const Color.fromRGBO(29, 40, 58, 1),
        ),
        body: userService.isConnected
            ? SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 40, 10, 0),
                  child: Column(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      height: 80,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color.fromRGBO(99, 163, 253, 0.5))),
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
                                  const Text("Available"),
                                  Text("${userService.availableToken.toStringAsFixed(2)} ABOAT"),
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
                                  const Text("Locked"),
                                  Text("${userService.lockedToken.toStringAsFixed(2)} ABOAT"),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    WalletButton("Earning History", () {
                      Navigator.push(
                          context,
                          PageTransition(
                              alignment: Alignment.centerRight,
                              curve: Curves.bounceOut,
                              type: PageTransitionType.rightToLeftWithFade,
                              duration: const Duration(milliseconds: 300),
                              reverseDuration: const Duration(milliseconds: 200),
                              child: const EarningsScreen()));
                      debugPrint("Earning History");
                    }, Colors.white, "assets/images/arrow_right.png"),
                    WalletButton("Claim", () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomDialogBox(context);
                          });
                      debugPrint("Claim");
                    }, Colors.white, "assets/images/arrow_right.png"),
                    WalletButton("Connect new wallet", () async {
                      //if (Platform.isAndroid) {
                      launchUrlString("https://app.aboat-entertainment.com/wallet/add",
                          mode: LaunchMode.externalApplication);
                      /*} else {
                        if (connector.connected) {
                          await connector.killSession();
                        }
                        final r = await connectWallet(context);
                        if (r == null) {
                          return;
                        }
                        final session = r[0];
                        final uri = r[1];
                        debugPrint("Connect new wallet ${session!.accounts[0]} from $uri");
                        final message = await userService.addWallet(session!.accounts[0]);
                        if (connector.connected) {
                          try {
                            debugPrint("Message received $message");
                            EthereumWalletConnectProvider provider = EthereumWalletConnectProvider(connector);
                            launchUrlString(uri, mode: LaunchMode.externalApplication);
                            final signature =
                                await provider.personalSign(message: message, address: session!.accounts[0], password: "");
                            debugPrint(signature);
                            await userService.addWalletConfirm(session!.accounts[0], signature, false, message);
                            await connector.killSession();
                          } catch (exp) {
                            debugPrint("Error while signing transaction");
                            debugPrint(exp.toString());
                          }
                        }
                        connector.killSession();
                      }*/
                    }, Colors.white, "assets/images/arrow_right.png"),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color.fromRGBO(99, 163, 253, 0.5))),
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
                                  children: [
                                    addresses!.isNotEmpty
                                        ? Expanded(
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: addresses.length,
                                                scrollDirection: Axis.vertical,
                                                itemBuilder: (BuildContext context, int index) {
                                                  final item = addresses[index];
                                                  return Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                          "${item.substring(0, 7)}...${item.substring(item.length - 4, item.length)}"),
                                                      addresses.length > 1
                                                          ? IconButton(
                                                              padding: EdgeInsets.zero,
                                                              constraints: const BoxConstraints(),
                                                              onPressed: () {
                                                                debugPrint("delete");
                                                                showAlert(
                                                                    context,
                                                                    item,
                                                                    () => setState(() {
                                                                          addresses.remove(item);
                                                                        }));
                                                                setState(() {
                                                                  addresses.length;
                                                                });
                                                              },
                                                              icon: const Icon(
                                                                Icons.delete,
                                                                color: Color.fromRGBO(154, 0, 0, 1),
                                                                size: 22,
                                                              ))
                                                          : const SizedBox(),
                                                    ],
                                                  );
                                                }),
                                          )
                                        : const Center(child: Text("wallet not found")),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    WalletButton("Manage Custodial Wallet", () {
                      debugPrint("Manage Custodial Wallet");
                    }, const Color.fromRGBO(70, 70, 70, 1), "assets/images/arrow_right_inactive.png"),
                  ]),
                ),
              )
            : const Center(child: LoginButton()));
  }
}
