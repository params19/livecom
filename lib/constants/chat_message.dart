import 'package:flutter/material.dart';
import 'package:livecom/models/message_model.dart';

class ChatMessage extends StatefulWidget {
  final MessageModel message;
  final String currentUserId;
  final bool isImage;
  const ChatMessage(
      {super.key,
      required this.message,
      required this.currentUserId,
      required this.isImage});

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: widget.message.sender == widget.currentUserId
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: widget.message.sender == widget.currentUserId
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    child: Text(widget.message.message),
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
