import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int? selectedChain;
  String? selectedAddress;

  final connector = WalletConnect(
    bridge: 'https://bridge.walletconnect.org',
    clientMeta: PeerMeta(
      name: 'WalletConnect',
      description: 'WalletConnect Talkaboat App',
      url: 'https://talkaboat.online',
      icons: ['https://talkaboat.online/assets/images/aboat.png'],
    ),
  );

  var _session, uri, session;
  connectWallet(BuildContext context) async {
    if (!connector.connected) {
      try {
        session = await connector.createSession(onDisplayUri: (_uri) async {
          uri = _uri;
          await launchUrlString(uri, mode: LaunchMode.externalApplication);
        });
        setState(() {});

        print("session: $session");
      } catch (e) {
        print(e);
      }
    }
  }

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
                      print("Earning History");
                    }, Colors.white, "assets/images/arrow_right.png"),
                    WalletButton("Claim", () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomDialogBox(context, selectedAddress, selectedChain);
                          });
                      print("Claim");
                    }, Colors.white, "assets/images/arrow_right.png"),
                    WalletButton("Connect new wallet", () async {
                      await connectWallet(context);
                      print("Connect new wallet ${session.accounts[0]}");
                      await userService.addWallet(session.accounts[0]);
                      connector.killSession();
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
                                                                print("delete");
                                                                showAlert(context, item);
                                                              },
                                                              icon: const Icon(
                                                                Icons.delete,
                                                                color: Color.fromRGBO(154, 0, 0, 1),
                                                                size: 28,
                                                              ))
                                                          : SizedBox(),
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
                      print("Manage Custodial Wallet");
                    }, const Color.fromRGBO(70, 70, 70, 1), "assets/images/arrow_right_inactive.png"),
                  ]),
                ),
              )
            : const Center(child: LoginButton()));
  }

  showAlert(BuildContext context, String address) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
              backgroundColor: const Color.fromRGBO(48, 73, 123, 1),
              title: const Align(alignment: Alignment.center, child: Text("Remove Wallet")),
              elevation: 8,
              contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
              content: Container(
                  height: 50,
                  alignment: Alignment.center,
                  child: Text("Are you sure that you want to remove the wallet ${address.toString()} from your account?")),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: RawMaterialButton(
                    onPressed: (() {
                      setState(() {
                        userService.deleteWallet(address);
                      });
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
                  padding: const EdgeInsets.only(bottom: 10),
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
                const SizedBox(
                  width: 15,
                )
              ],
            ));
  }
}

class ClaimButton extends StatelessWidget {
  const ClaimButton(context, this.title, this.func, this.color, {Key? key}) : super(key: key);
  final String title;
  final VoidCallback? func;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: const Color.fromRGBO(29, 40, 58, 0.97),
          border: Border.all(
              color: const Color.fromRGBO(188, 140, 75, 0.25), // set border color
              width: 1.0), //
        ),
        height: 40,
        child: RawMaterialButton(
          onPressed: func,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color),
              ),
            ],
          ),
        ));
  }
}

class WalletButton extends StatelessWidget {
  const WalletButton(this.textButton, this.func, this.textColor, this.imageLink, {Key? key}) : super(key: key);
  final String? textButton;
  final VoidCallback? func;
  final Color? textColor;
  final String? imageLink;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: RawMaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onPressed: func,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromRGBO(29, 40, 58, 1),
            boxShadow: [
              const BoxShadow(
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
              Text(textButton!, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: textColor)),
              Image.asset(
                imageLink!,
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
}

class CustomDialogBox extends StatefulWidget {
  CustomDialogBox(context, this.selectedAddress, this.selectedChain, {Key? key}) : super(key: key);

  int? selectedChain;
  String? selectedAddress;
  static const Map<int, String> network = {21: "Elastos Testnet"};

  @override
  State<CustomDialogBox> createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  final userService = getIt<UserService>();
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final addresses = userService.userInfo!.addresses;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 0, top: 15, right: 0, bottom: 20),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: const Color.fromRGBO(48, 73, 123, 1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    "Claim ABOAT",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  inputSelect(context, "Select chain...", CustomDialogBox.network, addresses!, true, widget.selectedChain,
                      widget.selectedAddress),
                  const SizedBox(
                    height: 10,
                  ),
                  inputSelect(context, "Select wallet...", CustomDialogBox.network, addresses!, false, widget.selectedChain,
                      widget.selectedAddress),
                  Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.only(right: 25),
                      child: Align(
                          alignment: Alignment.bottomRight,
                          child: Text("${userService.availableToken.toStringAsFixed(2)} ABOAT",
                              style: Theme.of(context).textTheme.bodyMedium))),
                  Container(
                    width: 265,
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    alignment: Alignment.center,
                    child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromRGBO(29, 40, 58, 1),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(188, 140, 75, 1),
                                spreadRadius: 0,
                                blurRadius: 0,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: TextField(
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: const Color.fromRGBO(164, 202, 255, 1),
                                  ),
                              controller: textController,
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
                                border: InputBorder.none,
                                alignLabelWithHint: true,
                                hintText: "Amount...",
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: const Color.fromRGBO(135, 135, 135, 1), fontStyle: FontStyle.italic),
                              ),
                            ),
                          ),
                        )),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                      width: 250,
                      child: Align(
                          alignment: Alignment.center,
                          child: Text(
                              "Min. ABOAT to claim: 5000 ABOAT. The ABOAT claim incurs fees of 500 ABOAT. These will be deducted from your withdrawn amount. When withdrawing chain-native coins, there are fees of 10%.",
                              style: Theme.of(context).textTheme.bodyMedium))),
                  const SizedBox(
                    height: 10,
                  ),
                  ClaimButton(context, "Claim ABOAT", () {
                    print("Claim ABOAT");
                    print(widget.selectedAddress);
                    print(widget.selectedChain);
                    if (textController.text.isEmpty) {
                      return;
                    }
                    if (double.parse(textController.text) >= 5000 &&
                        widget.selectedChain != null &&
                        widget.selectedAddress != null) {
                      userService.claimABOAT(
                          widget.selectedChain!, widget.selectedAddress!, double.parse(textController.text));
                      textController.text = "";
                      Navigator.pop(context);
                    } else {
                      print("<5000");
                    }
                  }, const Color.fromRGBO(99, 163, 253, 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Row(children: <Widget>[
                      const Expanded(
                          child: Divider(
                        color: Color.fromRGBO(15, 23, 41, 1),
                        thickness: 3,
                      )),
                      SizedBox(
                          width: 45,
                          height: 40,
                          child: Center(
                              child: Text(
                            "OR",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: const Color.fromRGBO(15, 23, 41, 1), fontWeight: FontWeight.w600),
                          ))),
                      const Expanded(
                          child: Divider(
                        color: Color.fromRGBO(15, 23, 41, 1),
                        thickness: 3,
                      )),
                    ]),
                  ),
                  ClaimButton(context, "Convert to {{chain-native}}", () {
                    print("Convert to {{chain-native}}");
                    if (textController.text.isEmpty) {
                      return;
                    }
                    userService.claimABOATNative(
                        widget.selectedChain!, widget.selectedAddress!, double.parse(textController.text));
                    textController.text = "";
                    Navigator.pop(context);
                  }, const Color.fromRGBO(188, 140, 75, 1))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget inputSelect(BuildContext context, String hintText, Map network, List addresses, bool chain, int? selectedChain,
      String? selectedAddress) {
    return Container(
      width: 260,
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
      child: DropdownButtonFormField<String>(
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color.fromRGBO(99, 163, 253, 1),
            size: 30,
          ),
          hint: Text(hintText,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: const Color.fromRGBO(135, 135, 135, 1), fontStyle: FontStyle.italic)),
          dropdownColor: const Color.fromRGBO(29, 40, 58, 0.97),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.only(left: 10),
            border: InputBorder.none,
            alignLabelWithHint: true,
          ),
          value: chain ? widget.selectedChain?.toString() : widget.selectedAddress,
          items: chain
              ? network.entries
                  .map((e) => DropdownMenuItem<String>(
                      value: e.key.toString(),
                      child: Text(
                        e.value.toString(),
                        overflow: TextOverflow.ellipsis,
                      )))
                  .toList()
              : addresses
                  .map((item) => DropdownMenuItem<String>(
                      value: item.toString(),
                      child: Text(
                        item.toString(),
                        overflow: TextOverflow.ellipsis,
                      )))
                  .toList(),
          onChanged: chain
              ? (e) {
                  setState(() => widget.selectedChain = int.parse(e!));
                  print(e);
                }
              : (e) {
                  setState(() => widget.selectedAddress = e);
                  print(e);
                }),
    );
  }
}
