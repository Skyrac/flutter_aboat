import 'package:Talkaboat/widgets/wallet/wallet-buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../injection/injector.dart';
import '../../models/smart/chain.model.dart';
import '../../services/repositories/smart-contract.repository.dart';
import '../../services/user/user.service.dart';

class CustomDialogBox extends StatefulWidget {
  CustomDialogBox(context, {Key? key}) : super(key: key);

  int? selectedChainId;
  String? selectedChain;
  String? selectedAddress;

  @override
  State<CustomDialogBox> createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  final userService = getIt<UserService>();
  final textController = TextEditingController();

  Future<List<Chain>> getChain() async {
    return SmartContract.getChain();
  }

  Future<List<Chain>>? _getChain;

  @override
  initState() {
    super.initState();
    _getChain = getChain();
  }

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
                  inputSelect(context, "Select chain...", addresses!, true, widget.selectedChainId, widget.selectedChain,
                      widget.selectedAddress),
                  const SizedBox(
                    height: 10,
                  ),
                  inputSelect(context, "Select wallet...", addresses, false, widget.selectedChainId, widget.selectedChain,
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
                    print(widget.selectedChainId);
                    if (textController.text.isEmpty) {
                      return;
                    }
                    if (double.parse(textController.text) >= 5000 &&
                        widget.selectedChainId != null &&
                        widget.selectedAddress != null) {
                      userService.claimABOAT(
                          widget.selectedChainId!, widget.selectedAddress!, double.parse(textController.text));
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
                  ClaimButton(context,
                      widget.selectedChain == null ? "Convert to {{chain-native}}" : "Convert to ${widget.selectedChain}",
                      () {
                    print("Convert to {{chain-native}}");
                    if (textController.text.isEmpty) {
                      return;
                    }
                    userService.claimABOATNative(
                        widget.selectedChainId!, widget.selectedAddress!, double.parse(textController.text));
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

  Widget inputSelect(BuildContext context, String hintText, List addresses, bool chain, int? selectedChainId,
      String? selectedChain, String? selectedAddress) {
    return FutureBuilder(
        future: _getChain,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  '${snapshot.error} occurred',
                  style: const TextStyle(fontSize: 18),
                ),
              );
            }

            final chains = snapshot.data;
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
                  value: chain ? widget.selectedChainId?.toString() : widget.selectedAddress,
                  items: chain
                      ? chains!
                          .map((e) => DropdownMenuItem<String>(
                              value: e.chainId.toString(),
                              child: Text(
                                e.chainName.toString(),
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
                          var chain = chains!.where((element) => e.toString() == element.chainId.toString());
                          setState(() {
                            widget.selectedChainId = int.parse(e!);
                            widget.selectedChain = chain.first.coin.toString();
                          });
                          print(e);
                        }
                      : (e) {
                          setState(() => widget.selectedAddress = e);
                          print(e);
                        }),
            );
          }
          return const SizedBox(height: 48, width: 48, child: CircularProgressIndicator());
        });
  }
}

void showAlert(BuildContext context, String address) {
  final userService = getIt<UserService>();
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
                    userService.deleteWallet(address);
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
