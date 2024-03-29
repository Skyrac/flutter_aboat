import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:Talkaboat/screens/app.screen.dart';
import 'package:Talkaboat/themes/colors.dart';
import 'package:Talkaboat/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  @override
  initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: const Color.fromRGBO(15, 23, 41, 1), // navigation bar color
        statusBarColor: DefaultColors.secondaryColor.shade900 // status bar color
        ));
    super.initState();
  }

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
        ShowSnackBar(context, AppLocalizations.of(context)!.errorGettingPIN);
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // returns true if we need to register, false otherwise
  Future<bool> sendLogin(BuildContext context, String email, String pin) async {
    final navigator = Navigator.of(context);
    if (pin.length > 3 && email.isValidEmail()) {
      setState(() {
        isLoading = true;
      });
      final result = await userService.emailLogin(email, pin);
      debugPrint(result);
      if (result == "new_account") {
        setState(() {
          isLoading = false;
        });
        return true;
      } else if (result == "true") {
        navAway(navigator);
      } else {
        Fluttertoast.showToast(msg: AppLocalizations.of(context)!.errorLoggingIn);
      }
      setState(() {
        isLoading = false;
      });
    }
    return false;
  }

  createEmailPinRequestWidget(BuildContext context, String labelText, void Function(BuildContext context) callback,
          TextEditingController textController, String buttonText) =>
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
                          callback(context);
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
                  onTap: () => callback(context),
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
                  child: Center(child: Text(AppLocalizations.of(context)!.or))),
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

  String _removeWhitespaces(text) {
    return text.replaceAll(RegExp(r'\s'), '');
  }

  socialButtonPressed(SocialLogin socialLogin) async {
    final navigator = Navigator.of(context);
    setState(() {
      isLoading = true;
    });

    try {
      if (await userService.socialLogin(socialLogin, context)) {
        navAway(navigator);
        return;
      }
    } catch (exception) {
      userService.logout();
      debugPrint("$exception");
    }

    setState(() {
      isLoading = false;
    });
    if (userService.lastConnectionState != null && userService.lastConnectionState?.text != null) {
      if (userService.lastConnectionState?.text == "not_connected") {
        ShowSnackBar(context, AppLocalizations.of(context)!.checkYourEMail);
        final bodyMediumTheme = Theme.of(context).textTheme.bodyMedium;
        final pinResult = await showInputDialog(context, AppLocalizations.of(context)!.confirmPIN, (_) {
          return [
            TextSpan(
              text: AppLocalizations.of(context)!.receivePIN,
              style: bodyMediumTheme,
            ),
            TextSpan(
              text: emailController.text,
              style: bodyMediumTheme?.copyWith(fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: AppLocalizations.of(context)!.receivePIN2,
              style: bodyMediumTheme,
            ),
          ];
        }, "Pin...", (pin) => pin.length >= 7, AppLocalizations.of(context)!.invalidPin);
        //showAlert(context, socialLoginPinVerification, "Verify Pin", "Pin", "", verifySocialLoginPin);
      } else if (userService.lastConnectionState?.text == "new_account") {
        await doSocialRegister(context, Theme.of(context).textTheme.bodyMedium!, navigator, null);
      } else {
        ShowSnackBar(context, AppLocalizations.of(context)!.unresolvedResponse);
      }
    } else {
      ShowSnackBar(context, AppLocalizations.of(context)!.unableToVerify);
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

  Future<String?> showUsernameDialog(BuildContext context, TextStyle theme, String? rejectedUsername) async {
    final username = await showInputDialog(
        context,
        AppLocalizations.of(context)!.chooseAnUsername,
        (_) => [
              TextSpan(
                text: AppLocalizations.of(context)!.yourUsernameWillBeShown,
                style: theme,
              ),
              rejectedUsername != null
                  ? TextSpan(
                      text: AppLocalizations.of(context)!.usernameIsInvalid(rejectedUsername),
                      style: theme.copyWith(color: Colors.red.shade100),
                    )
                  : const TextSpan()
            ],
        "${AppLocalizations.of(context)!.username}...",
        null,
        null);
    return username;
  }

  Future<void> doEmailRegister(
      BuildContext context, TextStyle theme, String pinResult, NavigatorState navigator, String? rejectedUsername) async {
    var isUsernameValid = false;
    while (!isUsernameValid) {
      final username = await showUsernameDialog(context, theme, rejectedUsername);
      debugPrint(username);
      if (username != null) {
        setState(() {
          isLoading = true;
        });
        final registerResult = await userService.emailRegister(emailController.text, pinResult, username, false);
        setState(() {
          isLoading = false;
        });
        isUsernameValid = true;
        debugPrint("registerResult $registerResult");
        if (registerResult == null) {
          // returns error
          navAway(navigator);
        } else {
          // register error
          if (registerResult.contains("username_invalid") ||
              registerResult.contains("User or Wallet is already registered!")) {
            debugPrint("invalid $username");
            isUsernameValid = false;
            Fluttertoast.showToast(msg: "invalid username $username");
          } else {
            ShowSnackBar(context, AppLocalizations.of(context)!.errorRegistering);
          }
        }
      } else {
        debugPrint("cancel");
        // cancel
        return;
      }
    }
  }

  Future<void> doSocialRegister(
      BuildContext context, TextStyle theme, NavigatorState navigator, String? rejectedUsername) async {
    final username = await showUsernameDialog(context, theme, rejectedUsername);
    if (username != null) {
      setState(() {
        isLoading = true;
      });
      var registerResult = await userService.firebaseRegister(username, true);
      setState(() {
        isLoading = false;
      });
      if (registerResult == null) {
        // returns error
        navAway(navigator);
      } else {
        // register error
        if (registerResult.contains("username_invalid")) {
          await doSocialRegister(context, theme, navigator, username);
        } else {
          ShowSnackBar(context, AppLocalizations.of(context)!.errorRegistering);
        }
      }
    } else {
      debugPrint("cancel");
      // cancel
      return;
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
                            child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(AppLocalizations.of(context)!.continueAsGuest))))
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
                            createEmailPinRequestWidget(context, "E-Mail...", (context) async {
                              final navigator = Navigator.of(context);
                              final bodyMediumTheme = Theme.of(context).textTheme.bodyMedium;
                              await sendPinRequest();
                              final pinResult =
                                  await showInputDialog(context, AppLocalizations.of(context)!.confirmPIN, (_) {
                                return [
                                  TextSpan(
                                    text: AppLocalizations.of(context)!.receivePIN,
                                    style: bodyMediumTheme,
                                  ),
                                  TextSpan(
                                    text: emailController.text,
                                    style: bodyMediumTheme?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  TextSpan(
                                    text: AppLocalizations.of(context)!.receivePIN2,
                                    style: bodyMediumTheme,
                                  ),
                                ];
                              }, "Pin...", (pin) => pin.length >= 7, AppLocalizations.of(context)!.invalidPin);
                              if (pinResult != null) {
                                // Confirm
                                setState(() {
                                  isLoading = true;
                                });
                                final loginResult = await sendLogin(context, emailController.text, pinResult);
                                debugPrint("$loginResult");
                                setState(() {
                                  isLoading = false;
                                });
                                if (loginResult) {
                                  await doEmailRegister(context, bodyMediumTheme!, pinResult, navigator, null);
                                } else {
                                  //loginResult == false -> not a new account
                                }
                              } else {
                                // Cancel from PIN Dialog
                                return;
                              }
                            }, emailController, AppLocalizations.of(context)!.requestPIN),
                            SizedBox(height: size.height * 0.05),
                            createAppleLogin(),
                            SizedBox(height: Platform.isIOS ? 10 : 0),
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
                  AppLocalizations.of(context)!.signIn(text),
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
      BuildContext context,
      String title,
      List<TextSpan> Function(BuildContext context) textBuilder,
      String hintText,
      bool Function(String)? validate,
      String? validateErrorTest) async {
    final textController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        bool isValid = true;
        final bodyMediumTheme = Theme.of(context).textTheme.bodyMedium;
        return StatefulBuilder(builder: (context, setState) {
          return Container(
            width: 200,
            color: Colors.black12,
            child: Stack(alignment: Alignment.center, children: [
              Positioned(
                top: 200,
                child: Container(
                  width: min(MediaQuery.of(context).size.width * 0.8, 360),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(20), color: const Color.fromRGBO(48, 73, 123, 1)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
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
                          child: Text.rich(TextSpan(children: [
                            ...textBuilder(context),
                            validateErrorTest != null && !isValid
                                ? TextSpan(
                                    text: validateErrorTest,
                                    style: bodyMediumTheme?.copyWith(fontWeight: FontWeight.w600),
                                  )
                                : const TextSpan()
                          ])),
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

                                  final text = _removeWhitespaces(textController.text);
                                  if (validate != null) {
                                    bool _valid = validate(text);
                                    if (_valid) {
                                      Navigator.of(context).pop(text);
                                    } else {
                                      setState(
                                        () {
                                          isValid = false;
                                        },
                                      );
                                    }
                                  } else {
                                    Navigator.of(context).pop(text);
                                  }
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
                                      AppLocalizations.of(context)!.confirm,
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
                                      AppLocalizations.of(context)!.cancel,
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
              ),
            ]),
          );
        });
      },
    );
  }
}
