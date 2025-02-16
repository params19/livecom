import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:livecom/constants/color.dart';
import 'package:livecom/constants/date_format.dart';
import 'package:livecom/controllers/appwrite_controllers.dart';
import 'package:livecom/controllers/notification_controller.dart';
import 'package:livecom/models/chat_data_model.dart';
import 'package:livecom/models/user_model.dart';
import 'package:livecom/providers/chat_provider.dart';
import 'package:livecom/providers/user_data_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String currentUserId = "";

  @override
  void initState() {
    // TODO: implement initState
    currentUserId =
        Provider.of<UserDataProvider>(context, listen: false).getUserId;
    Provider.of<ChatProvider>(context, listen: false).loadChats(currentUserId);
    PushNotifications.getDeviceToken();
    subscribeToRealtime(userId: currentUserId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background_color,
      appBar: AppBar(
        backgroundColor: background_color,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: const Text(
          "Chats",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 29),
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, "/profile"),
            child: Consumer<UserDataProvider>(
              builder: (context, value, child) {
                return CircleAvatar(
                  backgroundImage: value.getUserProfile != null &&
                          value.getUserProfile != ""
                      ? CachedNetworkImageProvider(
                          "https://cloud.appwrite.io/v1/storage/buckets/67a3d9aa002c49506451/files/${value.getUserProfile}/view?project=67a316ad003a50945b8b&mode=admin")
                      : const AssetImage("assets/user.png") as ImageProvider,
                );
              },
            ),
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, value, child) {
          if (value.getAllChats.isEmpty) {
            return const Center(
              child: Text("No chats yet!"),
            );
          } else {
            List otherUsers = value.getAllChats.keys.toList();

            return ListView.builder(
              itemCount: otherUsers.length,
              itemBuilder: (context, index) {
                List<ChatDataModel> chatData =
                    value.getAllChats[otherUsers[index]]!;
                int totalChats = chatData.length;
                UserData otherUser =
                    chatData[0].users[0].userId == currentUserId
                        ? chatData[0].users[1]
                        : chatData[0].users[0];

                int unreadMsg = 0;
                chatData.fold(unreadMsg, (previousValue, element) {
                  if (element.message.isSeenByReceiver == false) {
                    return unreadMsg++;
                  }
                  return unreadMsg;
                });
                return ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, "/chat", arguments: otherUser);
                  },
                  leading: Stack(
                    children: [
                      CircleAvatar(
                          backgroundImage: otherUser.profilePic == null ||
                                  otherUser.profilePic!.isEmpty
                              ? Image(
                                  image: AssetImage("assets/user.png"),
                                ).image
                              : CachedNetworkImageProvider(
                                  "https://cloud.appwrite.io/v1/storage/buckets/67a3d9aa002c49506451/files/${otherUser.profilePic}/view?project=67a316ad003a50945b8b&mode=admin")),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 6,
                          backgroundColor:
                              otherUser.isOnline == true ? Colors.green : null,
                        ),
                      ),
                    ],
                  ),
                  title: Text(otherUser.name!),
                  subtitle: Text(
                    "${chatData[totalChats - 1].message.sender == currentUserId ? "You: " : ""}${chatData[totalChats - 1].message.isImage == true ? "Sent an image" : chatData[totalChats - 1].message.message}",
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      chatData[totalChats - 1].message.sender != currentUserId
                          ? unreadMsg != 0
                              ? CircleAvatar(
                                  backgroundColor: primary_blue,
                                  radius: 10,
                                  child: Text(
                                    unreadMsg.toString(),
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.white),
                                  ),
                                )
                              : SizedBox()
                          : SizedBox(),
                      SizedBox(height: 8),
                      Text(formatDate(
                          chatData[totalChats - 1].message.timestamp)),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.chat),
      ),
    );
  }
}
