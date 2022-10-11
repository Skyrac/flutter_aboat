import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginAndRegisterBackground extends StatelessWidget {
  final Widget child;

  const LoginAndRegisterBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: size.height,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
              top: 0,
              right: 0,
              child: Container(
                color: Color.fromRGBO(29, 40, 58, 1),
                height: 110,
                width: size.width,
              )),
          Positioned(
            top: 100,
            right: 0,
            child:
                Image.asset("assets/images/wave_group.png", width: size.width),
          ),
          Positioned(
            top: 20,
            child: Image.asset("assets/images/logo_no_circle1.png",
                width: size.width * 0.13),
          ),
          Positioned(
            top: 80,
            child: Text("Talkaboat",
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                      color: Color.fromRGBO(99, 163, 253, 1),
                      fontWeight: FontWeight.w700,
                      fontSize: 24),
                )),
          ),
          // Positioned(
          //   bottom: 0,
          //   right: 0,
          //   child: Image.asset("assets/images/bottom1.png", width: size.width),
          // ),
          // Positioned(
          //   bottom: 0,
          //   right: 0,
          //   child: Image.asset("assets/images/bottom2.png", width: size.width),
          // ),
          child
        ],
      ),
    );
  }
}
