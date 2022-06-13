import 'package:flutter/material.dart';
import 'package:talkaboat/services/repositories/user.repository.dart';
import 'package:talkaboat/utils/extensions.dart';

import '../themes/colors.dart';
import '../themes/login-and-register.background.dart';
import '../widgets/login-app-bar.widget.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);
  var isLogin = true;
  final emailController = TextEditingController();
  final pinController = TextEditingController();

  Future<void> sendPinRequest() async {
    final email = emailController.text;
    if (email.isValidEmail()) {
      await UserRepository.requestEmailLogin(email);
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
          const LoginAppBarWidget(),
          LoginAndRegisterBackground(
            child: Container(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.06),
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  child: Card(
                    color: DefaultColors.secondaryColorAlphaBlend.shade900,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: TextField(
                        controller: emailController,
                        onSubmitted: (_) async {
                          await sendPinRequest();
                        },
                        decoration: InputDecoration(labelText: "E-Mail"),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.01),
                Container(
                  alignment: Alignment.center,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  child: InkWell(
                    onTap: () async {
                      await sendPinRequest();
                    },
                    child: const Text("Request E-Mail with pin",
                        style:
                            TextStyle(fontSize: 12, color: Color(0XFF2661FA))),
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  child: Card(
                    color: DefaultColors.secondaryColorAlphaBlend.shade900,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: TextField(
                        controller: pinController,
                        decoration: const InputDecoration(labelText: "Pin"),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.05),
                Container(
                  alignment: Alignment.centerRight,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  child: RaisedButton(
                    onPressed: () {},
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(80.0)),
                    textColor: Colors.white,
                    padding: const EdgeInsets.all(0),
                    child: Container(
                      alignment: Alignment.center,
                      height: 50.0,
                      width: size.width * 0.5,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(80.0),
                          gradient: const LinearGradient(colors: [
                            Color.fromARGB(255, 255, 136, 34),
                            Color.fromARGB(255, 255, 177, 41)
                          ])),
                      padding: const EdgeInsets.all(0),
                      child: const Text(
                        "LOGIN",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                // Container(
                //   alignment: Alignment.centerRight,
                //   margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                //   child: GestureDetector(
                //     onTap: () => {
                //       Navigator.push(context,
                //           MaterialPageRoute(builder: (context) => RegisterScreen()))
                //     },
                //     child: Text(
                //       "Don't Have an Account? Sign up",
                //       style: TextStyle(
                //           fontSize: 12,
                //           fontWeight: FontWeight.bold,
                //           color: Color(0xFF2661FA)),
                //     ),
                //   ),
                // )
              ],
            )),
          ),
        ],
      )),
    ));
  }
}
