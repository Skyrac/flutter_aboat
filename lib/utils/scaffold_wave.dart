import 'package:flutter/material.dart';

class ScaffoldWave extends StatelessWidget {
  const ScaffoldWave({required this.body, this.appBar, this.height = 66, this.physics, this.header, Key? key})
      : super(key: key);

  final PreferredSizeWidget? appBar;
  final Widget body;
  final double height;
  final ScrollPhysics? physics;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: const Color.fromRGBO(15, 23, 41, 1),
        child: Scaffold(
          appBar: appBar,
          body: Stack(
            children: [
              NestedScrollView(
                physics: physics,
                body: body,
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(child: SizedBox(height: height)),
                    header ?? const SliverToBoxAdapter(child: SizedBox())
                  ];
                },
              ),
              Container(
                color: Colors.transparent,
                height: 66,
                child: Image.asset(
                  height: 66,
                  width: MediaQuery.of(context).size.width,
                  "assets/images/wave_old.png",
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
