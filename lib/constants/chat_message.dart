import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:livecom/constants/color.dart';
import 'package:livecom/constants/date_format.dart';
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
    return widget.isImage
        ? Container(
            child: Row(
              mainAxisAlignment: widget.message.sender == widget.currentUserId
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment:
                      widget.message.sender == widget.currentUserId
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.all(4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                            imageUrl:
                                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcREOermuzN2tCHhrj4MURWQS9pcFjSFfUKjtQ&s",
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 3),
                          child: Text(
                            formatDate(widget.message.timestamp),
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.outline),
                          ),
                        ),
                        widget.message.sender == widget.currentUserId
                            ? widget.message.isSeenByReceiver
                                ? Icon(
                                    Icons.check_circle_outlined,
                                    size: 16,
                                    color: primary_blue,
                                  )
                                : Icon(
                                    Icons.check_circle_outlined,
                                    size: 16,
                                    color: Colors.grey,
                                  )
                            : SizedBox()
                      ],
                    )
                  ],
                )
              ],
            ),
          )
        : Container(
            padding: EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: widget.message.sender == widget.currentUserId
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment:
                      widget.message.sender == widget.currentUserId
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                              color:
                                  widget.message.sender == widget.currentUserId
                                      ? primary_blue
                                      : secondary_color,
                              borderRadius: BorderRadius.only(
                                bottomLeft: widget.message.sender ==
                                        widget.currentUserId
                                    ? Radius.circular(20)
                                    : Radius.circular(2),
                                bottomRight: widget.message.sender ==
                                        widget.currentUserId
                                    ? Radius.circular(2)
                                    : Radius.circular(20),
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              )),
                          child: Text(
                            widget.message.message,
                            style: TextStyle(
                                color: widget.message.sender ==
                                        widget.currentUserId
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 3),
                          child: Text(
                            formatDate(widget.message.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),
                        widget.message.sender == widget.currentUserId
                            ? widget.message.isSeenByReceiver
                                ? Icon(
                                    Icons.check_circle_outline,
                                    color:
                                        const Color.fromARGB(255, 4, 125, 224),
                                    size: 15,
                                  )
                                : Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.grey,
                                    size: 15,
                                  )
                            : Container()
                      ],
                    )
                  ],
                ),
              ],
            ),
          );
  }
}
