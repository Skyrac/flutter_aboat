import 'package:flutter/material.dart';
import 'package:social_login_buttons/social_login_buttons.dart';
import 'package:talkaboat/services/repositories/user.repository.dart';
import 'package:talkaboat/utils/Snackbar_Creator.dart';
import 'package:talkaboat/utils/extensions.dart';

import '../injection/injector.dart';
import '../services/user/user.service.dart';
import '../themes/colors.dart';
import '../themes/login-and-register.background.dart';
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
    if (pin.length > 6 && email.isValidEmail()) {
      setState(() {
        isLoading = true;
      });
      final userService = getIt<UserService>();
      if (await getIt<UserService>().emailLogin(email, pin)) {
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

  verifySocialLoginPin() async {
    if (await userService.firebaseVerify(socialLoginPinVerification.text)) {
      setState(() {
        Navigator.pop(context);
        widget.refreshParent();
        Navigator.pop(context);
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.06),
                    sentEmail
                        ? createEmailPinRequestWidget("Pin", () async {
                            await sendLogin(context);
                          }, pinController, "Login")
                        : createEmailPinRequestWidget("E-Mail", requestEmail,
                            emailController, "Request Pin"),
                    SizedBox(height: size.height * 0.01),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 100),
                      child: SocialLoginButton(
                        buttonType: SocialLoginButtonType.google,
                        mode: SocialLoginButtonMode.single,
                        text: "Google Sign In",
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });

                          if (await userService.signInWithGoogle()) {
                            widget.refreshParent();
                            Navigator.pop(context);
                            return;
                          }
                          if (userService.lastConnectionState != null &&
                              userService.lastConnectionState?.text != null) {
                            if (userService.lastConnectionState?.text ==
                                "not_connected") {
                              ShowSnackBar(context,
                                  "Check your E-Mail and Verify the Pin");
                              showAlert(
                                  context,
                                  socialLoginPinVerification,
                                  "Verify Pin",
                                  "Pin",
                                  "",
                                  verifySocialLoginPin);
                            } else if (userService.lastConnectionState?.text ==
                                "new_account") {
                              ShowSnackBar(context,
                                  "Please create a new account with given E-Mail");
                              // showAlert(
                              //     context,
                              //     socialLoginPinVerification,
                              //     "Enter Username",
                              //     "Username",
                              //     "",
                              //     () async => {});
                            }
                          }
                          ShowSnackBar(context, "test 1");
                          setState(() {
                            isLoading = false;
                          });
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
              top: 0,
              left: 0,
              right: 0,
              height: 80,
              child: LoginAppBarWidget()),
        ],
      )),
    ));
  }

  void showAlert(BuildContext context, TextEditingController controller,
      String title, String? label, String? hint, Function submitFunction) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).dialogBackgroundColor,
              title: Text(title),
              elevation: 8,
              content: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                      hintText: hint,
                      labelText: label,
                      labelStyle: Theme.of(context).textTheme.labelLarge,
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ))),
              actions: [
                TextButton(
                    onPressed: (() async {
                      submitFunction();
                    }),
                    child: Text("Submit")),
                TextButton(
                    onPressed: (() {
                      Navigator.pop(context);
                    }),
                    child: Text("Cancel"))
              ],
            ));
  }
}
