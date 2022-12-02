import 'package:flutter/material.dart';
import '../../injection/injector.dart';
import '../../services/user/user.service.dart';
import '../../utils/scaffold_wave.dart';
import '../login-button.widget.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key, this.refresh}) : super(key: key);
  final Function? refresh;
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final userService = getIt<UserService>();
  List<String> chainList = ["etherium", "mumbai", "polygon"];
  String? selectedItem;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: ScaffoldWave(
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
                                      const Text("Locked"),
                                      const Text("105,000,253.53 ABOAT"),
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
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("0xDjhas...hjbb"),
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
                                      const Text("0xDjhas...hjbb"),
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
                        }, const Color.fromRGBO(70, 70, 70, 1), "assets/images/wallet_button2.png"),
                      ]),
                    ),
                  )
                : const Center(child: LoginButton())));
  }

  Widget walletButton(String textButton, VoidCallback func, Color textColor, String imageLink) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: RawMaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onPressed: func,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 45,
          width: 380,
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
    return Container(
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: contentBox(context),
      ),
    );
  }

  Widget contentBox(context) {
    return SingleChildScrollView(
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 0, top: 15, right: 0, bottom: 20),
            // margin: EdgeInsets.only(top: 30),
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
                inputSelect(context, "Select chain...", chainList),
                const SizedBox(
                  height: 10,
                ),
                inputSelect(context, "Select wallet...", chainList),
                Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.only(right: 25),
                    child: Align(
                        alignment: Alignment.bottomRight,
                        child: Text("366,264.09 ABOAT", style: Theme.of(context).textTheme.bodyMedium))),
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
                            // controller: textController,
                            onSubmitted: (text) {
                              Navigator.of(context).pop(text);
                            },
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
                Container(
                    width: 250,
                    child: Align(
                        alignment: Alignment.center,
                        child: Text(
                            "Min. ABOAT to claim: 5000 ABOAT. The ABOAT claim incurs fees of 500 ABOAT. These will be deducted from your withdrawn amount. When withdrawing chain-native coins, there are fees of 10%.",
                            style: Theme.of(context).textTheme.bodyMedium))),
                const SizedBox(
                  height: 10,
                ),
                claimButton(context, "Claim ABOAT", () => {print("Claim ABOAT")}, const Color.fromRGBO(99, 163, 253, 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Row(children: <Widget>[
                    const Expanded(
                        child: Divider(
                      color: Color.fromRGBO(15, 23, 41, 1),
                      thickness: 3,
                    )),
                    Container(
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
                claimButton(context, "Convert to {{chain-native}}", () => {print("Convert to {{chain-native}}")},
                    const Color.fromRGBO(188, 140, 75, 1))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget claimButton(BuildContext context, String title, VoidCallback func, Color color) {
    return RawMaterialButton(
        onPressed: func,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: const Color.fromRGBO(29, 40, 58, 0.97),
            border: Border.all(
                color: const Color.fromRGBO(188, 140, 75, 0.25), // set border color
                width: 1.0), //
          ),
          height: 40,
          child: Center(
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
          ),
        ));
  }

  Widget inputSelect(BuildContext context, String hintText, List items) {
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
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color.fromRGBO(99, 163, 253, 1),
            size: 30,
          ),
          dropdownColor: const Color.fromRGBO(29, 40, 58, 0.97),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(left: 10),
            border: InputBorder.none,
            alignLabelWithHint: true,
            hintText: hintText,
            hintStyle: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: const Color.fromRGBO(135, 135, 135, 1), fontStyle: FontStyle.italic),
          ),
          value: selectedItem,
          items: items.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
          onChanged: (item) => {setState(() => selectedItem = item)}),
    );
  }

  showAlert(BuildContext context) {
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
                  child:
                      const Text("Are you sure that you want to remove the wallet {{wallet-address}} from your account?")),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
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
