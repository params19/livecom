import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:livecom/constants/chat_message.dart';
import 'package:livecom/constants/color.dart';
import 'package:livecom/models/message_model.dart';

class ChatPage extends StatefulWidget {
  List messages = [
    MessageModel(
        message: "Hello",
        sender: "101",
        receiver: "202",
        timestamp: DateTime(2024, 1, 1),
        isSeenByReceiver: true,
        isGroupInvite: false),
    MessageModel(
        message: "hi",
        sender: "202",
        receiver: "101",
        timestamp: DateTime(2024, 1, 2),
        isSeenByReceiver: false,
        isGroupInvite: false),
    MessageModel(
        message: "how are you?",
        sender: "101",
        receiver: "202",
        timestamp: DateTime(2024, 1, 3),
        isGroupInvite: false,
        isSeenByReceiver: false),
    MessageModel(
        message: "how are you?",
        sender: "101",
        receiver: "202",
        timestamp: DateTime(2024, 1, 4),
        isSeenByReceiver: false,
        isImage: true,
        isGroupInvite: false),
  ];

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: background_color,
        leadingWidth: 40,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // Back button
          onPressed: () {
            // Navigates back
          },
        ),
        title: Row(
          children: [
            CircleAvatar(),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Other User",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  "Online",
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
      
    );
    
  }
}
