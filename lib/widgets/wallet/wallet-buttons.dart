import 'package:flutter/material.dart';

class ClaimButton extends StatelessWidget {
  const ClaimButton(context, this.title, this.func, this.color, {Key? key}) : super(key: key);
  final String title;
  final VoidCallback? func;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: const Color.fromRGBO(29, 40, 58, 0.97),
          border: Border.all(
              color: const Color.fromRGBO(188, 140, 75, 0.25), // set border color
              width: 1.0), //
        ),
        height: 40,
        child: RawMaterialButton(
          onPressed: func,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color),
              ),
            ],
          ),
        ));
  }
}

class WalletButton extends StatelessWidget {
  const WalletButton(this.textButton, this.func, this.textColor, this.imageLink, {Key? key}) : super(key: key);
  final String? textButton;
  final VoidCallback? func;
  final Color? textColor;
  final String? imageLink;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: RawMaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onPressed: func,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromRGBO(29, 40, 58, 1),
            boxShadow: [
              const BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.25),
                spreadRadius: -0.2,
                blurRadius: 0,
                offset: Offset(0, 4), // changes position of shadow
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(textButton!, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: textColor)),
              Image.asset(
                imageLink!,
                width: 35,
                height: 30,
                fit: BoxFit.cover,
              )
            ],
          ),
        ),
      ),
    );
  }
}
