import 'package:appwrite/models.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:livecom/constants/chat_message.dart';
import 'package:livecom/constants/color.dart';
import 'package:livecom/controllers/appwrite_controllers.dart';
import 'package:livecom/models/message_model.dart';
import 'package:livecom/models/user_model.dart';
import 'package:livecom/pages/home_page.dart';
import 'package:livecom/providers/chat_provider.dart';
import 'package:livecom/providers/user_data_provider.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  // final List<MessageModel> messages;

  // // Constructor to receive messages
  // ChatPage({required this.messages});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();

  late String currentUserId;
  late String currentUserName;

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
  void initState() {
    // TODO: implement initState
    currentUserId =
        Provider.of<UserDataProvider>(context, listen: false).getUserId;
    currentUserName =
        Provider.of<UserDataProvider>(context, listen: false).getUserName;
    super.initState();
  }

// to send simple text message
  void _sendMessage({required UserData receiver}) {
    if (messageController.text.isNotEmpty) {
      setState(() {
        createNewChat(
                message: messageController.text,
                senderId: currentUserId,
                receiverId: receiver.userId,
                isImage: false,
                isGroupInvite: false)
            .then((value) {
          if (value) {
            Provider.of<ChatProvider>(context, listen: false).addMessage(
                MessageModel(
                  message: messageController.text,
                  sender: currentUserId,
                  receiver: receiver.userId,
                  timestamp: DateTime.now(),
                  isSeenByReceiver: false,
                ),
                currentUserId,
                [UserData(phone: "", userId: currentUserId), receiver]);
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    UserData receiver = ModalRoute.of(context)!.settings.arguments as UserData;
    return Consumer<ChatProvider>(
      builder: (context, value, child) {
        final userAndOtherChats = value.getAllChats[receiver.userId] ?? [];
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
            title: Row(
              children: [
                CircleAvatar(
                  backgroundImage: receiver.profilePic == "" ||
                          receiver.profilePic == null
                      ? Image(
                          image: AssetImage("assets/user.png"),
                        ).image
                      : CachedNetworkImageProvider(
                          "https://cloud.appwrite.io/v1/storage/buckets/67a3d9aa002c49506451/files/${receiver.profilePic}/view?project=67a316ad003a50945b8b&mode=admin"),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receiver.name!,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      userAndOtherChats == true ? "Online" : "Offline",
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
                        itemCount: userAndOtherChats.length,
                        itemBuilder: (context, index) {
                          final msg = userAndOtherChats[
                                  userAndOtherChats.length - 1 - index]
                              .message;

                          ChatMessage(
                              isImage: msg.isImage ?? false,
                              message: msg,
                              currentUserId: currentUserId);
                        })),
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
      },
    );
  }
}
