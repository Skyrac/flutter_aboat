import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/chat/chat-dtos.dart';
import 'package:Talkaboat/models/chat/message-history-request-dto.dart';
import 'package:Talkaboat/services/hubs/chat/chat.service.dart';
import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';

class Chat extends StatefulWidget {
  final int roomId;

  const Chat({Key? key, required this.roomId}) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final chatService = getIt<ChatService>();
  final focusNode = FocusNode();
  final List<String> messageType = ["", "Podcast", "Episode"];

  Widget buildMessage(context, ChatMessageDto entry) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 7.5, 20, 7.5),
        child: SwipeTo(
          onLeftSwipe: () {
            print("swipe");
            // _displayInputBottomSheet(true);
            focusNode.requestFocus();
          },
          child: RawMaterialButton(
            onLongPress: () {},
            onPressed: () {},
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromRGBO(29, 40, 58, 0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: RawMaterialButton(
                    onPressed: () {
                      print(entry.id);
                    },
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text(
                              entry.senderName.toString(),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(messageType[entry.messageType],
                                style: const TextStyle(color: Color.fromRGBO(99, 163, 253, 1))),
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 25),
                          child: Align(alignment: Alignment.centerLeft, child: Text(entry.content.toString())),
                        ),
                      ],
                    ),
                  ),
                )),
          ),
        ),
      );

  Widget buildMessages(List<ChatMessageDto> data) => ListView.builder(
      physics: const ScrollPhysics(),
      shrinkWrap: true,
      itemCount: data.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        final item = data[index];
        var messageIndex = index;
        return buildMessage(context, item);
      });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: chatService,
      builder: (BuildContext context, Widget? child) {
        return FutureBuilder(
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      '${snapshot.error} occurred',
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                } else if (snapshot.hasData && snapshot.data != null) {
                  // Extracting data from snapshot object
                  final data = snapshot.data as List<ChatMessageDto>?;
                  if (data != null && data.isNotEmpty) {
                    // return Text(data[1].content.toString());
                    return Container(
                      alignment: Alignment.topCenter,
                      // height: 400,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          buildMessages(data),
                        ],
                      ),
                    );
                  } else {
                    return SizedBox(
                      height: 300,
                      child: Stack(alignment: Alignment.bottomCenter, children: [
                        Positioned(
                          top: 0,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Text(
                              'No data found for this podcast. Please try again later!',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ]),
                    );
                  }
                }
              }

              return const Center(
                child: CircularProgressIndicator(),
              );
            },
            future: chatService.getHistory(MessageHistoryRequestDto(roomId: widget.roomId, direction: 0)));
      },
    );
  }
}
