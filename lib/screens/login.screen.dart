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
              height: 10,
            ),
            Row(children: <Widget>[
              Expanded(
                  child: Divider(
                color: Color.fromRGBO(99, 163, 253, 1),
                thickness: 2,
              )),
              Container(
                  child: Center(child: Text("OR")),
                  width: 80,
                  height: 40,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Color.fromRGBO(
                              99, 163, 253, 1), // set border color
                          width: 2.0), // set border width
                      borderRadius: BorderRadius.all(Radius.circular(20.0)))),
              Expanded(
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
                    sentEmail
                        ? createEmailPinRequestWidget("Pin", () async {
                            await sendLogin(context);
                          }, pinController, "Login")
                        : createEmailPinRequestWidget("E-Mail...", requestEmail,
                            emailController, "Request PIN"),
                    // sentEmail
                    //     ? createEmailPinRequestWidget("Pin", () async {
                    //         await sendLogin(context);
                    //       }, pinController, "Login")
                    //     : createEmailPinRequestWidget(
                    //         "E-Mail", requestEmail, emailController, "Get Pin"),
                    SizedBox(height: size.height * 0.01),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Color.fromRGBO(
                                  188, 140, 75, 0.25), // set border color
                              width: 1.0), // set border width
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      margin: const EdgeInsets.symmetric(horizontal: 50),
                      child: SocialLoginButton(
                        backgroundColor: Color.fromRGBO(29, 40, 58, 0.97),
                        imageWidth: 25,
                        height: 40,
                        borderRadius: 15,
                        buttonType: SocialLoginButtonType.google,
                        mode: SocialLoginButtonMode.single,
                        text: "Sign in with Google",
                        onPressed: () async {
                          await socialButtonPressed(SocialLogin.Google);
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    createAppleLogin(),
                    SizedBox(height: Platform.isIOS ? 10 : 0),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Color.fromRGBO(
                                  188, 140, 75, 0.25), // set border color
                              width: 1.0), // set border width
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      margin: const EdgeInsets.symmetric(horizontal: 50),
                      child: SocialLoginButton(
                        backgroundColor: Color.fromRGBO(29, 40, 58, 0.97),
                        imageWidth: 25,
                        height: 40,
                        borderRadius: 15,
                        textColor: Color.fromRGBO(99, 163, 253, 1),
                        buttonType: SocialLoginButtonType.facebook,
                        mode: SocialLoginButtonMode.single,
                        text: "Sign in with Facebook",
                        onPressed: () async {
                          await socialButtonPressed(SocialLogin.Facebook);
                        },
                      ),
                    ),
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
}
