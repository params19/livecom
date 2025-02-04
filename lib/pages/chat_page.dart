import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:livecom/constants/chat_message.dart';
import 'package:livecom/constants/color.dart';
import 'package:livecom/models/message_model.dart';
import 'package:livecom/pages/home_page.dart';

class ChatPage extends StatefulWidget {
  // final List<MessageModel> messages;

  // // Constructor to receive messages
  // ChatPage({required this.messages});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  List messages = [
    MessageModel(
        message: "Hello",
        sender: "101",
        receiver: "202",
        timestamp: DateTime(2024, 1, 1),
        isSeenByReceiver: true,
        isImage: true),
    MessageModel(
      message: "hi",
      sender: "202",
      receiver: "101",
      timestamp: DateTime(2024, 1, 2),
      isSeenByReceiver: false,
      isImage: true,
    ),
    MessageModel(
      message: "how are you?",
      sender: "101",
      receiver: "202",
      timestamp: DateTime(2024, 1, 3),
      isSeenByReceiver: false,
      isImage: true,
    ),
    MessageModel(
      message: "how are you?",
      sender: "101",
      receiver: "202",
      timestamp: DateTime(2024, 1, 3),
      isSeenByReceiver: false,
      isImage: true,
    ),
  ];

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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        title: const Row(
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
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(8),
              child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) => ChatMessage(
                      message: messages[index],
                      currentUserId: "101",
                      isImage: messages[index].isImage ?? false)),
            ),
          ),
          Container(
              margin: EdgeInsets.all(6),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: secondary_color,
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: messageController,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type a message..."),
                    ),
                  ),
                  IconButton(onPressed: () {}, icon: Icon(Icons.image)),
                  IconButton(onPressed: () {}, icon: Icon(Icons.send))
                ],
              ))
        ],
      ),
    );
  }
}
