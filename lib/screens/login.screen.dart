import 'dart:io';

import 'package:Talkaboat/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_login_buttons/social_login_buttons.dart';

import '../injection/injector.dart';
import '../services/repositories/user.repository.dart';
import '../services/user/user.service.dart';
import '../themes/colors.dart';
import '../themes/login-and-register.background.dart';
import '../utils/Snackbar_Creator.dart';
import '../utils/modal.widget.dart';
import '../widgets/login-app-bar.widget.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen(this.refreshParent, {Key? key}) : super(key: key);
  final Function refreshParent;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var isLoading = false;
  var isLogin = true;
  var sentEmail = false;
  var dialog;
  var socialLoginPinVerification = TextEditingController();
  var socialLoginNewUser = TextEditingController();
  final userService = getIt<UserService>();

  final emailController = TextEditingController();

  final pinController = TextEditingController();

  Future<void> sendPinRequest() async {
    final email = emailController.text;
    if (email.isValidEmail()) {
      setState(() {
        isLoading = true;
        sentEmail = true;
      });
      await UserRepository.requestEmailLogin(email);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> sendLogin(BuildContext context) async {
    final pin = pinController.text;
    final email = emailController.text;
    if (pin.length > 3 && email.isValidEmail()) {
      setState(() {
        isLoading = true;
      });
      final userService = getIt<UserService>();
      if (await userService.emailLogin(email, pin)) {
        widget.refreshParent();
        Navigator.pop(context);
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  createEmailPinRequestWidget(String labelText, Function callback,
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromRGBO(29, 40, 58, 1),
                      // ignore: prefer_const_literals_to_create_immutables
                      boxShadow: [
                        const BoxShadow(
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
                        controller: textController,
                        onSubmitted: (_) async {
                          callback();
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          alignLabelWithHint: true,
                          hintText: labelText,
                          hintStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: const Color.fromRGBO(135, 135, 135, 1),
                                  fontStyle: FontStyle.italic),
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
                    side: const BorderSide(
                        color: Color.fromRGBO(188, 140, 75, 0.25), width: 1),
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
                            color: const Color.fromRGBO(15, 23, 41, 1),
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
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
                  child: const Center(child: Text("OR")),
                  width: 80,
                  height: 40,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromRGBO(
                              99, 163, 253, 1), // set border color
                          width: 2.0), // set border width
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20.0)))),
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

  requestEmail() async {
    await sendPinRequest();
  }

  socialButtonPressed(SocialLogin socialLogin) async {
    setState(() {
      isLoading = true;
    });

    try {
      if (await userService.socialLogin(socialLogin, context)) {
        ShowSnackBar(context, "Successfully signed in");
        widget.refreshParent();
        Navigator.pop(context);
        return;
      }
    } catch (exception) {
      print(exception);
    }

    setState(() {
      isLoading = false;
    });
    if (userService.lastConnectionState != null &&
        userService.lastConnectionState?.text != null) {
      if (userService.lastConnectionState?.text == "not_connected") {
        ShowSnackBar(context, "Check your E-Mail and Verify the Pin");
        showAlert(context, socialLoginPinVerification, "Verify Pin", "Pin", "",
            verifySocialLoginPin);
      } else if (userService.lastConnectionState?.text == "new_account") {
        ShowSnackBar(context, "Please create a new user");
        showAlert(context, socialLoginNewUser, "Enter Username", "Username", "",
            registerSocialLogin);
      } else {
        ShowSnackBar(context, "Unresolved response. Please contact an admin.");
      }
    } else {
      ShowSnackBar(context, "Unable to verify your login.");
    }
  }

  verifySocialLoginPin() async {
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    if (await userService.firebaseVerify(socialLoginPinVerification.text)) {
      setState(() {
        isLoading = false;
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.pop(context);
        widget.refreshParent();
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  registerSocialLogin() async {
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                new CircularProgressIndicator(),
                new Text("Loading"),
              ],
            ),
          ),
        );
      },
    );
    var successful =
        await userService.firebaseRegister(socialLoginNewUser.text, true);
    setState(() {
      Navigator.of(context, rootNavigator: true).pop();
      isLoading = false;
    });
    if (successful) {
      setState(() {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.pop(context);
        widget.refreshParent();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
        child: Container(
      decoration: const BoxDecoration(color: Color.fromRGBO(15, 23, 41, 1)),
      // gradient: LinearGradient(colors: [
      //   DefaultColors.primaryColor.shade900,
      //   DefaultColors.secondaryColor.shade900,
      //   DefaultColors.secondaryColor.shade900
      // ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Scaffold(
          body: Stack(
        children: [
          LoginAndRegisterBackground(
            child: Container(
              width: size.width > 500 ? 500 : size.width,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      margin: const EdgeInsets.only(left: 55),
                      child: Text(
                        "Login",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    createEmailPinRequestWidget("E-Mail...", () async {
                      await sendPinRequest();
                      await dialogBuilder(context);
                    }, emailController, "Request PIN"),
                    // sentEmail ? dialogBuilder(context) : SizedBox(),
                    // sentEmail
                    //     ? createEmailPinRequestWidget("Pin", () async {
                    //         await sendLogin(context);
                    //       }, pinController, "Login")
                    //     : createEmailPinRequestWidget("E-Mail...", () async {
                    //         await sendPinRequest();
                    //         await dialogBuilder(context);
                    //       }, emailController, "Request PIN"),
                    // sentEmail
                    //     ? createEmailPinRequestWidget("Pin", () async {
                    //         await sendLogin(context);
                    //       }, pinController, "Login")
                    //     : createEmailPinRequestWidget(
                    //         "E-Mail", requestEmail, emailController, "Get Pin"),
                    SizedBox(height: size.height * 0.05),
                    createAppleLogin(),
                    SizedBox(height: Platform.isIOS ? 10 : 0),
                    signInButton(
                        image: "apple.png",
                        socialLogin: SocialLogin.Apple,
                        text: "Apple"),

                    const SizedBox(
                      height: 10,
                    ),
                    signInButton(
                        image: "google.png",
                        socialLogin: SocialLogin.Google,
                        text: "Google"),
                    const SizedBox(
                      height: 10,
                    ),
                    signInButton(
                        image: "facebook.png",
                        socialLogin: SocialLogin.Facebook,
                        text: "Facebook"),
                  ],
                ),
              ),
            ),
          ),
          isLoading
              ? const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Card(
                      color: Colors.transparent,
                      child: Center(
                        child: CircularProgressIndicator(),
                      )))
              : const SizedBox(),
          const Positioned(
              top: 5,
              left: 0,
              right: 0,
              height: 80,
              child: LoginAppBarWidget()),
        ],
      )),
    ));
  }

  createAppleLogin() {
    return Platform.isIOS
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: SocialLoginButton(
              buttonType: SocialLoginButtonType.apple,
              mode: SocialLoginButtonMode.single,
              text: "Sign in with Apple",
              onPressed: () async {
                await socialButtonPressed(SocialLogin.Apple);
              },
            ),
          )
        : const SizedBox();
  }

  signInButton(
      {required String image,
      required String text,
      required SocialLogin socialLogin}) {
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
                color: const Color.fromRGBO(
                    188, 140, 75, 0.25), // set border color
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
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color.fromRGBO(99, 163, 253, 1),
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ));
  }

  Future<void> dialogBuilder(BuildContext context) async {
    final email = emailController.text;
    final size = MediaQuery.of(context).size;
    return showDialog<void>(
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
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color.fromRGBO(48, 73, 123, 1)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 5),
                        child: Center(
                            child: Text(
                          "Confirm PIN",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        )),
                      ),
                      const SizedBox(
                        height: 7,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 23.5),
                        child: Text.rich(TextSpan(children: [
                          TextSpan(
                            text: 'You should receive a PIN on ',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          TextSpan(
                            text: email,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text:
                                ' to verify your login. If you have no account registered under your email, you’ll be asked to setup an username after sign in.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ])),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        alignment: Alignment.center,
                        child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color.fromRGBO(29, 40, 58, 1),
                                // ignore: prefer_const_literals_to_create_immutables
                                boxShadow: [
                                  const BoxShadow(
                                    color: Color.fromRGBO(188, 140, 75, 1),
                                    spreadRadius: 0,
                                    blurRadius: 0,
                                    offset: Offset(
                                        0, 1), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: TextField(
                                  controller: pinController,
                                  onSubmitted: (_) async {
                                    await sendLogin(context);
                                  },
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    alignLabelWithHint: true,
                                    hintText: "PIN...",
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            color: const Color.fromRGBO(
                                                135, 135, 135, 1),
                                            fontStyle: FontStyle.italic),
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
                          child: Container(
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RawMaterialButton(
                                    onPressed: () async {
                                      await sendLogin(context);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          const BoxShadow(
                                            color: Colors.black45,
                                            spreadRadius: 1,
                                            blurRadius: 5,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(15),
                                        color: const Color.fromRGBO(
                                            99, 163, 253, 1),
                                        border: Border.all(
                                            color: const Color.fromRGBO(
                                                188, 140, 75, 0.25),
                                            width: 1.0), //
                                      ),
                                      height: 40,
                                      width: 150,
                                      child: Center(
                                        child: Text(
                                          "Confirm",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                  color: const Color.fromRGBO(
                                                      15, 23, 41, 1),
                                                  fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  RawMaterialButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          const BoxShadow(
                                            color: Colors.black45,
                                            spreadRadius: 1,
                                            blurRadius: 5,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(15),
                                        color:
                                            const Color.fromRGBO(154, 0, 0, 1),
                                        border: Border.all(
                                            color: const Color.fromRGBO(
                                                188, 140, 75, 0.25),
                                            width: 1.0), //
                                      ),
                                      height: 40,
                                      width: 80,
                                      child: Center(
                                        child: Text(
                                          "Cancel",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                  color: const Color.fromRGBO(
                                                      164, 202, 255, 1),
                                                  fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                  )
                                ]),
                          ))
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
