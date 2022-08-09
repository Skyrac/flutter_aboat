import 'dart:io';

import 'package:Talkaboat/utils/extensions.dart';
import 'package:flutter/material.dart';
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                alignment: Alignment.center,
                child: Card(
                  color: DefaultColors.secondaryColorAlphaBlend.shade900,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: TextField(
                      controller: textController,
                      onSubmitted: (_) async {
                        callback();
                      },
                      decoration: InputDecoration(labelText: labelText),
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              child: Card(
                color: DefaultColors.secondaryColorAlphaBlend.shade900,
                child: InkWell(
                  onTap: () => callback(),
                  child: Container(
                    height: 60,
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Text(
                        buttonText,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
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
    } catch(exception) {
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
    var successful = await userService.firebaseRegister(socialLoginNewUser.text, true);
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
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                DefaultColors.primaryColor.shade900,
                DefaultColors.secondaryColor.shade900,
                DefaultColors.secondaryColor.shade900
              ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
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
                            SizedBox(height: size.height * 0.06),
                            sentEmail
                                ? createEmailPinRequestWidget("Pin", () async {
                              await sendLogin(context);
                            }, pinController, "Login")
                                : createEmailPinRequestWidget(
                                "E-Mail", requestEmail, emailController, "Get Pin"),
                            SizedBox(height: size.height * 0.01),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 50),
                              child: SocialLoginButton(
                                buttonType: SocialLoginButtonType.google,
                                mode: SocialLoginButtonMode.single,
                                text: "Sign in with Google",
                                onPressed: () async {
                                  await socialButtonPressed(SocialLogin.Google);
                                },
                              ),
                            ),
                            SizedBox(height: 10,),
                            createAppleLogin(),
                            SizedBox(height: Platform.isIOS ? 10 : 0),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 50),
                              child: SocialLoginButton(
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
                      : SizedBox(),
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
    return Platform.isIOS ?

      Padding(
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
     :  SizedBox() ;
  }
}
