import 'package:Talkaboat/widgets/chat-input.widget.dart';
import 'package:flutter/material.dart';

class LiveControlls extends StatefulWidget {
  const LiveControlls({super.key, required this.roomId});

  final int roomId;

  @override
  State<LiveControlls> createState() => _LiveControllsState();
}

class _LiveControllsState extends State<LiveControlls> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    debugPrint("size: ${size.width} ${size.width - (5 * 2) - (10 * 2) - 100}");
    return Row(
      children: [
        SizedBox(
            height: 50,
            width: 50,
            child: MaterialButton(
                onPressed: () {
                  debugPrint("le button");
                },
                color: const Color.fromRGBO(29, 40, 58, 0.97),
                child: Image.asset("assets/icons/icon-chat-on.png"))),
        ChatInput(
          roomId: widget.roomId,
          messageType: 0,
          width: size.width - (5 * 2) - (10 * 2) - 100,
          positionSelf: false,
        )
      ],
    );
  }
}
