import 'package:flutter/material.dart';
import 'package:talkaboat/services/repositories/user.repository.dart';
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
  var isLogin = true;
  var sentEmail = false;
  final userService = getIt<UserService>();

  final emailController = TextEditingController();

  final pinController = TextEditingController();

  Future<void> sendPinRequest() async {
    final email = emailController.text;
    if (email.isValidEmail()) {
      await UserRepository.requestEmailLogin(email);
    }
  }

  Future<void> sendLogin(BuildContext context) async {
    final pin = pinController.text;
    final email = emailController.text;
    if (pin.length > 6 && email.isValidEmail()) {
      final userService = getIt<UserService>();
      if (await getIt<UserService>().emailLogin(email, pin)) {
        widget.refreshParent();
        Navigator.pop(context);
      }
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
    setState(() {
      sentEmail = true;
    });
    await sendPinRequest();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    print(sentEmail);
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
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.06),
                sentEmail
                    ? createEmailPinRequestWidget("Pin", () async {
                        await sendLogin(context);
                      }, pinController, "Login")
                    : createEmailPinRequestWidget(
                        "E-Mail", requestEmail, emailController, "Request Pin"),
                SizedBox(height: size.height * 0.01),
                Card(
                  color: DefaultColors.secondaryColorAlphaBlend.shade900,
                  child: InkWell(
                    onTap: () => userService.signInWithGoogle(),
                    child: Container(
                      height: 60,
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Text(
                          "Google Login",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )),
          ),
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
}
