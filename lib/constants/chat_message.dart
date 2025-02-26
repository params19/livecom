import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:livecom/constants/color.dart';
import 'package:livecom/constants/date_format.dart';
import 'package:livecom/controllers/appwrite_controllers.dart';
import 'package:livecom/models/message_model.dart';
import 'package:livecom/providers/chat_provider.dart';
import 'package:provider/provider.dart';

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
    Map groupInviteData = widget.message.isGroupInvite == true
        ? jsonDecode(widget.message.message) ?? {}
        : {};
    return widget.message.isGroupInvite == true
        ? Container(
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: widget.message.sender == widget.currentUserId
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.message.sender == widget.currentUserId
                      ? "You send a group invitation for ${groupInviteData["name"]}."
                      : "Group invitation for ${groupInviteData["name"]}."),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * .8,
                  decoration: BoxDecoration(
                      color: widget.message.sender == widget.currentUserId
                          ? Colors.blue.shade400
                          : secondary_color,
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                            radius: 35,
                            backgroundImage: groupInviteData["image"] == null &&
                                    groupInviteData["image"] == ""
                                ? Image(
                                    image: AssetImage("assets/user.png"),
                                  ).image
                                : CachedNetworkImageProvider(
                                    "https://cloud.appwrite.io/v1/storage/buckets/67b7f7a000142a335f4e/files/${groupInviteData["image"]}/view?project=67b7e512000635cad2ad&mode=admin")),
                        Text(
                          groupInviteData["name"] ?? "",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color:
                                  widget.message.sender == widget.currentUserId
                                      ? Colors.white
                                      : Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          groupInviteData["desc"] ?? "",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: widget.message.sender == widget.currentUserId
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                onPressed: () async {
                                  if (widget.message.sender ==
                                      widget.currentUserId) {
                                    // cancel the invitation
                                    Provider.of<ChatProvider>(context,
                                            listen: false)
                                        .deleteMessage(widget.message,
                                            widget.currentUserId);
                                  } else {
                                    await addUserToGroup(
                                            groupId: groupInviteData["id"],
                                            currentUser: widget.currentUserId)
                                        .then((value) {
                                      if (value) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    "Joined ${groupInviteData["name"]} group successfully.")));
                                        Provider.of<ChatProvider>(context,
                                                listen: false)
                                            .deleteMessage(widget.message,
                                                widget.currentUserId);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    "Error in joining group.")));
                                      }
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: widget.message.sender ==
                                            widget.currentUserId
                                        ? Colors.white
                                        : Colors.blue),
                                child: Text(
                                  widget.message.sender == widget.currentUserId
                                      ? "Cancel Invitation"
                                      : "Join Group",
                                  style: TextStyle(
                                      color: widget.message.sender ==
                                              widget.currentUserId
                                          ? Colors.blue
                                          : Colors.white),
                                )),
                            if (widget.message.sender != widget.currentUserId)
                              SizedBox(
                                width: 10,
                              ),
                            if (widget.message.sender != widget.currentUserId)
                              OutlinedButton(
                                  onPressed: () {
                                    Provider.of<ChatProvider>(context,
                                            listen: false)
                                        .deleteMessage(widget.message,
                                            widget.currentUserId);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Colors.red.shade300,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    "Reject",
                                    style:
                                        TextStyle(color: Colors.red.shade300),
                                  ))
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        : widget.isImage
            ? Container(
                child: Row(
                  mainAxisAlignment:
                      widget.message.sender == widget.currentUserId
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
                                    "https://cloud.appwrite.io/v1/storage/buckets/67b7f7a000142a335f4e/files/${widget.message.message}/view?project=67b7e512000635cad2ad&mode=admin",
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
                                    color:
                                        Theme.of(context).colorScheme.outline),
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
                  mainAxisAlignment:
                      widget.message.sender == widget.currentUserId
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
                                  color: widget.message.sender ==
                                          widget.currentUserId
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
                                        color: const Color.fromARGB(
                                            255, 4, 125, 224),
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
