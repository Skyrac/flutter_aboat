import 'dart:io';

import 'package:Talkaboat/screens/app.screen.dart';
import 'package:Talkaboat/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../injection/injector.dart';
import '../services/repositories/user.repository.dart';
import '../services/user/user.service.dart';
import '../themes/login-and-register.background.dart';
import '../utils/Snackbar_Creator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen(this.shouldPop, {this.allowPop = true, this.refreshParent, Key? key}) : super(key: key);
  final Function? refreshParent;
  final bool shouldPop;
  final bool allowPop;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var isLoading = false;

  final userService = getIt<UserService>();

  final emailController = TextEditingController();

  void navAway(NavigatorState navigator) {
    if (widget.refreshParent != null) {
      widget.refreshParent!();
    }
    if (widget.shouldPop) {
      navigator.pop();
    } else {
      navigator.pushReplacement(MaterialPageRoute(builder: (context) => const AppScreen(title: 'Talkaboat')));
    }
  }

  Future<void> sendPinRequest() async {
    final email = emailController.text;
    if (email.isValidEmail()) {
      setState(() {
        isLoading = true;
      });
      var result = await UserRepository.requestEmailLogin(email);
      if (result != null) {
        setState(() {
          isLoading = false;
        });
      } else {
        ShowSnackBar(context, "Error getting PIN");
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<bool> sendLogin(BuildContext context, String email, String pin) async {
    final navigator = Navigator.of(context);
    if (pin.length > 3 && email.isValidEmail()) {
      setState(() {
        isLoading = true;
      });
      final result = await userService.emailLogin(email, pin);
      print(result);
      if (result == "new_account") {
        setState(() {
          isLoading = false;
        });
        return true;
      } else if (result == "true") {
        navAway(navigator);
      } else {
        ShowSnackBar(context, "Error lgging in");
      }
      setState(() {
        isLoading = false;
      });
    }
    return false;
  }

  createEmailPinRequestWidget(
          String labelText, Function callback, TextEditingController textController, String buttonText) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Container(
                    height: 40,
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
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: TextField(
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color.fromRGBO(164, 202, 255, 1),
                            ),
                        controller: textController,
                        onSubmitted: (_) async {
                          callback();
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          alignLabelWithHint: true,
                          hintText: labelText,
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
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Card(
                shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Color.fromRGBO(188, 140, 75, 0.25), width: 1),
                    borderRadius: BorderRadius.circular(15)),
                color: const Color.fromRGBO(99, 163, 253, 1),
                child: InkWell(
                  onTap: () => callback(),
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Text(
                        buttonText,
                        style: GoogleFonts.inter(
                            color: const Color.fromRGBO(15, 23, 41, 1), fontWeight: FontWeight.w600, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Row(children: <Widget>[
              const Expanded(
                  child: Divider(
                color: Color.fromRGBO(99, 163, 253, 1),
                thickness: 2,
              )),
              Container(
                  width: 80,
                  height: 40,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromRGBO(99, 163, 253, 1), // set border color
                          width: 2.0), // set border width
                      borderRadius: const BorderRadius.all(Radius.circular(20.0))),
                  child: const Center(child: Text("OR"))),
              const Expanded(
                  child: Divider(
                color: Color.fromRGBO(99, 163, 253, 1),
                thickness: 2,
              )),
            ]),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      );

  socialButtonPressed(SocialLogin socialLogin) async {
    setState(() {
      isLoading = true;
    });

    try {
      if (await userService.socialLogin(socialLogin, context)) {
        navAway(Navigator.of(context));
        return;
      }
    } catch (exception) {
      print(exception);
    }

    setState(() {
      isLoading = false;
    });
    if (userService.lastConnectionState != null && userService.lastConnectionState?.text != null) {
      if (userService.lastConnectionState?.text == "not_connected") {
        ShowSnackBar(context, "Check your E-Mail and Verify the Pin");
        final bodyMediumTheme = Theme.of(context).textTheme.bodyMedium;
        final pinResult = await showInputDialog(context, "Confirm PIN", (_) {
          return Text.rich(TextSpan(children: [
            TextSpan(
              text: 'You should receive a PIN on ',
              style: bodyMediumTheme,
            ),
            TextSpan(
              text: emailController.text,
              style: bodyMediumTheme?.copyWith(fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text:
                  ' to verify your login. If you have no account registered under your email, you’ll be asked to setup an username after sign in.',
              style: bodyMediumTheme,
            ),
          ]));
        }, "Pin...");
        //showAlert(context, socialLoginPinVerification, "Verify Pin", "Pin", "", verifySocialLoginPin);
      } else if (userService.lastConnectionState?.text == "new_account") {
        final result = await showInputDialog(
            context,
            "Choose an username",
            (_) => Text.rich(TextSpan(children: [
                  TextSpan(
                    text:
                        'Your username will be shown for in social media features as well as comments and ratings you might leave for podcasts and episodes.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ])),
            "Username...");
        if (result != null) {
          registerSocialLogin(result);
        } else {
          // cancel
        }
      } else {
        ShowSnackBar(context, "Unresolved response. Please contact an admin.");
      }
    } else {
      ShowSnackBar(context, "Unable to verify your login.");
    }
  }

  verifySocialLoginPin(String pin) async {
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    if (await userService.firebaseVerify(pin)) {
      setState(() {
        isLoading = false;
        //widget.refreshParent();
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  registerSocialLogin(String username) async {
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    var successful = await userService.firebaseRegister(username, true);
    print("successful: $successful");
    setState(() {
      isLoading = false;
    });
    if (successful) {
      setState(() {
        navAway(Navigator.of(context));
      });
    } else {
      ShowSnackBar(context, "Error registering");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
        onWillPop: () => Future.value(widget.allowPop),
        child: Stack(children: [
          SafeArea(
            child: Container(
              decoration: const BoxDecoration(color: Color.fromRGBO(15, 23, 41, 1)),
              child: Scaffold(
                bottomNavigationBar: Stack(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: InkWell(
                            onTap: () async {
                              await userService.loginAsGuest();
                              navAway(Navigator.of(context));
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10), child: Text("Continue as guest"))))
                  ]),
                  isLoading
                      ? Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Card(
                              color: const Color.fromRGBO(15, 23, 41, 0.75),
                              margin: const EdgeInsets.all(0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                              child: null))
                      : const SizedBox()
                ]),
                body: Stack(
                  children: [
                    LoginAndRegisterBackground(
                      child: SizedBox(
                        width: size.width > 500 ? 500 : size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              alignment: Alignment.topLeft,
                              margin: const EdgeInsets.only(left: 55),
                              child: Text(
                                "Login",
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            SizedBox(height: size.height * 0.02),
                            createEmailPinRequestWidget("E-Mail...", () async {
                              final bodyMediumTheme = Theme.of(context).textTheme.bodyMedium;
                              await sendPinRequest();
                              final pinResult = await showInputDialog(context, "Confirm PIN", (_) {
                                return Text.rich(TextSpan(children: [
                                  TextSpan(
                                    text: 'You should receive a PIN on ',
                                    style: bodyMediumTheme,
                                  ),
                                  TextSpan(
                                    text: emailController.text,
                                    style: bodyMediumTheme?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  TextSpan(
                                    text:
                                        ' to verify your login. If you have no account registered under your email, you’ll be asked to setup an username after sign in.',
                                    style: bodyMediumTheme,
                                  ),
                                ]));
                              }, "Pin...");
                              if (pinResult != null) {
                                // Confirm
                                setState(() {
                                  isLoading = true;
                                });
                                final loginResult = await sendLogin(context, emailController.text, pinResult);
                                print(loginResult);
                                setState(() {
                                  isLoading = false;
                                });
                                if (loginResult) {
                                  // new user
                                  final username = await showInputDialog(
                                      context,
                                      "Choose an username",
                                      (_) => Text.rich(TextSpan(children: [
                                            TextSpan(
                                              text:
                                                  'Your username will be shown for in social media features as well as comments and ratings you might leave for podcasts and episodes.',
                                              style: bodyMediumTheme,
                                            ),
                                          ])),
                                      "Username...");
                                  if (username != null) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    final registerResult =
                                        await UserRepository.emailRegister(emailController.text, pinResult, username, false);
                                    setState(() {
                                      isLoading = false;
                                    });
                                    if (registerResult) {
                                      //widget.refreshParent();
                                    } else {
                                      // register error
                                    }
                                  } else {
                                    print("cancel");
                                    // cancel
                                    return;
                                  }
                                } else {
                                  //loginResult == false -> not a new account
                                }
                              } else {
                                // Cancel from PIN Dialog
                                return;
                              }
                            }, emailController, "Request PIN"),
                            SizedBox(height: size.height * 0.05),
                            createAppleLogin(),
                            SizedBox(height: Platform.isIOS ? 10 : 0),
                            createAppleLogin(),
                            const SizedBox(
                              height: 10,
                            ),
                            signInButton(image: "google.png", socialLogin: SocialLogin.Google, text: "Google"),
                            const SizedBox(
                              height: 10,
                            ),
                            signInButton(image: "facebook.png", socialLogin: SocialLogin.Facebook, text: "Facebook"),
                          ],
                        ),
                      ),
                    ),
                    isLoading
                        ? Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Card(
                                color: const Color.fromRGBO(15, 23, 41, 0.75),
                                margin: const EdgeInsets.all(0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color.fromRGBO(99, 163, 253, 1),
                                  ),
                                )))
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
          ),
        ]));
  }

  createAppleLogin() {
    return Platform.isIOS
        ? signInButton(image: "apple.png", socialLogin: SocialLogin.Apple, text: "Apple")
        : const SizedBox();
  }

  signInButton({required String image, required String text, required SocialLogin socialLogin}) {
    return RawMaterialButton(
        onPressed: () async {
          await socialButtonPressed(socialLogin);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 50),
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
                Image.asset("assets/images/$image", width: 25),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "Sign in with $text",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: const Color.fromRGBO(99, 163, 253, 1), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ));
  }

  Future<String?> showInputDialog(
      BuildContext context, String title, Text Function(BuildContext context) textBuilder, String hintText) async {
    final textController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return Builder(builder: (context) {
          return Container(
            width: 150,
            height: 150,
            color: Colors.black12,
            child: Stack(alignment: Alignment.center, children: [
              Positioned(
                top: 200,
                child: Container(
                  width: 300,
                  height: 260,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(20), color: const Color.fromRGBO(48, 73, 123, 1)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 5),
                        child: Center(
                            child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        )),
                      ),
                      const SizedBox(
                        height: 7,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 23.5),
                        child: textBuilder(context),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        alignment: Alignment.center,
                        child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: Container(
                              height: 40,
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
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                child: TextField(
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: const Color.fromRGBO(164, 202, 255, 1),
                                      ),
                                  controller: textController,
                                  onSubmitted: (text) {
                                    Navigator.of(context).pop(text);
                                  },
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    alignLabelWithHint: true,
                                    hintText: hintText,
                                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: const Color.fromRGBO(135, 135, 135, 1), fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ),
                            )),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            RawMaterialButton(
                              onPressed: () {
                                Navigator.of(context).pop(textController.text);
                              },
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
                                width: 150,
                                child: Center(
                                  child: Text(
                                    "Confirm",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(color: const Color.fromRGBO(15, 23, 41, 1), fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            RawMaterialButton(
                              onPressed: () {
                                Navigator.of(context).pop(null);
                              },
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
                                width: 80,
                                child: Center(
                                  child: Text(
                                    "Cancel",
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        color: const Color.fromRGBO(164, 202, 255, 1), fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            )
                          ]))
                    ],
                  ),
                ),
              ),
            ]),
          );
        });
      },
    );
  }
}
